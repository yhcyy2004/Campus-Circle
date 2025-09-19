const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

/**
 * 任务服务类 - 面向对象重构版本
 * 遵循单一职责原则和开闭原则
 */
class TaskService {
  constructor(pool) {
    this.pool = pool;
  }

  /**
   * 获取任务列表
   */
  async getTasks(params) {
    const { page = 1, limit = 20, categoryId, status = 1, sort = 'latest', search } = params;

    // 确保 page 和 limit 是整数
    const pageInt = parseInt(page);
    const limitInt = parseInt(limit);
    const offsetInt = (pageInt - 1) * limitInt;

    let whereClause = 'WHERE t.status = ?';
    let queryParams = [parseInt(status)];

    // 分类筛选
    if (categoryId) {
      whereClause += ' AND t.category_id = ?';
      queryParams.push(parseInt(categoryId));
    }

    // 搜索功能
    if (search) {
      whereClause += ' AND (t.title LIKE ? OR t.description LIKE ?)';
      const searchTerm = `%${search}%`;
      queryParams.push(searchTerm, searchTerm);
    }

    // 排序逻辑
    let orderBy = 't.created_at DESC';
    if (sort === 'hot') {
      orderBy = 't.current_participants DESC, t.created_at DESC';
    } else if (sort === 'urgent') {
      orderBy = 't.end_time ASC, t.created_at DESC';
    } else if (sort === 'reward') {
      orderBy = 't.reward_value DESC, t.created_at DESC';
    }

    const sql = `
      SELECT t.*, u.nickname as creator_name, u.avatar_url as creator_avatar,
             tc.name as category_name, tc.color as category_color
      FROM tasks t
      LEFT JOIN users u ON t.created_by = u.id
      LEFT JOIN task_categories tc ON t.category_id = tc.id
      ${whereClause}
      ORDER BY ${orderBy}
      LIMIT ? OFFSET ?
    `;

    let tasks;
    try {
      [tasks] = await this.pool.query(sql, [...queryParams, limitInt, offsetInt]);
    } catch (error) {
      console.log('Query failed, trying without parameters');
      const allParams = [...queryParams, limitInt, offsetInt];
      let paramIndex = 0;
      const finalSql = sql.replace(/\?/g, () => {
        const value = allParams[paramIndex++];
        return typeof value === 'string' ? `'${value}'` : value;
      });
      [tasks] = await this.pool.query(finalSql);
    }

    const countSql = `SELECT COUNT(*) as total FROM tasks t ${whereClause}`;
    const [countResult] = await this.pool.query(countSql, queryParams);

    return {
      tasks,
      pagination: {
        page: pageInt,
        limit: limitInt,
        total: countResult[0].total,
        totalPages: Math.ceil(countResult[0].total / limitInt)
      }
    };
  }

  /**
   * 获取任务详情
   */
  async getTaskDetail(taskId) {
    const sql = `
      SELECT t.*, u.nickname as creator_name, u.avatar_url as creator_avatar,
             tc.name as category_name, tc.color as category_color
      FROM tasks t
      LEFT JOIN users u ON t.created_by = u.id
      LEFT JOIN task_categories tc ON t.category_id = tc.id
      WHERE t.id = ? AND t.status != 0
    `;

    const [taskRows] = await this.pool.execute(sql, [taskId]);

    if (taskRows.length === 0) {
      return null;
    }

    const task = taskRows[0];

    // 获取参与者信息
    const participantsSql = `
      SELECT ut.*, u.nickname as user_name, u.avatar_url as user_avatar
      FROM user_tasks ut
      LEFT JOIN users u ON ut.user_id = u.id
      WHERE ut.task_id = ? AND ut.status != 0
      ORDER BY ut.started_at DESC
    `;

    const [participants] = await this.pool.execute(participantsSql, [taskId]);

    return { task, participants };
  }

