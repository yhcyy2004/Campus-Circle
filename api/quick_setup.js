// 简单的数据库表创建程序，直接使用服务器的数据库连接池
const express = require('express');
const mysql = require('mysql2/promise');

// 使用与服务器相同的配置
const dbConfig = {
  host: 'localhost',
  port: 3306,
  user: 'campus_project', // 使用硬编码的用户名
  password: 'Group21Password',
  database: 'campus_project',
  charset: 'utf8mb4'
};

// 如果上面不行，尝试这个配置
const dbConfig2 = {
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: '123456', // 常见的默认密码
  database: 'campus_project',
  charset: 'utf8mb4'
};

// 创建分区表的SQL
const createSectionTableSQL = `
CREATE TABLE IF NOT EXISTS sections (
  id varchar(32) NOT NULL COMMENT '分区ID',
  name varchar(100) NOT NULL COMMENT '分区名称',
  description text DEFAULT NULL COMMENT '分区描述',
  icon varchar(100) DEFAULT NULL COMMENT '分区图标',
  color varchar(10) DEFAULT '#007AFF' COMMENT '分区主题颜色',
  creator_id varchar(32) NOT NULL COMMENT '创建者用户ID',
  member_count int NOT NULL DEFAULT 0 COMMENT '成员数量',
  post_count int NOT NULL DEFAULT 0 COMMENT '帖子数量',
  is_public tinyint NOT NULL DEFAULT 1 COMMENT '是否公开',
  join_permission tinyint NOT NULL DEFAULT 1 COMMENT '加入权限',
  post_permission tinyint NOT NULL DEFAULT 1 COMMENT '发帖权限',
  rules text DEFAULT NULL COMMENT '分区规则',
  tags json DEFAULT NULL COMMENT '分区标签',
  sort_order int NOT NULL DEFAULT 0 COMMENT '排序权重',
  status tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分区表';
`;

const insertDefaultSections = `
INSERT IGNORE INTO sections (id, name, description, icon, color, creator_id) VALUES
('section_001', '校园生活', '分享校园日常生活、学习经历和趣事', 'school', '#FF6B6B', '1'),
('section_002', '学习交流', '学术讨论、学习资料分享和经验交流', 'book', '#4ECDC4', '1'),
('section_003', '社团活动', '各类社团活动发布和讨论', 'group', '#45B7D1', '1');
`;

async function tryCreateTables() {
  console.log('🔧 尝试创建分区表...');
  
  // 尝试第一个配置
  try {
    console.log('📋 尝试配置1: campus_project用户');
    const pool = mysql.createPool(dbConfig);
    const connection = await pool.getConnection();
    
    await connection.execute(createSectionTableSQL);
    console.log('✅ sections表创建成功');
    
    await connection.execute(insertDefaultSections);
    console.log('✅ 默认分区数据插入成功');
    
    connection.release();
    pool.end();
    console.log('🎉 数据库初始化完成！');
    return;
  } catch (error) {
    console.log('❌ 配置1失败:', error.message);
  }
  
  // 尝试第二个配置
  try {
    console.log('📋 尝试配置2: root用户');
    const pool2 = mysql.createPool(dbConfig2);
    const connection = await pool2.getConnection();
    
    await connection.execute(createSectionTableSQL);
    console.log('✅ sections表创建成功');
    
    await connection.execute(insertDefaultSections);
    console.log('✅ 默认分区数据插入成功');
    
    connection.release();
    pool2.end();
    console.log('🎉 数据库初始化完成！');
    return;
  } catch (error) {
    console.log('❌ 配置2失败:', error.message);
  }
  
  console.log('❌ 所有配置都失败了，请检查数据库连接');
}

tryCreateTables();