import mysql from 'mysql2/promise';
import { v4 as uuidv4 } from 'uuid';

/**
 * 任务数据模型
 */
export interface Task {
  id: string;
  categoryId: number;
  title: string;
  description: string;
  requirements: any[];
  rewardType: number;
  rewardValue: number;
  rewardDescription?: string;
  maxParticipants?: number;
  currentParticipants: number;
  difficultyLevel: number;
  estimatedTime?: number;
  startTime?: Date;
  endTime: Date;
  isRecurring: boolean;
  recurringType?: string;
  locationRequired: boolean;
  locationAddress?: string;
  locationRadius?: number;
  imageRequired: boolean;
  status: number;
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;

  // 关联数据
  creatorName?: string;
  creatorAvatar?: string;
  categoryName?: string;
  categoryColor?: string;
}

/**
 * 任务查询参数
 */
export interface TaskQueryParams {
  page: number;
  limit: number;
  categoryId?: number;
  status: number;
  sort: string;
  search?: string;
}

/**
 * 创建任务请求
 */
export interface CreateTaskRequest {
  title: string;
  description: string;
  categoryId: number;
  requirements: any[];
  rewardType: number;
  rewardValue: number;
  rewardDescription?: string;
  maxParticipants?: number;
  difficultyLevel: number;
  estimatedTime?: number;
  startTime?: Date;
  endTime: Date;
  isRecurring: boolean;
  recurringType?: string;
  locationRequired: boolean;
  locationAddress?: string;
  locationRadius?: number;
  imageRequired: boolean;
  createdBy: string;
}

/**
 * 任务分页结果
 */
