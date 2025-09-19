const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { TaskService, TaskController } = require('./TaskModule');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8080;
const JWT_SECRET = process.env.JWT_SECRET || 'campus-circle-secret-key';

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件服务
app.use(express.static(__dirname));

// 根路径提供 index.html
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

// MySQL数据库连接配置
const dbConfig = {
  host: process.env.DB_HOST || '43.138.4.157',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Group21Password',
  database: process.env.DB_NAME || 'campus_project',
  charset: 'utf8mb4'
};

// 创建数据库连接池
const pool = mysql.createPool(dbConfig);

// 初始化任务服务和控制器
const taskService = new TaskService(pool);
const taskController = new TaskController(taskService);

// 测试数据库连接
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('✅ MySQL数据库连接成功');
    connection.release();
  } catch (error) {
    console.error('❌ MySQL数据库连接失败:', error.message);
    process.exit(1);
  }
}

// 密码哈希函数（使用SHA256与数据库兼容）
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

// 验证密码
function verifyPassword(password, hashedPassword) {
  const hashInput = crypto.createHash('sha256').update(password).digest('hex');
  return hashInput === hashedPassword;
}

// 生成JWT Token
function generateToken(user) {
  return jwt.sign(
    { 
      userId: user.id, 
      studentNumber: user.student_number,
      email: user.email 
    },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
}

// 用户注册API
app.post('/api/v1/auth/register', async (req, res) => {
  try {
    const {
      student_number,
      email,
      password,
      nickname,
      real_name,
      major,
      grade
    } = req.body;

    // 验证必填字段
    if (!student_number || !email || !password || !nickname || !real_name || !major || !grade) {
      return res.status(400).json({
        success: false,
        message: '请填写所有必需字段'
      });
    }

    // 检查学号是否已存在
    const [existingStudentNumber] = await pool.execute(
      'SELECT id FROM users WHERE student_number = ?',
      [student_number]
    );

    if (existingStudentNumber.length > 0) {
      return res.status(400).json({
        success: false,
        message: '该学号已被注册'
      });
    }

    // 检查邮箱是否已存在
    const [existingEmail] = await pool.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingEmail.length > 0) {
      return res.status(400).json({
        success: false,
        message: '该邮箱已被注册'
      });
    }

    // 创建新用户
    const userId = uuidv4().replace(/-/g, '').substring(0, 32); // 移除连字符并截取32位
    const hashedPassword = hashPassword(password);
    const now = new Date();

    await pool.execute(
      `INSERT INTO users (
        id, student_number, email, password, nickname, real_name,
        major, grade, status, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)`,
      [userId, student_number, email, hashedPassword, nickname, real_name, major, grade, now, now]
    );

    // 创建用户详细信息
    await pool.execute(
      `INSERT INTO user_profiles (
        user_id, total_points, level, posts_count, comments_count, likes_received,
        created_at, updated_at
      ) VALUES (?, 0, 1, 0, 0, 0, ?, ?)`,
      [userId, now, now]
    );

    // 获取新创建的用户信息
    const [userRows] = await pool.execute(
      'SELECT * FROM users WHERE id = ?',
      [userId]
    );

    const user = userRows[0];
    delete user.password; // 不返回密码

    res.status(201).json({
      success: true,
      message: '注册成功',
      data: {
        id: user.id,
        student_number: user.student_number,
        email: user.email,
        nickname: user.nickname,
        real_name: user.real_name,
        major: user.major,
        grade: user.grade,
        avatar_url: user.avatar_url,
        phone: user.phone,
        status: user.status,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    });

  } catch (error) {
    console.error('注册错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 用户登录API
app.post('/api/v1/auth/login', async (req, res) => {
  try {
    const { account, password } = req.body;

    if (!account || !password) {
      return res.status(400).json({
        success: false,
        message: '请输入账号和密码'
      });
    }

    // 查找用户（通过学号或邮箱）
    const [userRows] = await pool.execute(
      'SELECT * FROM users WHERE (student_number = ? OR email = ?) AND status = 1',
      [account, account]
    );

    if (userRows.length === 0) {
      return res.status(401).json({
        success: false,
        message: '账号不存在或已被禁用'
      });
    }

    const user = userRows[0];

    // 验证密码
    if (!verifyPassword(password, user.password)) {
      return res.status(401).json({
        success: false,
        message: '密码错误'
      });
    }

    // 更新最后登录时间
    await pool.execute(
      'UPDATE users SET last_login_time = ? WHERE id = ?',
      [new Date(), user.id]
    );

    // 获取用户详细信息
    const [profileRows] = await pool.execute(
      'SELECT * FROM user_profiles WHERE user_id = ?',
      [user.id]
    );

    const profile = profileRows[0] || {};

    // 生成Token
    const token = generateToken(user);

    delete user.password; // 不返回密码

    res.json({
      success: true,
      message: '登录成功',
      data: {
        token: token,
        user: {
          id: user.id,
          student_number: user.student_number,
          email: user.email,
          nickname: user.nickname,
          real_name: user.real_name,
          major: user.major,
          grade: user.grade,
          avatar_url: user.avatar_url,
          phone: user.phone,
          status: user.status,
          last_login_time: user.last_login_time,
          created_at: user.created_at,
          updated_at: user.updated_at
        },
        userProfile: {
          userId: profile.user_id || user.id,
          bio: profile.bio,
          interests: profile.interests,
          location: profile.location,
          socialLinks: profile.social_links,
          privacySettings: profile.privacy_settings,
          totalPoints: profile.total_points || 0,
          level: profile.level || 1,
          postsCount: profile.posts_count || 0,
          commentsCount: profile.comments_count || 0,
          likesReceived: profile.likes_received || 0,
          createdAt: profile.created_at,
          updatedAt: profile.updated_at
        }
      }
    });

  } catch (error) {
    console.error('登录错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 检查学号是否存在API
app.get('/api/v1/auth/check-student-number', async (req, res) => {
  try {
    const { student_number } = req.query;

    if (!student_number) {
      return res.status(400).json({
        success: false,
        message: '请提供学号'
      });
    }

    const [rows] = await pool.execute(
      'SELECT id FROM users WHERE student_number = ?',
      [student_number]
    );

    res.json({
      success: true,
      data: {
        exists: rows.length > 0
      }
    });

  } catch (error) {
    console.error('检查学号错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 检查邮箱是否存在API
app.get('/api/v1/auth/check-email', async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: '请提供邮箱'
      });
    }

    const [rows] = await pool.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    res.json({
      success: true,
      data: {
        exists: rows.length > 0
      }
    });

  } catch (error) {
    console.error('检查邮箱错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// JWT验证中间件
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      success: false,
      message: '访问令牌缺失'
    });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: '访问令牌无效'
      });
    }
    req.user = user;
    next();
  });
}

// 用户登出API
app.post('/api/v1/auth/logout', async (req, res) => {
  try {
    // 这里可以添加JWT验证和token失效逻辑
    // 目前只是简单返回成功，因为我们没有实现token黑名单
    res.json({
      success: true,
      message: '登出成功'
    });
  } catch (error) {
    console.error('登出错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 更新用户资料API
app.put('/api/v1/user/profile', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      nickname,
      phone,
      bio,
      location,
      interests,
      socialLinks
    } = req.body;

    console.log('更新用户资料请求:', userId, req.body);

    // 开始事务
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 更新用户基本信息
      if (nickname !== undefined || phone !== undefined) {
        const userUpdateFields = [];
        const userUpdateValues = [];

        if (nickname !== undefined) {
          userUpdateFields.push('nickname = ?');
          userUpdateValues.push(nickname);
        }

        if (phone !== undefined) {
          userUpdateFields.push('phone = ?');
          userUpdateValues.push(phone);
        }

        if (userUpdateFields.length > 0) {
          userUpdateFields.push('updated_at = ?');
          userUpdateValues.push(new Date());
          userUpdateValues.push(userId);

          await connection.execute(
            `UPDATE users SET ${userUpdateFields.join(', ')} WHERE id = ?`,
            userUpdateValues
          );
        }
      }

      // 更新用户资料信息
      if (bio !== undefined || location !== undefined || interests !== undefined || socialLinks !== undefined) {
        const profileUpdateFields = [];
        const profileUpdateValues = [];

        if (bio !== undefined) {
          profileUpdateFields.push('bio = ?');
          profileUpdateValues.push(bio);
        }

        if (location !== undefined) {
          profileUpdateFields.push('location = ?');
          profileUpdateValues.push(location);
        }

        if (interests !== undefined) {
          profileUpdateFields.push('interests = ?');
          profileUpdateValues.push(JSON.stringify(interests));
        }

        if (socialLinks !== undefined) {
          profileUpdateFields.push('social_links = ?');
          profileUpdateValues.push(JSON.stringify(socialLinks));
        }

        if (profileUpdateFields.length > 0) {
          profileUpdateFields.push('updated_at = ?');
          profileUpdateValues.push(new Date());
          profileUpdateValues.push(userId);

          await connection.execute(
            `UPDATE user_profiles SET ${profileUpdateFields.join(', ')} WHERE user_id = ?`,
            profileUpdateValues
          );
        }
      }

      // 提交事务
      await connection.commit();

      // 获取更新后的用户信息
      const [userRows] = await connection.execute(
        'SELECT * FROM users WHERE id = ? AND status = 1',
        [userId]
      );

      const [profileRows] = await connection.execute(
        'SELECT * FROM user_profiles WHERE user_id = ?',
        [userId]
      );

      if (userRows.length === 0) {
        return res.status(404).json({
          success: false,
          message: '用户不存在'
        });
      }

      const user = userRows[0];
      const profile = profileRows[0] || {};

      delete user.password; // 不返回密码

      // 生成新的Token（可选，用于刷新用户信息）
      const token = generateToken(user);

      res.json({
        success: true,
        message: '资料更新成功',
        data: {
          token: token,
          user: {
            id: user.id,
            student_number: user.student_number,
            email: user.email,
            nickname: user.nickname,
            real_name: user.real_name,
            major: user.major,
            grade: user.grade,
            avatar_url: user.avatar_url,
            phone: user.phone,
            status: user.status,
            last_login_time: user.last_login_time,
            created_at: user.created_at,
            updated_at: user.updated_at
          },
          userProfile: {
            userId: profile.user_id || user.id,
            bio: profile.bio,
            interests: profile.interests ? JSON.parse(profile.interests) : null,
            location: profile.location,
            socialLinks: profile.social_links ? JSON.parse(profile.social_links) : null,
            privacySettings: profile.privacy_settings ? JSON.parse(profile.privacy_settings) : null,
            totalPoints: profile.total_points || 0,
            level: profile.level || 1,
            postsCount: profile.posts_count || 0,
            commentsCount: profile.comments_count || 0,
            likesReceived: profile.likes_received || 0,
            createdAt: profile.created_at,
            updatedAt: profile.updated_at
          }
        }
      });

    } catch (error) {
      // 回滚事务
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('更新用户资料错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 获取用户信息API
app.get('/api/v1/user/profile', async (req, res) => {
  try {
    // 这里可以添加JWT验证中间件
    const { user_id } = req.query;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: '请提供用户ID'
      });
    }

    const [userRows] = await pool.execute(
      'SELECT * FROM users WHERE id = ? AND status = 1',
      [user_id]
    );

    if (userRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }

    const user = userRows[0];
    delete user.password;

    const [profileRows] = await pool.execute(
      'SELECT * FROM user_profiles WHERE user_id = ?',
      [user_id]
    );

    const profile = profileRows[0] || {};

    res.json({
      success: true,
      data: {
        user: user,
        profile: profile
      }
    });

  } catch (error) {
    console.error('获取用户信息错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 健康检查API
app.get('/api/v1/health', (req, res) => {
  res.json({
    success: true,
    message: '服务运行正常',
    timestamp: new Date().toISOString()
  });
});

// ====================================
// 分区管理API
// ====================================

// 获取所有分区列表
app.get('/api/v1/sections', async (req, res) => {
  try {
    const { page = 1, limit = 20, status = 1 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const limitValue = parseInt(limit);
    const statusValue = parseInt(status);

    const [sections] = await pool.execute(
      `SELECT s.*, u.nickname as creator_name 
       FROM sections s 
       LEFT JOIN users u ON s.creator_id = u.id 
       WHERE s.status = ? 
       ORDER BY s.sort_order DESC, s.created_at DESC 
       LIMIT ${limitValue} OFFSET ${offset}`,
      [statusValue]
    );

    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM sections WHERE status = ?',
      [statusValue]
    );

    res.json({
      success: true,
      data: {
        sections: sections,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: countResult[0].total,
          totalPages: Math.ceil(countResult[0].total / parseInt(limit))
        }
      }
    });
  } catch (error) {
    console.error('获取分区列表错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 获取分区详情
app.get('/api/v1/sections/:sectionId', async (req, res) => {
  try {
    const { sectionId } = req.params;

    const [sectionRows] = await pool.execute(
      `SELECT s.*, u.nickname as creator_name 
       FROM sections s 
       LEFT JOIN users u ON s.creator_id = u.id 
       WHERE s.id = ? AND s.status = 1`,
      [sectionId]
    );

    if (sectionRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '分区不存在'
      });
    }

    const section = sectionRows[0];

    // 获取最近的帖子
    const [recentPosts] = await pool.execute(
      `SELECT sp.*, u.nickname as author_name 
       FROM section_posts sp 
       LEFT JOIN users u ON sp.user_id = u.id 
       WHERE sp.section_id = ? AND sp.status = 1 
       ORDER BY sp.created_at DESC 
       LIMIT 5`,
      [sectionId]
    );

    res.json({
      success: true,
      data: {
        section: section,
        recentPosts: recentPosts
      }
    });
  } catch (error) {
    console.error('获取分区详情错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 创建新分区
app.post('/api/v1/sections', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      name,
      description,
      icon = 'default',
      color = '#007AFF',
      is_public = 1,
      join_permission = 1,
      post_permission = 1,
      rules,
      tags = []
    } = req.body;

    // 验证必填字段
    if (!name || !description) {
      return res.status(400).json({
        success: false,
        message: '分区名称和描述不能为空'
      });
    }

    // 检查用户创建的分区数量
    const [userSections] = await pool.execute(
      'SELECT COUNT(*) as count FROM sections WHERE creator_id = ? AND status != 0',
      [userId]
    );

    const maxSections = 5; // 可以从系统配置中读取
    if (userSections[0].count >= maxSections) {
      return res.status(400).json({
        success: false,
        message: `每个用户最多只能创建${maxSections}个分区`
      });
    }

    // 检查分区名称是否重复
    const [existingSection] = await pool.execute(
      'SELECT id FROM sections WHERE name = ? AND status != 0',
      [name]
    );

    if (existingSection.length > 0) {
      return res.status(400).json({
        success: false,
        message: '分区名称已存在'
      });
    }

    // 创建分区
    const sectionId = uuidv4().replace(/-/g, '').substring(0, 32);
    const memberId = uuidv4().replace(/-/g, '').substring(0, 32);
    const now = new Date();

    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 插入分区记录
      await connection.execute(
        `INSERT INTO sections (
          id, name, description, icon, color, creator_id, 
          is_public, join_permission, post_permission, rules, 
          tags, member_count, post_count, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 0, ?, ?)`,
        [
          sectionId, name, description, icon, color, userId,
          is_public, join_permission, post_permission, rules,
          JSON.stringify(tags), now, now
        ]
      );

      // 创建者自动加入分区
      await connection.execute(
        `INSERT INTO section_members (
          id, section_id, user_id, role, status, joined_at, updated_at
        ) VALUES (?, ?, ?, 3, 1, ?, ?)`,
        [memberId, sectionId, userId, now, now]
      );

      await connection.commit();

      // 获取创建的分区信息
      const [newSection] = await connection.execute(
        `SELECT s.*, u.nickname as creator_name 
         FROM sections s 
         LEFT JOIN users u ON s.creator_id = u.id 
         WHERE s.id = ?`,
        [sectionId]
      );

      res.status(201).json({
        success: true,
        message: '分区创建成功',
        data: newSection[0]
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('创建分区错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 加入分区
app.post('/api/v1/sections/:sectionId/join', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { sectionId } = req.params;
    const { join_reason } = req.body;

    // 检查分区是否存在
    const [sectionRows] = await pool.execute(
      'SELECT * FROM sections WHERE id = ? AND status = 1',
      [sectionId]
    );

    if (sectionRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '分区不存在'
      });
    }

    const section = sectionRows[0];

    // 检查用户是否已加入
    const [memberRows] = await pool.execute(
      'SELECT * FROM section_members WHERE section_id = ? AND user_id = ? AND status != 0',
      [sectionId, userId]
    );

    if (memberRows.length > 0) {
      return res.status(400).json({
        success: false,
        message: '您已加入该分区'
      });
    }

    // 检查加入权限
    if (section.join_permission === 3) { // 仅邀请
      return res.status(403).json({
        success: false,
        message: '该分区仅限邀请加入'
      });
    }

    const memberId = uuidv4().replace(/-/g, '').substring(0, 32);
    const now = new Date();
    const memberStatus = section.join_permission === 2 ? 2 : 1; // 需要审核 : 正常

    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 添加成员记录
      await connection.execute(
        `INSERT INTO section_members (
          id, section_id, user_id, role, join_reason, status, joined_at, updated_at
        ) VALUES (?, ?, ?, 1, ?, ?, ?, ?)`,
        [memberId, sectionId, userId, join_reason, memberStatus, now, now]
      );

      // 更新分区成员数量
      await connection.execute(
        'UPDATE sections SET member_count = member_count + 1, updated_at = ? WHERE id = ?',
        [now, sectionId]
      );

      await connection.commit();

      res.json({
        success: true,
        message: section.join_permission === 2 ? '申请已提交，等待审核' : '成功加入分区'
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('加入分区错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 退出分区
app.delete('/api/v1/sections/:sectionId/leave', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { sectionId } = req.params;

    // 检查用户是否为分区成员
    const [memberRows] = await pool.execute(
      'SELECT * FROM section_members WHERE section_id = ? AND user_id = ? AND status = 1',
      [sectionId, userId]
    );

    if (memberRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '您不是该分区的成员'
      });
    }

    const member = memberRows[0];

    // 检查是否为创建者
    if (member.role === 3) {
      return res.status(403).json({
        success: false,
        message: '分区创建者不能退出分区'
      });
    }

    const now = new Date();
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 更新成员状态为已退出
      await connection.execute(
        'UPDATE section_members SET status = 0, updated_at = ? WHERE id = ?',
        [now, member.id]
      );

      // 更新分区成员数量
      await connection.execute(
        'UPDATE sections SET member_count = member_count - 1, updated_at = ? WHERE id = ?',
        [now, sectionId]
      );

      await connection.commit();

      res.json({
        success: true,
        message: '成功退出分区'
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('退出分区错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// ====================================
// 分区帖子管理API
// ====================================

// 获取分区内的帖子列表
app.get('/api/v1/sections/:sectionId/posts', async (req, res) => {
  try {
    const { sectionId } = req.params;
    const { page = 1, limit = 20, sort = 'latest' } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    // 检查分区是否存在
    const [sectionRows] = await pool.execute(
      'SELECT * FROM sections WHERE id = ? AND status = 1',
      [sectionId]
    );

    if (sectionRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '分区不存在'
      });
    }

    let orderBy = 'sp.created_at DESC'; // 默认按时间排序
    if (sort === 'hot') {
      orderBy = 'sp.like_count DESC, sp.comment_count DESC, sp.created_at DESC';
    } else if (sort === 'top') {
      orderBy = 'sp.is_pinned DESC, sp.created_at DESC';
    }

    const [posts] = await pool.execute(
      `SELECT sp.*, u.nickname as author_name, u.avatar_url as author_avatar
       FROM section_posts sp 
       LEFT JOIN users u ON sp.user_id = u.id 
       WHERE sp.section_id = ? AND sp.status = 1 
       ORDER BY ${orderBy}
       LIMIT ? OFFSET ?`,
      [sectionId, parseInt(limit), offset]
    );

    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM section_posts WHERE section_id = ? AND status = 1',
      [sectionId]
    );

    res.json({
      success: true,
      data: {
        posts: posts,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: countResult[0].total,
          totalPages: Math.ceil(countResult[0].total / parseInt(limit))
        }
      }
    });
  } catch (error) {
    console.error('获取分区帖子列表错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 获取分区帖子详情
app.get('/api/v1/sections/:sectionId/posts/:postId', async (req, res) => {
  try {
    const { sectionId, postId } = req.params;

    const [postRows] = await pool.execute(
      `SELECT sp.*, u.nickname as author_name, u.avatar_url as author_avatar
       FROM section_posts sp 
       LEFT JOIN users u ON sp.user_id = u.id 
       WHERE sp.id = ? AND sp.section_id = ? AND sp.status = 1`,
      [postId, sectionId]
    );

    if (postRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '帖子不存在'
      });
    }

    const post = postRows[0];

    // 更新浏览次数
    await pool.execute(
      'UPDATE section_posts SET view_count = view_count + 1 WHERE id = ?',
      [postId]
    );

    // 获取帖子评论
    const [comments] = await pool.execute(
      `SELECT spc.*, u.nickname as author_name, u.avatar_url as author_avatar
       FROM section_post_comments spc 
       LEFT JOIN users u ON spc.user_id = u.id 
       WHERE spc.post_id = ? AND spc.status = 1 
       ORDER BY spc.created_at ASC`,
      [postId]
    );

    res.json({
      success: true,
      data: {
        post: post,
        comments: comments
      }
    });
  } catch (error) {
    console.error('获取帖子详情错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 在分区内发布帖子
app.post('/api/v1/sections/:sectionId/posts', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { sectionId } = req.params;
    const {
      title,
      content,
      content_type = 1,
      images = [],
      video_url,
      link_url,
      tags = [],
      is_anonymous = 0
    } = req.body;

    // 验证必填字段
    if (!title || !content) {
      return res.status(400).json({
        success: false,
        message: '帖子标题和内容不能为空'
      });
    }

    // 检查分区是否存在
    const [sectionRows] = await pool.execute(
      'SELECT * FROM sections WHERE id = ? AND status = 1',
      [sectionId]
    );

    if (sectionRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '分区不存在'
      });
    }

    const section = sectionRows[0];

    // 检查用户是否为分区成员
    const [memberRows] = await pool.execute(
      'SELECT * FROM section_members WHERE section_id = ? AND user_id = ? AND status = 1',
      [sectionId, userId]
    );

    if (memberRows.length === 0) {
      return res.status(403).json({
        success: false,
        message: '您不是该分区的成员，无法发帖'
      });
    }

    const member = memberRows[0];

    // 检查发帖权限
    if (section.post_permission === 2 && member.role === 1) { // 仅版主可发帖
      return res.status(403).json({
        success: false,
        message: '该分区仅允许版主发帖'
      });
    }

    const postId = uuidv4().replace(/-/g, '').substring(0, 32);
    const now = new Date();
    const postStatus = section.post_permission === 3 ? 2 : 1; // 需要审核 : 正常

    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 创建帖子
      await connection.execute(
        `INSERT INTO section_posts (
          id, section_id, user_id, title, content, content_type,
          images, video_url, link_url, tags, is_anonymous,
          status, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          postId, sectionId, userId, title, content, content_type,
          JSON.stringify(images), video_url, link_url, JSON.stringify(tags), is_anonymous,
          postStatus, now, now
        ]
      );

      // 更新分区帖子数量
      await connection.execute(
        'UPDATE sections SET post_count = post_count + 1, updated_at = ? WHERE id = ?',
        [now, sectionId]
      );

      // 更新用户积分和统计
      await connection.execute(
        'UPDATE user_profiles SET posts_count = posts_count + 1, total_points = total_points + 3 WHERE user_id = ?',
        [userId]
      );

      await connection.commit();

      // 获取创建的帖子信息
      const [newPost] = await connection.execute(
        `SELECT sp.*, u.nickname as author_name, u.avatar_url as author_avatar
         FROM section_posts sp 
         LEFT JOIN users u ON sp.user_id = u.id 
         WHERE sp.id = ?`,
        [postId]
      );

      res.status(201).json({
        success: true,
        message: postStatus === 2 ? '帖子已提交，等待审核' : '发布成功',
        data: newPost[0]
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('发布帖子错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 给分区帖子点赞/取消点赞
app.post('/api/v1/sections/:sectionId/posts/:postId/like', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { postId } = req.params;

    // 检查帖子是否存在
    const [postRows] = await pool.execute(
      'SELECT * FROM section_posts WHERE id = ? AND status = 1',
      [postId]
    );

    if (postRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '帖子不存在'
      });
    }

    // 检查是否已点赞
    const [existingLike] = await pool.execute(
      'SELECT * FROM section_post_likes WHERE post_id = ? AND user_id = ?',
      [postId, userId]
    );

    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      if (existingLike.length > 0) {
        // 取消点赞
        await connection.execute(
          'DELETE FROM section_post_likes WHERE post_id = ? AND user_id = ?',
          [postId, userId]
        );
        
        await connection.execute(
          'UPDATE section_posts SET like_count = like_count - 1 WHERE id = ?',
          [postId]
        );

        await connection.commit();

        res.json({
          success: true,
          message: '取消点赞成功',
          data: { liked: false }
        });
      } else {
        // 添加点赞
        await connection.execute(
          'INSERT INTO section_post_likes (post_id, user_id, created_at) VALUES (?, ?, ?)',
          [postId, userId, new Date()]
        );
        
        await connection.execute(
          'UPDATE section_posts SET like_count = like_count + 1 WHERE id = ?',
          [postId]
        );

        await connection.commit();

        res.json({
          success: true,
          message: '点赞成功',
          data: { liked: true }
        });
      }
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('点赞操作错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 评论分区帖子
app.post('/api/v1/sections/:sectionId/posts/:postId/comments', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { postId } = req.params;
    const { content, parent_id, reply_to_user_id, images = [], is_anonymous = 0 } = req.body;

    if (!content) {
      return res.status(400).json({
        success: false,
        message: '评论内容不能为空'
      });
    }

    // 检查帖子是否存在
    const [postRows] = await pool.execute(
      'SELECT * FROM section_posts WHERE id = ? AND status = 1',
      [postId]
    );

    if (postRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '帖子不存在'
      });
    }

    const commentId = uuidv4().replace(/-/g, '').substring(0, 32);
    const now = new Date();

    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 创建评论
      await connection.execute(
        `INSERT INTO section_post_comments (
          id, post_id, user_id, parent_id, reply_to_user_id, 
          content, images, is_anonymous, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          commentId, postId, userId, parent_id, reply_to_user_id,
          content, JSON.stringify(images), is_anonymous, now, now
        ]
      );

      // 更新帖子评论数
      await connection.execute(
        'UPDATE section_posts SET comment_count = comment_count + 1, last_comment_time = ? WHERE id = ?',
        [now, postId]
      );

      // 如果是回复，更新父评论回复数
      if (parent_id) {
        await connection.execute(
          'UPDATE section_post_comments SET reply_count = reply_count + 1 WHERE id = ?',
          [parent_id]
        );
      }

      // 更新用户积分
      await connection.execute(
        'UPDATE user_profiles SET comments_count = comments_count + 1, total_points = total_points + 1 WHERE user_id = ?',
        [userId]
      );

      await connection.commit();

      // 获取创建的评论信息
      const [newComment] = await connection.execute(
        `SELECT spc.*, u.nickname as author_name, u.avatar_url as author_avatar
         FROM section_post_comments spc 
         LEFT JOIN users u ON spc.user_id = u.id 
         WHERE spc.id = ?`,
        [commentId]
      );

      res.status(201).json({
        success: true,
        message: '评论成功',
        data: newComment[0]
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('评论错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// ====================================
// 签到功能API
// ====================================

// 获取用户签到状态
app.get('/api/v1/checkin/status', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0];
    const yesterdayStr = new Date(today.getTime() - 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // 检查今天是否已签到
    const [todayCheckin] = await pool.execute(
      'SELECT * FROM daily_checkins WHERE user_id = ? AND checkin_date = ?',
      [userId, todayStr]
    );

    // 获取连续签到天数
    let consecutiveDays = 0;
    if (todayCheckin.length > 0) {
      consecutiveDays = todayCheckin[0].consecutive_days;
    } else {
      // 检查昨天是否签到，以确定连续天数
      const [yesterdayCheckin] = await pool.execute(
        'SELECT consecutive_days FROM daily_checkins WHERE user_id = ? AND checkin_date = ?',
        [userId, yesterdayStr]
      );
      consecutiveDays = yesterdayCheckin.length > 0 ? yesterdayCheckin[0].consecutive_days : 0;
    }

    // 获取总签到天数
    const [totalResult] = await pool.execute(
      'SELECT COUNT(*) as total_days FROM daily_checkins WHERE user_id = ?',
      [userId]
    );

    // 计算今天和明天的签到积分
    const todayPoints = calculateCheckinPoints(consecutiveDays + (todayCheckin.length > 0 ? 0 : 1));
    const tomorrowPoints = calculateCheckinPoints(consecutiveDays + (todayCheckin.length > 0 ? 1 : 2));

    // 获取最后签到时间
    const [lastCheckin] = await pool.execute(
      'SELECT checkin_date FROM daily_checkins WHERE user_id = ? ORDER BY checkin_date DESC LIMIT 1',
      [userId]
    );

    const nextCheckinDate = new Date(today);
    nextCheckinDate.setDate(nextCheckinDate.getDate() + 1);
    nextCheckinDate.setHours(0, 0, 0, 0);

    res.json({
      success: true,
      data: {
        has_checked_in_today: todayCheckin.length > 0,
        consecutive_days: consecutiveDays,
        total_checkin_days: totalResult[0].total_days,
        today_points: todayPoints,
        tomorrow_points: tomorrowPoints,
        last_checkin_date: lastCheckin.length > 0 ? lastCheckin[0].checkin_date : null,
        next_checkin_date: nextCheckinDate.toISOString()
      }
    });

  } catch (error) {
    console.error('获取签到状态错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 执行签到
app.post('/api/v1/checkin', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0];
    const yesterdayStr = new Date(today.getTime() - 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // 检查今天是否已签到
    const [existingCheckin] = await pool.execute(
      'SELECT * FROM daily_checkins WHERE user_id = ? AND checkin_date = ?',
      [userId, todayStr]
    );

    if (existingCheckin.length > 0) {
      return res.status(400).json({
        success: false,
        message: '您今天已经签到过了'
      });
    }

    // 获取昨天的签到记录以计算连续天数
    const [yesterdayCheckin] = await pool.execute(
      'SELECT consecutive_days FROM daily_checkins WHERE user_id = ? AND checkin_date = ?',
      [userId, yesterdayStr]
    );

    const consecutiveDays = yesterdayCheckin.length > 0 ? yesterdayCheckin[0].consecutive_days + 1 : 1;
    const pointsEarned = calculateCheckinPoints(consecutiveDays);

    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      const checkinId = uuidv4().replace(/-/g, '').substring(0, 32);
      const pointsRecordId = uuidv4().replace(/-/g, '').substring(0, 32);

      // 插入签到记录
      await connection.execute(
        `INSERT INTO daily_checkins (
          id, user_id, checkin_date, consecutive_days, points_earned, created_at
        ) VALUES (?, ?, ?, ?, ?, ?)`,
        [checkinId, userId, todayStr, consecutiveDays, pointsEarned, today]
      );

      // 获取当前积分余额
      const [profileResult] = await connection.execute(
        'SELECT total_points FROM user_profiles WHERE user_id = ?',
        [userId]
      );

      const currentPoints = profileResult[0]?.total_points || 0;
      const newBalance = currentPoints + pointsEarned;

      // 更新用户积分
      await connection.execute(
        'UPDATE user_profiles SET total_points = ?, updated_at = ? WHERE user_id = ?',
        [newBalance, today, userId]
      );

      // 插入积分记录
      await connection.execute(
        `INSERT INTO points_records (
          id, user_id, type, source_type, source_id, points, balance_after,
          title, description, created_at
        ) VALUES (?, ?, 1, 'daily_checkin', ?, ?, ?, ?, ?, ?)`,
        [
          pointsRecordId, userId, checkinId, pointsEarned, newBalance,
          '每日签到奖励', `连续签到${consecutiveDays}天，获得${pointsEarned}积分`, today
        ]
      );

      await connection.commit();

      res.json({
        success: true,
        message: `签到成功！连续签到${consecutiveDays}天，获得${pointsEarned}积分`,
        data: {
          checkin_id: checkinId,
          consecutive_days: consecutiveDays,
          points_earned: pointsEarned,
          total_points: newBalance,
          checkin_date: todayStr
        }
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('签到错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 获取签到历史记录
app.get('/api/v1/checkin/history', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { page = 1, limit = 30 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    const [checkins] = await pool.execute(
      `SELECT * FROM daily_checkins
       WHERE user_id = ?
       ORDER BY checkin_date DESC
       LIMIT ? OFFSET ?`,
      [userId, parseInt(limit), offset]
    );

    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM daily_checkins WHERE user_id = ?',
      [userId]
    );

    res.json({
      success: true,
      data: {
        checkins: checkins,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: countResult[0].total,
          totalPages: Math.ceil(countResult[0].total / parseInt(limit))
        }
      }
    });

  } catch (error) {
    console.error('获取签到历史错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 获取签到规则配置
app.get('/api/v1/checkin/rules', async (req, res) => {
  try {
    const rules = [
      { day: 1, points: 5, description: '首次签到奖励', is_bonus: false },
      { day: 2, points: 6, description: '连续2天签到', is_bonus: false },
      { day: 3, points: 7, description: '连续3天签到', is_bonus: false },
      { day: 4, points: 8, description: '连续4天签到', is_bonus: false },
      { day: 5, points: 9, description: '连续5天签到', is_bonus: false },
      { day: 6, points: 10, description: '连续6天签到', is_bonus: false },
      { day: 7, points: 15, description: '连续7天签到奖励！', is_bonus: true },
      { day: 14, points: 25, description: '连续14天签到大奖！', is_bonus: true },
      { day: 30, points: 50, description: '连续30天签到超级大奖！', is_bonus: true }
    ];

    res.json({
      success: true,
      data: {
        rules: rules,
        description: '连续签到可获得更多积分奖励，中断签到后重新计算连续天数'
      }
    });

  } catch (error) {
    console.error('获取签到规则错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// ====================================
// 积分系统API
// ====================================

// 获取用户积分信息
app.get('/api/v1/points/profile', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0];
    const weekStart = new Date(today);
    weekStart.setDate(today.getDate() - today.getDay());
    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);

    // 获取用户积分信息
    const [profileResult] = await pool.execute(
      'SELECT total_points, level FROM user_profiles WHERE user_id = ?',
      [userId]
    );

    const profile = profileResult[0] || { total_points: 0, level: 1 };

    // 获取今日积分
    const [todayResult] = await pool.execute(
      `SELECT SUM(points) as today_earned FROM points_records
       WHERE user_id = ? AND type = 1 AND DATE(created_at) = ?`,
      [userId, todayStr]
    );

    // 获取本周积分
    const [weekResult] = await pool.execute(
      `SELECT SUM(points) as week_earned FROM points_records
       WHERE user_id = ? AND type = 1 AND created_at >= ?`,
      [userId, weekStart]
    );

    // 获取本月积分
    const [monthResult] = await pool.execute(
      `SELECT SUM(points) as month_earned FROM points_records
       WHERE user_id = ? AND type = 1 AND created_at >= ?`,
      [userId, monthStart]
    );

    // 计算等级进度
    const currentLevel = profile.level;
    const currentPoints = profile.total_points;
    const nextLevelPoints = (currentLevel * 100) + 100; // 简单的等级计算
    const levelProgress = Math.min(100, Math.floor((currentPoints % 100) / 100 * 100));

    res.json({
      success: true,
      data: {
        total_points: currentPoints,
        today_earned: todayResult[0]?.today_earned || 0,
        week_earned: weekResult[0]?.week_earned || 0,
        month_earned: monthResult[0]?.month_earned || 0,
        level: currentLevel,
        level_progress: levelProgress,
        next_level_points: nextLevelPoints
      }
    });

  } catch (error) {
    console.error('获取积分信息错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 获取积分历史记录
app.get('/api/v1/points/history', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { page = 1, limit = 20, type } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let whereClause = 'WHERE user_id = ?';
    let params = [userId];

    if (type === 'earned') {
      whereClause += ' AND type = 1';
    } else if (type === 'spent') {
      whereClause += ' AND type = 2';
    }

    const [records] = await pool.execute(
      `SELECT * FROM points_records
       ${whereClause}
       ORDER BY created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    const [countResult] = await pool.execute(
      `SELECT COUNT(*) as total FROM points_records ${whereClause}`,
      params
    );

    res.json({
      success: true,
      data: {
        records: records,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: countResult[0].total,
          totalPages: Math.ceil(countResult[0].total / parseInt(limit))
        }
      }
    });

  } catch (error) {
    console.error('获取积分历史错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 获取积分统计信息
app.get('/api/v1/points/statistics', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    // 获取总获得和总消费
    const [earnedResult] = await pool.execute(
      'SELECT SUM(points) as total_earned FROM points_records WHERE user_id = ? AND type = 1',
      [userId]
    );

    const [spentResult] = await pool.execute(
      'SELECT SUM(points) as total_spent FROM points_records WHERE user_id = ? AND type = 2',
      [userId]
    );

    // 获取当前余额
    const [balanceResult] = await pool.execute(
      'SELECT total_points FROM user_profiles WHERE user_id = ?',
      [userId]
    );

    // 按来源统计获得积分
    const [earnedBySource] = await pool.execute(
      `SELECT source_type, SUM(points) as total FROM points_records
       WHERE user_id = ? AND type = 1
       GROUP BY source_type`,
      [userId]
    );

    // 按来源统计消费积分
    const [spentBySource] = await pool.execute(
      `SELECT source_type, SUM(points) as total FROM points_records
       WHERE user_id = ? AND type = 2
       GROUP BY source_type`,
      [userId]
    );

    // 获取最近30天的每日积分
    const [dailyHistory] = await pool.execute(
      `SELECT
         DATE(created_at) as date,
         SUM(CASE WHEN type = 1 THEN points ELSE 0 END) as earned,
         SUM(CASE WHEN type = 2 THEN points ELSE 0 END) as spent
       FROM points_records
       WHERE user_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
       GROUP BY DATE(created_at)
       ORDER BY date DESC`,
      [userId]
    );

    const earnedBySourceMap = {};
    earnedBySource.forEach(item => {
      earnedBySourceMap[item.source_type] = item.total;
    });

    const spentBySourceMap = {};
    spentBySource.forEach(item => {
      spentBySourceMap[item.source_type] = item.total;
    });

    res.json({
      success: true,
      data: {
        total_earned: earnedResult[0]?.total_earned || 0,
        total_spent: spentResult[0]?.total_spent || 0,
        current_balance: balanceResult[0]?.total_points || 0,
        earned_by_source: earnedBySourceMap,
        spent_by_source: spentBySourceMap,
        daily_history: dailyHistory.map(item => ({
          date: item.date,
          earned: item.earned || 0,
          spent: item.spent || 0,
          balance: balanceResult[0]?.total_points || 0
        }))
      }
    });

  } catch (error) {
    console.error('获取积分统计错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 获取积分获取方式列表
app.get('/api/v1/points/earn-ways', async (req, res) => {
  try {
    const earnWays = [
      {
        source_type: 'daily_checkin',
        title: '每日签到',
        description: '每天签到可获得积分，连续签到奖励更多',
        points: '5-50',
        conditions: '每天只能签到一次',
        daily_limit: 1,
        is_active: true
      },
      {
        source_type: 'post',
        title: '发布帖子',
        description: '在社区发布优质内容',
        points: '3',
        conditions: '需要审核通过',
        daily_limit: null,
        is_active: true
      },
      {
        source_type: 'comment',
        title: '发表评论',
        description: '参与讨论，发表有价值的评论',
        points: '1',
        conditions: '评论内容不得违规',
        daily_limit: null,
        is_active: true
      },
      {
        source_type: 'task_completion',
        title: '完成任务',
        description: '完成校园相关任务获得奖励',
        points: '10-100',
        conditions: '任务需要审核',
        daily_limit: null,
        is_active: true
      }
    ];

    res.json({
      success: true,
      data: {
        earn_ways: earnWays
      }
    });

  } catch (error) {
    console.error('获取积分获取方式错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 手动添加积分记录（管理员功能）
app.post('/api/v1/points/add', authenticateToken, async (req, res) => {
  try {
    const {
      points,
      source_type,
      source_id,
      title,
      description
    } = req.body;

    if (!points || !source_type || !title) {
      return res.status(400).json({
        success: false,
        message: '积分数量、来源类型和标题不能为空'
      });
    }

    const userId = req.user.userId;
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      const recordId = uuidv4().replace(/-/g, '').substring(0, 32);
      const now = new Date();

      // 获取当前积分余额
      const [profileResult] = await connection.execute(
        'SELECT total_points FROM user_profiles WHERE user_id = ?',
        [userId]
      );

      const currentPoints = profileResult[0]?.total_points || 0;
      const newBalance = currentPoints + points;

      // 更新用户积分
      await connection.execute(
        'UPDATE user_profiles SET total_points = ?, updated_at = ? WHERE user_id = ?',
        [newBalance, now, userId]
      );

      // 插入积分记录
      await connection.execute(
        `INSERT INTO points_records (
          id, user_id, type, source_type, source_id, points, balance_after,
          title, description, created_at
        ) VALUES (?, ?, 1, ?, ?, ?, ?, ?, ?, ?)`,
        [
          recordId, userId, source_type, source_id, points, newBalance,
          title, description, now
        ]
      );

      await connection.commit();

      res.json({
        success: true,
        message: '积分添加成功',
        data: {
          record_id: recordId,
          points: points,
          total_points: newBalance
        }
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('添加积分记录错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

// 计算签到积分的辅助函数
function calculateCheckinPoints(consecutiveDays) {
  if (consecutiveDays >= 30) return 50;
  if (consecutiveDays >= 14) return 25;
  if (consecutiveDays >= 7) return 15;
  if (consecutiveDays >= 6) return 10;
  if (consecutiveDays >= 5) return 9;
  if (consecutiveDays >= 4) return 8;
  if (consecutiveDays >= 3) return 7;
  if (consecutiveDays >= 2) return 6;
  return 5; // 首次签到
}

// ====================================
// 任务发布功能API - 面向对象重构版
// ====================================

// 获取任务列表
app.get('/api/v1/tasks', (req, res) => taskController.getTasks(req, res));

// 获取任务详情
app.get('/api/v1/tasks/:taskId', (req, res) => taskController.getTaskDetail(req, res));

// 创建任务
app.post('/api/v1/tasks', authenticateToken, (req, res) => taskController.createTask(req, res));

// 参与任务
app.post('/api/v1/tasks/:taskId/join', authenticateToken, (req, res) => taskController.joinTask(req, res));

// 获取任务分类列表
app.get('/api/v1/task-categories', (req, res) => taskController.getTaskCategories(req, res));

// 启动服务器
app.listen(PORT, async () => {
  console.log(`🚀 校园圈API服务启动成功`);
  console.log(`📡 服务地址: http://localhost:${PORT}`);
  console.log(`🔗 健康检查: http://localhost:${PORT}/api/v1/health`);
  
  // 测试数据库连接
  await testConnection();
});

// 错误处理
process.on('unhandledRejection', (err) => {
  console.error('未处理的Promise拒绝:', err);
  process.exit(1);
});

process.on('uncaughtException', (err) => {
  console.error('未捕获的异常:', err);
  process.exit(1);
});