  /**
   * 创建任务
   */
  async createTask(request) {
    // 验证必填字段
    this.validateCreateTaskRequest(request);

    const taskId = uuidv4().replace(/-/g, '').substring(0, 32);
    const now = new Date();

    // 检查用户积分
    await this.validateUserPoints(request.createdBy, request.rewardType, request.rewardValue);

    const connection = await this.pool.getConnection();
    await connection.beginTransaction();

    try {
      // 创建任务
      const insertSql = `
        INSERT INTO tasks (
          id, category_id, title, description, requirements, reward_type, reward_value,
          reward_description, max_participants, difficulty_level, estimated_time,
          start_time, end_time, is_recurring, recurring_type, location_required,
          location_address, location_radius, image_required, status, created_by, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)
      `;

      // 转换日期格式为MySQL兼容格式
      const formatDateForMySQL = (dateString) => {
        if (!dateString) return null;
        const date = new Date(dateString);
        return date.toISOString().slice(0, 19).replace('T', ' ');
      };

      await connection.execute(insertSql, [
        taskId,
        request.categoryId || 1,
        request.title,
        request.description,
        JSON.stringify(request.requirements || []),
        request.rewardType || 1,
        request.rewardValue || 0,
        request.rewardDescription || null,
        request.maxParticipants || null,
        request.difficultyLevel || 1,
        request.estimatedTime || null,
        formatDateForMySQL(request.startTime),
        formatDateForMySQL(request.endTime),
        request.isRecurring ? 1 : 0,
        request.recurringType || null,
        request.locationRequired ? 1 : 0,
        request.locationAddress || null,
        request.locationRadius || null,
        request.imageRequired ? 1 : 0,
        request.createdBy,
        now,
        now
      ]);

      // 如果是积分奖励，处理积分逻辑
      if (request.rewardType === 1) {
        await this.processPointsForTaskCreation(connection, request.createdBy, taskId);
      }

      await connection.commit();

      // 获取创建的任务
      const [newTaskRows] = await connection.execute(`
        SELECT t.*, u.nickname as creator_name, u.avatar_url as creator_avatar,
               tc.name as category_name, tc.color as category_color
        FROM tasks t
        LEFT JOIN users u ON t.created_by = u.id
        LEFT JOIN task_categories tc ON t.category_id = tc.id
        WHERE t.id = ?
      `, [taskId]);

      return newTaskRows[0];

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * 参与任务
   */
  async joinTask(taskId, userId) {
    // 验证任务和用户权限
    await this.validateTaskForJoining(taskId, userId);

    const userTaskId = uuidv4().replace(/-/g, '').substring(0, 32);
    const now = new Date();

    const connection = await this.pool.getConnection();
    await connection.beginTransaction();

    try {
      // 创建参与记录
      await connection.execute(`
        INSERT INTO user_tasks (
          id, task_id, user_id, status, progress, started_at, updated_at
        ) VALUES (?, ?, ?, 1, 0, ?, ?)
      `, [userTaskId, taskId, userId, now, now]);

      // 更新任务参与人数
      await connection.execute(`
        UPDATE tasks SET current_participants = current_participants + 1, updated_at = ? WHERE id = ?
      `, [now, taskId]);

      await connection.commit();

      return { id: userTaskId, taskId, userId, status: 1 };

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * 获取任务分类
   */
  async getTaskCategories() {
    const [categories] = await this.pool.execute(`
      SELECT * FROM task_categories WHERE status = 1 ORDER BY sort_order ASC, created_at DESC
    `);

    return categories;
  }

  /**
   * 验证创建任务请求
   */
  validateCreateTaskRequest(request) {
    if (!request.title || request.title.trim().length === 0) {
      throw new Error('任务标题不能为空');
    }

    if (request.title.length > 200) {
      throw new Error('任务标题不能超过200个字符');
    }

    if (!request.description || request.description.trim().length === 0) {
      throw new Error('任务描述不能为空');
    }

    if (!request.endTime) {
      throw new Error('截止时间不能为空');
    }

    const endTime = new Date(request.endTime);
    if (endTime <= new Date()) {
      throw new Error('截止时间必须晚于当前时间');
    }

    if (request.rewardValue && request.rewardValue < 0) {
      throw new Error('奖励值不能为负数');
    }
  }

  /**
   * 验证用户积分
   */
  async validateUserPoints(userId, rewardType, rewardValue) {
    if (rewardType !== 1) return; // 非积分奖励不需要验证

    const [userProfile] = await this.pool.execute(
      'SELECT total_points FROM user_profiles WHERE user_id = ?',
      [userId]
    );

    const userPoints = userProfile[0]?.total_points || 0;
    const publishCost = 5;

    if (userPoints < rewardValue + publishCost) {
      throw new Error(`积分不足，需要 ${rewardValue + publishCost} 积分，当前只有 ${userPoints} 积分`);
    }
  }

  /**
   * 验证任务参与条件
   */
  async validateTaskForJoining(taskId, userId) {
    const [taskRows] = await this.pool.execute(
      'SELECT * FROM tasks WHERE id = ? AND status = 1',
      [taskId]
    );

    if (taskRows.length === 0) {
      throw new Error('任务不存在或已关闭');
    }

    const task = taskRows[0];

    if (task.created_by === userId) {
      throw new Error('不能参与自己发布的任务');
    }

    if (task.end_time && new Date(task.end_time) <= new Date()) {
      throw new Error('任务已过期');
    }

    // 检查是否已经参与过
    const [existing] = await this.pool.execute(
      'SELECT * FROM user_tasks WHERE task_id = ? AND user_id = ? AND status != 0',
      [taskId, userId]
    );

    if (existing.length > 0) {
      throw new Error('您已经参与过这个任务');
    }

    return task;
  }

  /**
   * 处理任务创建的积分逻辑
   */
  async processPointsForTaskCreation(connection, userId, taskId) {
    const publishCost = 5;

    const [userProfile] = await connection.execute(
      'SELECT total_points FROM user_profiles WHERE user_id = ?',
      [userId]
    );

    const currentPoints = userProfile[0]?.total_points || 0;
    const newBalance = currentPoints - publishCost;

    // 更新用户积分
    await connection.execute(
      'UPDATE user_profiles SET total_points = ?, updated_at = ? WHERE user_id = ?',
      [newBalance, new Date(), userId]
    );

    // 添加积分记录
    const pointsRecordId = uuidv4().replace(/-/g, '').substring(0, 32);
    await connection.execute(`
      INSERT INTO points_records (
        id, user_id, type, source_type, source_id, points, balance_after,
        title, description, created_at
      ) VALUES (?, ?, 2, 'task_publish', ?, ?, ?, ?, ?, ?)
    `, [
      pointsRecordId, userId, taskId, publishCost, newBalance,
      '发布任务', `发布任务消耗${publishCost}积分`, new Date()
    ]);
  }
}

/**
 * 任务控制器类
 * 处理HTTP请求/响应
 */
class TaskController {
  constructor(taskService) {
    this.taskService = taskService;
  }

  /**
   * 获取任务列表
   */
  async getTasks(req, res) {
    try {
      const params = {
        page: parseInt(req.query.page) || 1,
        limit: parseInt(req.query.limit) || 20,
        categoryId: req.query.category_id ? parseInt(req.query.category_id) : undefined,
        status: parseInt(req.query.status) || 1,
        sort: req.query.sort || 'latest',
        search: req.query.search
      };

      const result = await this.taskService.getTasks(params);

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      console.error('获取任务列表错误:', error);
      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 获取任务详情
   */
  async getTaskDetail(req, res) {
    try {
      const taskId = req.params.taskId;
      const result = await this.taskService.getTaskDetail(taskId);

      if (!result) {
        return res.status(404).json({
          success: false,
          message: '任务不存在'
        });
      }

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      console.error('获取任务详情错误:', error);
      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 创建任务
   */
  async createTask(req, res) {
    try {
      const userId = req.user.userId;
      const request = {
        title: req.body.title,
        description: req.body.description,
        categoryId: req.body.category_id || 1,
        requirements: req.body.requirements || [],
        rewardType: req.body.reward_type || 1,
        rewardValue: req.body.reward_value || 10,
        rewardDescription: req.body.reward_description,
        maxParticipants: req.body.max_participants,
        difficultyLevel: req.body.difficulty_level || 1,
        estimatedTime: req.body.estimated_time,
        startTime: req.body.start_time,
        endTime: req.body.end_time,
        isRecurring: req.body.is_recurring || false,
        recurringType: req.body.recurring_type,
        locationRequired: req.body.location_required || false,
        locationAddress: req.body.location_address,
        locationRadius: req.body.location_radius,
        imageRequired: req.body.image_required || false,
        createdBy: userId
      };

      const result = await this.taskService.createTask(request);

      res.status(201).json({
        success: true,
        message: '任务发布成功',
        data: result
      });
    } catch (error) {
      console.error('创建任务错误:', error);

      // 业务逻辑错误
      if (error.message.includes('积分不足') || error.message.includes('不能为空') || error.message.includes('必须晚于')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 参与任务
   */
  async joinTask(req, res) {
    try {
      const userId = req.user.userId;
      const taskId = req.params.taskId;

      const result = await this.taskService.joinTask(taskId, userId);

      res.status(201).json({
        success: true,
        message: '参与任务成功',
        data: result
      });
    } catch (error) {
      console.error('参与任务错误:', error);

      // 业务逻辑错误
      if (error.message.includes('不存在') || error.message.includes('不能参与') || error.message.includes('已过期') || error.message.includes('已经参与')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 获取任务分类
   */
  async getTaskCategories(req, res) {
    try {
      const categories = await this.taskService.getTaskCategories();

      res.json({
        success: true,
        data: { categories }
      });
    } catch (error) {
      console.error('获取任务分类错误:', error);
      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }
}

module.exports = { TaskService, TaskController };