export interface TaskListResult {
  tasks: Task[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

/**
 * 任务分类
 */
export interface TaskCategory {
  id: number;
  name: string;
  description: string;
  icon: string;
  color: string;
  sortOrder: number;
  status: number;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * 任务服务类 - 处理任务相关的业务逻辑
 * 遵循单一职责原则和开闭原则
 */
export class TaskService {
  private pool: mysql.Pool;

  constructor(pool: mysql.Pool) {
    this.pool = pool;
  }

  /**
   * 获取任务列表
   */
  async getTasks(params: TaskQueryParams): Promise<TaskListResult> {
    const { page, limit, categoryId, status, sort, search } = params;
    const offset = (page - 1) * limit;

    let whereClause = 'WHERE t.status = ?';
    let queryParams: any[] = [status];

    // 分类筛选
    if (categoryId) {
      whereClause += ' AND t.category_id = ?';
      queryParams.push(categoryId);
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

    const [tasks] = await this.pool.execute(sql, [...queryParams, limit, offset]) as [any[], any];

    const countSql = `SELECT COUNT(*) as total FROM tasks t ${whereClause}`;
    const [countResult] = await this.pool.execute(countSql, queryParams) as [any[], any];

    return {
      tasks: tasks.map(this.mapRowToTask),
      pagination: {
        page,
        limit,
        total: countResult[0].total,
        totalPages: Math.ceil(countResult[0].total / limit)
      }
    };
  }

  /**
   * 获取任务详情
   */
  async getTaskDetail(taskId: string): Promise<{ task: Task; participants: any[] } | null> {
    const sql = `
      SELECT t.*, u.nickname as creator_name, u.avatar_url as creator_avatar,
             tc.name as category_name, tc.color as category_color
      FROM tasks t
      LEFT JOIN users u ON t.created_by = u.id
      LEFT JOIN task_categories tc ON t.category_id = tc.id
      WHERE t.id = ? AND t.status != 0
    `;

    const [taskRows] = await this.pool.execute(sql, [taskId]) as [any[], any];

    if (taskRows.length === 0) {
      return null;
    }

    const task = this.mapRowToTask(taskRows[0]);

    // 获取参与者信息
    const participantsSql = `
      SELECT ut.*, u.nickname as user_name, u.avatar_url as user_avatar
      FROM user_tasks ut
      LEFT JOIN users u ON ut.user_id = u.id
      WHERE ut.task_id = ? AND ut.status != 0
      ORDER BY ut.started_at DESC
    `;

    const [participants] = await this.pool.execute(participantsSql, [taskId]) as [any[], any];

    return {
      task,
      participants
    };
  }

  /**
   * 创建任务
   */
  async createTask(request: CreateTaskRequest): Promise<Task> {
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

      await connection.execute(insertSql, [
        taskId, request.categoryId, request.title, request.description,
        JSON.stringify(request.requirements), request.rewardType, request.rewardValue,
        request.rewardDescription, request.maxParticipants, request.difficultyLevel,
        request.estimatedTime, request.startTime, request.endTime,
        request.isRecurring ? 1 : 0, request.recurringType, request.locationRequired ? 1 : 0,
        request.locationAddress, request.locationRadius, request.imageRequired ? 1 : 0,
        request.createdBy, now, now
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
      `, [taskId]) as [any[], any];

      return this.mapRowToTask(newTaskRows[0]);

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
  async joinTask(taskId: string, userId: string): Promise<any> {
    // 验证任务和用户权限
    const task = await this.validateTaskForJoining(taskId, userId);

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
  async getTaskCategories(): Promise<TaskCategory[]> {
    const [categories] = await this.pool.execute(`
      SELECT * FROM task_categories WHERE status = 1 ORDER BY sort_order ASC, created_at DESC
    `) as [any[], any];

    return categories.map(row => ({
      id: row.id,
      name: row.name,
      description: row.description,
      icon: row.icon,
      color: row.color,
      sortOrder: row.sort_order,
      status: row.status,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));
  }

  /**
   * 验证用户积分
   */
  private async validateUserPoints(userId: string, rewardType: number, rewardValue: number): Promise<void> {
    if (rewardType !== 1) return; // 非积分奖励不需要验证

    const [userProfile] = await this.pool.execute(
      'SELECT total_points FROM user_profiles WHERE user_id = ?',
      [userId]
    ) as [any[], any];

    const userPoints = userProfile[0]?.total_points || 0;
    const publishCost = 5;

    if (userPoints < rewardValue + publishCost) {
      throw new Error(`积分不足，需要 ${rewardValue + publishCost} 积分，当前只有 ${userPoints} 积分`);
    }
  }

  /**
   * 验证任务参与条件
   */
  private async validateTaskForJoining(taskId: string, userId: string): Promise<Task> {
    const [taskRows] = await this.pool.execute(
      'SELECT * FROM tasks WHERE id = ? AND status = 1',
      [taskId]
    ) as [any[], any];

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
    ) as [any[], any];

    if (existing.length > 0) {
      throw new Error('您已经参与过这个任务');
    }

    return this.mapRowToTask(task);
  }

  /**
   * 处理任务创建的积分逻辑
   */
  private async processPointsForTaskCreation(connection: mysql.PoolConnection, userId: string, taskId: string): Promise<void> {
    const publishCost = 5;

    const [userProfile] = await connection.execute(
      'SELECT total_points FROM user_profiles WHERE user_id = ?',
      [userId]
    ) as [any[], any];

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

  /**
   * 将数据库行映射为Task对象
   */
  private mapRowToTask(row: any): Task {
    return {
      id: row.id,
      categoryId: row.category_id,
      title: row.title,
      description: row.description,
      requirements: row.requirements ? JSON.parse(row.requirements) : [],
      rewardType: row.reward_type,
      rewardValue: row.reward_value,
      rewardDescription: row.reward_description,
      maxParticipants: row.max_participants,
      currentParticipants: row.current_participants,
      difficultyLevel: row.difficulty_level,
      estimatedTime: row.estimated_time,
      startTime: row.start_time,
      endTime: row.end_time,
      isRecurring: row.is_recurring === 1,
      recurringType: row.recurring_type,
      locationRequired: row.location_required === 1,
      locationAddress: row.location_address,
      locationRadius: row.location_radius,
      imageRequired: row.image_required === 1,
      status: row.status,
      createdBy: row.created_by,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      creatorName: row.creator_name,
      creatorAvatar: row.creator_avatar,
      categoryName: row.category_name,
      categoryColor: row.category_color
    };
  }
}