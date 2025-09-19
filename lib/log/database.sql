-- ====================================
-- 郑州轻工业大学校园圈互动平台数据库
-- 数据库编码: utf8mb4 (支持emoji和中文)
-- 排序规则: utf8mb4_general_ci
-- ====================================

-- 设置数据库字符集
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 用户主表
CREATE TABLE `users` (
                         `id` varchar(32) NOT NULL COMMENT '用户唯一标识ID',
                         `student_number` varchar(20) NOT NULL COMMENT '学号',
                         `email` varchar(100) NOT NULL COMMENT '邮箱',
                         `password` varchar(255) NOT NULL COMMENT '密码(加密后)',
                         `nickname` varchar(50) NOT NULL COMMENT '昵称',
                         `real_name` varchar(30) NOT NULL COMMENT '真实姓名',
                         `major` varchar(100) NOT NULL COMMENT '专业',
                         `grade` int NOT NULL COMMENT '年级',
                         `avatar_url` varchar(500) DEFAULT NULL COMMENT '头像URL',
                         `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
                         `status` tinyint NOT NULL DEFAULT '1' COMMENT '账号状态:0-禁用,1-正常,2-待验证',
                         `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
                         `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                         `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                         PRIMARY KEY (`id`),
                         UNIQUE KEY `uk_student_number` (`student_number`),
                         UNIQUE KEY `uk_email` (`email`),
                         KEY `idx_grade` (`grade`),
                         KEY `idx_major` (`major`),
                         KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户主表';

-- 先插入测试用户（真实姓名默认与昵称一致，专业/年级/学号/邮箱为注册时填写值）
INSERT INTO `users` (`id`, `student_number`, `email`, `password`, `nickname`, `real_name`, `major`, `grade`, `status`)
VALUES
    ('1', '20230001', 'test1@zzuli.edu.cn', '17406e11c3af2ba6ebb2bc008b892892b73fc3e260eb6ef202794a8e507d0c1e', '校园达人1', '校园达人1', '计算机科学与技术', 2023, 1),
    ('2', '20230002', 'test2@zzuli.edu.cn', '9f6567a6d8a2eae61a1139b193c981dd6fcc2399f07760dec8de3d469decf5aa', '校园达人2', '校园达人2', '软件工程', 2023, 1);

-- 2. 用户详细信息表
CREATE TABLE `user_profiles` (
                                 `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                 `bio` text DEFAULT NULL COMMENT '个人简介',
                                 `interests` json DEFAULT NULL COMMENT '兴趣爱好(JSON数组)',
                                 `location` varchar(100) DEFAULT NULL COMMENT '位置信息',
                                 `social_links` json DEFAULT NULL COMMENT '社交链接(JSON对象)',
                                 `privacy_settings` json DEFAULT NULL COMMENT '隐私设置(JSON对象)',
                                 `total_points` int NOT NULL DEFAULT '0' COMMENT '总积分',
                                 `level` int NOT NULL DEFAULT '1' COMMENT '用户等级',
                                 `posts_count` int NOT NULL DEFAULT '0' COMMENT '发帖数',
                                 `comments_count` int NOT NULL DEFAULT '0' COMMENT '评论数',
                                 `likes_received` int NOT NULL DEFAULT '0' COMMENT '获得点赞数',
                                 `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                 `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                 PRIMARY KEY (`user_id`),
                                 CONSTRAINT `fk_user_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户详细信息表';

-- 插入用户详情（所有统计字段默认0，等级默认1=初级）
INSERT INTO `user_profiles` (`user_id`, `total_points`, `level`, `posts_count`, `comments_count`, `likes_received`)
VALUES
    ('1', 0, 1, 0, 0, 0),
    ('2', 0, 1, 0, 0, 0);

-- 3. 帖子分类表
CREATE TABLE `post_categories` (
                                   `id` int AUTO_INCREMENT NOT NULL COMMENT '分类ID',
                                   `name` varchar(50) NOT NULL COMMENT '分类名称',
                                   `description` varchar(200) DEFAULT NULL COMMENT '分类描述',
                                   `color` varchar(10) DEFAULT '#007AFF' COMMENT '分类颜色',
                                   `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序权重',
                                   `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-禁用,1-启用',
                                   `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                   `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                   PRIMARY KEY (`id`),
                                   KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='帖子分类表';

-- 4. 帖子主表
CREATE TABLE `posts` (
                         `id` varchar(32) NOT NULL COMMENT '帖子ID',
                         `user_id` varchar(32) NOT NULL COMMENT '发布用户ID',
                         `category_id` int DEFAULT NULL COMMENT '分类ID',
                         `title` varchar(200) NOT NULL COMMENT '帖子标题',
                         `content` text NOT NULL COMMENT '帖子内容',
                         `images` json DEFAULT NULL COMMENT '图片URLs(JSON数组)',
                         `location` varchar(100) DEFAULT NULL COMMENT '位置信息',
                         `is_anonymous` tinyint NOT NULL DEFAULT '0' COMMENT '是否匿名:0-否,1-是',
                         `is_top` tinyint NOT NULL DEFAULT '0' COMMENT '是否置顶:0-否,1-是',
                         `is_hot` tinyint NOT NULL DEFAULT '0' COMMENT '是否热门:0-否,1-是',
                         `view_count` int NOT NULL DEFAULT '0' COMMENT '浏览次数',
                         `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞数',
                         `comment_count` int NOT NULL DEFAULT '0' COMMENT '评论数',
                         `share_count` int NOT NULL DEFAULT '0' COMMENT '分享次数',
                         `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-删除,1-正常,2-审核中,3-审核失败',
                         `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                         `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                         PRIMARY KEY (`id`),
                         KEY `idx_user_id` (`user_id`),
                         KEY `idx_category_id` (`category_id`),
                         KEY `idx_status` (`status`),
                         KEY `idx_created_at` (`created_at`),
                         KEY `idx_hot_top` (`is_hot`, `is_top`),
                         CONSTRAINT `fk_posts_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                         CONSTRAINT `fk_posts_category_id` FOREIGN KEY (`category_id`) REFERENCES `post_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='帖子主表';

-- 5. 帖子点赞表
CREATE TABLE `post_likes` (
                              `id` bigint AUTO_INCREMENT NOT NULL COMMENT '点赞记录ID',
                              `post_id` varchar(32) NOT NULL COMMENT '帖子ID',
                              `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                              `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
                              PRIMARY KEY (`id`),
                              UNIQUE KEY `uk_post_user` (`post_id`, `user_id`),
                              KEY `idx_user_id` (`user_id`),
                              CONSTRAINT `fk_post_likes_post_id` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
                              CONSTRAINT `fk_post_likes_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='帖子点赞表';

-- 6. 帖子评论表
CREATE TABLE `post_comments` (
                                 `id` varchar(32) NOT NULL COMMENT '评论ID',
                                 `post_id` varchar(32) NOT NULL COMMENT '帖子ID',
                                 `user_id` varchar(32) NOT NULL COMMENT '评论用户ID',
                                 `parent_id` varchar(32) DEFAULT NULL COMMENT '父评论ID(回复)',
                                 `reply_to_user_id` varchar(32) DEFAULT NULL COMMENT '回复目标用户ID',
                                 `content` text NOT NULL COMMENT '评论内容',
                                 `images` json DEFAULT NULL COMMENT '评论图片URLs(JSON数组)',
                                 `is_anonymous` tinyint NOT NULL DEFAULT '0' COMMENT '是否匿名:0-否,1-是',
                                 `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞数',
                                 `reply_count` int NOT NULL DEFAULT '0' COMMENT '回复数',
                                 `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-删除,1-正常,2-审核中',
                                 `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                 `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                 PRIMARY KEY (`id`),
                                 KEY `idx_post_id` (`post_id`),
                                 KEY `idx_user_id` (`user_id`),
                                 KEY `idx_parent_id` (`parent_id`),
                                 KEY `idx_created_at` (`created_at`),
                                 CONSTRAINT `fk_post_comments_post_id` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `fk_post_comments_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `fk_post_comments_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='帖子评论表';

-- 7. 评论点赞表
CREATE TABLE `comment_likes` (
                                 `id` bigint AUTO_INCREMENT NOT NULL COMMENT '点赞记录ID',
                                 `comment_id` varchar(32) NOT NULL COMMENT '评论ID',
                                 `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                 `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
                                 PRIMARY KEY (`id`),
                                 UNIQUE KEY `uk_comment_user` (`comment_id`, `user_id`),
                                 KEY `idx_user_id` (`user_id`),
                                 CONSTRAINT `fk_comment_likes_comment_id` FOREIGN KEY (`comment_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `fk_comment_likes_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='评论点赞表';

-- 8. 任务分类表
CREATE TABLE `task_categories` (
                                   `id` int AUTO_INCREMENT NOT NULL COMMENT '任务分类ID',
                                   `name` varchar(50) NOT NULL COMMENT '分类名称',
                                   `description` varchar(200) DEFAULT NULL COMMENT '分类描述',
                                   `icon` varchar(100) DEFAULT NULL COMMENT '分类图标',
                                   `color` varchar(10) DEFAULT '#007AFF' COMMENT '分类颜色',
                                   `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序权重',
                                   `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-禁用,1-启用',
                                   `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                   `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                   PRIMARY KEY (`id`),
                                   KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='任务分类表';

-- 9. 任务主表
CREATE TABLE `tasks` (
                         `id` varchar(32) NOT NULL COMMENT '任务ID',
                         `category_id` int DEFAULT NULL COMMENT '分类ID',
                         `title` varchar(200) NOT NULL COMMENT '任务标题',
                         `description` text NOT NULL COMMENT '任务描述',
                         `requirements` json DEFAULT NULL COMMENT '任务要求(JSON数组)',
                         `reward_type` tinyint NOT NULL DEFAULT '1' COMMENT '奖励类型:1-积分,2-实物,3-优惠券',
                         `reward_value` int NOT NULL DEFAULT '0' COMMENT '奖励数值(积分或价值)',
                         `reward_description` varchar(500) DEFAULT NULL COMMENT '奖励说明',
                         `max_participants` int DEFAULT NULL COMMENT '最大参与人数(NULL表示无限制)',
                         `current_participants` int NOT NULL DEFAULT '0' COMMENT '当前参与人数',
                         `difficulty_level` tinyint NOT NULL DEFAULT '1' COMMENT '难度等级:1-简单,2-普通,3-困难',
                         `estimated_time` int DEFAULT NULL COMMENT '预估完成时间(分钟)',
                         `start_time` datetime DEFAULT NULL COMMENT '任务开始时间',
                         `end_time` datetime DEFAULT NULL COMMENT '任务结束时间',
                         `is_recurring` tinyint NOT NULL DEFAULT '0' COMMENT '是否周期性任务:0-否,1-是',
                         `recurring_type` varchar(20) DEFAULT NULL COMMENT '周期类型:daily,weekly,monthly',
                         `location_required` tinyint NOT NULL DEFAULT '0' COMMENT '是否需要位置验证:0-否,1-是',
                         `location_address` varchar(200) DEFAULT NULL COMMENT '指定位置地址',
                         `location_radius` int DEFAULT NULL COMMENT '位置验证半径(米)',
                         `image_required` tinyint NOT NULL DEFAULT '0' COMMENT '是否需要上传图片:0-否,1-是',
                         `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-草稿,1-发布中,2-已暂停,3-已结束',
                         `created_by` varchar(32) NOT NULL COMMENT '创建者用户ID',
                         `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                         `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                         PRIMARY KEY (`id`),
                         KEY `idx_category_id` (`category_id`),
                         KEY `idx_status` (`status`),
                         KEY `idx_created_by` (`created_by`),
                         KEY `idx_start_end_time` (`start_time`, `end_time`),
                         KEY `idx_difficulty` (`difficulty_level`),
                         CONSTRAINT `fk_tasks_category_id` FOREIGN KEY (`category_id`) REFERENCES `task_categories` (`id`) ON DELETE SET NULL,
                         CONSTRAINT `fk_tasks_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='任务主表';

-- 10. 用户任务参与记录表
CREATE TABLE `user_tasks` (
                              `id` varchar(32) NOT NULL COMMENT '参与记录ID',
                              `task_id` varchar(32) NOT NULL COMMENT '任务ID',
                              `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                              `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:1-进行中,2-已完成,3-已放弃,4-审核中,5-审核失败',
                              `progress` int NOT NULL DEFAULT '0' COMMENT '完成进度(百分比)',
                              `submission_content` text DEFAULT NULL COMMENT '提交内容',
                              `submission_images` json DEFAULT NULL COMMENT '提交图片URLs(JSON数组)',
                              `submission_location` json DEFAULT NULL COMMENT '提交位置信息(JSON对象)',
                              `submitted_at` datetime DEFAULT NULL COMMENT '提交时间',
                              `completed_at` datetime DEFAULT NULL COMMENT '完成时间',
                              `review_status` tinyint DEFAULT NULL COMMENT '审核状态:1-待审核,2-审核通过,3-审核拒绝',
                              `reviewer_id` varchar(32) DEFAULT NULL COMMENT '审核员ID',
                              `review_comment` text DEFAULT NULL COMMENT '审核意见',
                              `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
                              `reward_claimed` tinyint NOT NULL DEFAULT '0' COMMENT '是否已领取奖励:0-否,1-是',
                              `started_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
                              `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                              PRIMARY KEY (`id`),
                              UNIQUE KEY `uk_task_user` (`task_id`, `user_id`),
                              KEY `idx_user_id` (`user_id`),
                              KEY `idx_status` (`status`),
                              KEY `idx_review_status` (`review_status`),
                              CONSTRAINT `fk_user_tasks_task_id` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
                              CONSTRAINT `fk_user_tasks_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                              CONSTRAINT `fk_user_tasks_reviewer_id` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户任务参与记录表';

-- 11. 积分记录表
CREATE TABLE `points_records` (
                                  `id` varchar(32) NOT NULL COMMENT '积分记录ID',
                                  `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                  `type` tinyint NOT NULL COMMENT '类型:1-获得,2-消费',
                                  `source_type` varchar(50) NOT NULL COMMENT '来源类型:task,post,comment,daily_checkin,reward_exchange,manual',
                                  `source_id` varchar(32) DEFAULT NULL COMMENT '来源ID(任务ID、帖子ID等)',
                                  `points` int NOT NULL COMMENT '积分变动数量',
                                  `balance_after` int NOT NULL COMMENT '变动后余额',
                                  `title` varchar(200) NOT NULL COMMENT '积分变动标题',
                                  `description` varchar(500) DEFAULT NULL COMMENT '详细描述',
                                  `operator_id` varchar(32) DEFAULT NULL COMMENT '操作员ID(手动调整时)',
                                  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                  PRIMARY KEY (`id`),
                                  KEY `idx_user_id` (`user_id`),
                                  KEY `idx_type` (`type`),
                                  KEY `idx_source_type` (`source_type`),
                                  KEY `idx_created_at` (`created_at`),
                                  CONSTRAINT `fk_points_records_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                                  CONSTRAINT `fk_points_records_operator_id` FOREIGN KEY (`operator_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='积分记录表';

-- 12. 奖励商品表
CREATE TABLE `rewards` (
                           `id` varchar(32) NOT NULL COMMENT '奖励ID',
                           `name` varchar(200) NOT NULL COMMENT '奖励名称',
                           `description` text DEFAULT NULL COMMENT '奖励描述',
                           `image_url` varchar(500) DEFAULT NULL COMMENT '奖励图片URL',
                           `type` tinyint NOT NULL DEFAULT '1' COMMENT '类型:1-虚拟商品,2-实物商品,3-优惠券,4-特殊权限',
                           `points_required` int NOT NULL COMMENT '所需积分',
                           `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价(元)',
                           `stock_total` int DEFAULT NULL COMMENT '总库存(NULL表示无限)',
                           `stock_remaining` int DEFAULT NULL COMMENT '剩余库存',
                           `exchange_limit` int DEFAULT NULL COMMENT '每人限兑数量(NULL表示无限制)',
                           `validity_period` int DEFAULT NULL COMMENT '有效期(天,NULL表示永久有效)',
                           `exchange_start_time` datetime DEFAULT NULL COMMENT '兑换开始时间',
                           `exchange_end_time` datetime DEFAULT NULL COMMENT '兑换结束时间',
                           `is_featured` tinyint NOT NULL DEFAULT '0' COMMENT '是否精选:0-否,1-是',
                           `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序权重',
                           `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-下架,1-上架,2-售罄',
                           `created_by` varchar(32) NOT NULL COMMENT '创建者ID',
                           `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                           `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                           PRIMARY KEY (`id`),
                           KEY `idx_type` (`type`),
                           KEY `idx_status` (`status`),
                           KEY `idx_featured_sort` (`is_featured`, `sort_order`),
                           KEY `idx_points_required` (`points_required`),
                           CONSTRAINT `fk_rewards_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='奖励商品表';

-- 插入奖励（关联用户ID '1'）
INSERT INTO `rewards` (`id`, `name`, `description`, `type`, `points_required`, `is_featured`, `sort_order`, `created_by`)
VALUES
    ('reward_001', '校园一卡通充值(10元)', '为您的校园一卡通充值10元', 1, 100, 1, 1, '1'),
    ('reward_002', '图书馆延期券', '图书借阅期限延长30天', 1, 50, 1, 2, '1');

-- 13. 用户兑换记录表
CREATE TABLE `user_rewards` (
                                `id` varchar(32) NOT NULL COMMENT '兑换记录ID',
                                `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                `reward_id` varchar(32) NOT NULL COMMENT '奖励ID',
                                `reward_name` varchar(200) NOT NULL COMMENT '兑换时的奖励名称',
                                `points_spent` int NOT NULL COMMENT '消费积分',
                                `quantity` int NOT NULL DEFAULT '1' COMMENT '兑换数量',
                                `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:1-待发放,2-已发放,3-已使用,4-已过期,5-已取消',
                                `exchange_code` varchar(50) DEFAULT NULL COMMENT '兑换码',
                                `recipient_info` json DEFAULT NULL COMMENT '收货信息(JSON对象)',
                                `tracking_number` varchar(100) DEFAULT NULL COMMENT '物流单号',
                                `usage_time` datetime DEFAULT NULL COMMENT '使用时间',
                                `expiry_time` datetime DEFAULT NULL COMMENT '过期时间',
                                `notes` text DEFAULT NULL COMMENT '备注信息',
                                `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '兑换时间',
                                `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                PRIMARY KEY (`id`),
                                KEY `idx_user_id` (`user_id`),
                                KEY `idx_reward_id` (`reward_id`),
                                KEY `idx_status` (`status`),
                                KEY `idx_created_at` (`created_at`),
                                CONSTRAINT `fk_user_rewards_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                                CONSTRAINT `fk_user_rewards_reward_id` FOREIGN KEY (`reward_id`) REFERENCES `rewards` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户兑换记录表';

-- 14. 聊天室表
CREATE TABLE `chat_rooms` (
                              `id` varchar(32) NOT NULL COMMENT '聊天室ID',
                              `name` varchar(100) DEFAULT NULL COMMENT '聊天室名称(群聊时)',
                              `type` tinyint NOT NULL DEFAULT '1' COMMENT '类型:1-私聊,2-群聊,3-系统通知',
                              `avatar_url` varchar(500) DEFAULT NULL COMMENT '聊天室头像URL',
                              `description` varchar(500) DEFAULT NULL COMMENT '聊天室描述',
                              `owner_id` varchar(32) DEFAULT NULL COMMENT '创建者ID',
                              `max_members` int DEFAULT NULL COMMENT '最大成员数(NULL表示无限制)',
                              `current_members` int NOT NULL DEFAULT '0' COMMENT '当前成员数',
                              `is_public` tinyint NOT NULL DEFAULT '0' COMMENT '是否公开:0-私有,1-公开',
                              `join_permission` tinyint NOT NULL DEFAULT '1' COMMENT '加入权限:1-自由加入,2-需要验证,3-仅邀请',
                              `mute_all` tinyint NOT NULL DEFAULT '0' COMMENT '是否全员禁言:0-否,1-是',
                              `last_message_id` varchar(32) DEFAULT NULL COMMENT '最后一条消息ID',
                              `last_message_time` datetime DEFAULT NULL COMMENT '最后消息时间',
                              `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-已删除,1-正常,2-已封禁',
                              `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                              `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                              PRIMARY KEY (`id`),
                              KEY `idx_type` (`type`),
                              KEY `idx_owner_id` (`owner_id`),
                              KEY `idx_status` (`status`),
                              KEY `idx_last_message_time` (`last_message_time`),
                              CONSTRAINT `fk_chat_rooms_owner_id` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='聊天室表';

-- 15. 聊天室成员表
CREATE TABLE `chat_participants` (
                                     `id` varchar(32) NOT NULL COMMENT '参与记录ID',
                                     `room_id` varchar(32) NOT NULL COMMENT '聊天室ID',
                                     `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                     `role` tinyint NOT NULL DEFAULT '1' COMMENT '角色:1-普通成员,2-管理员,3-创建者',
                                     `nickname` varchar(50) DEFAULT NULL COMMENT '群昵称',
                                     `is_muted` tinyint NOT NULL DEFAULT '0' COMMENT '是否被禁言:0-否,1-是',
                                     `mute_until` datetime DEFAULT NULL COMMENT '禁言到期时间',
                                     `last_read_message_id` varchar(32) DEFAULT NULL COMMENT '最后已读消息ID',
                                     `last_read_time` datetime DEFAULT NULL COMMENT '最后已读时间',
                                     `unread_count` int NOT NULL DEFAULT '0' COMMENT '未读消息数',
                                     `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
                                     `left_at` datetime DEFAULT NULL COMMENT '离开时间',
                                     `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-已离开,1-正常',
                                     `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                     PRIMARY KEY (`id`),
                                     UNIQUE KEY `uk_room_user` (`room_id`, `user_id`),
                                     KEY `idx_user_id` (`user_id`),
                                     KEY `idx_role` (`role`),
                                     KEY `idx_status` (`status`),
                                     CONSTRAINT `fk_chat_participants_room_id` FOREIGN KEY (`room_id`) REFERENCES `chat_rooms` (`id`) ON DELETE CASCADE,
                                     CONSTRAINT `fk_chat_participants_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='聊天室成员表';

-- 16. 聊天消息表
CREATE TABLE `chat_messages` (
                                 `id` varchar(32) NOT NULL COMMENT '消息ID',
                                 `room_id` varchar(32) NOT NULL COMMENT '聊天室ID',
                                 `sender_id` varchar(32) NOT NULL COMMENT '发送者ID',
                                 `reply_to_message_id` varchar(32) DEFAULT NULL COMMENT '回复的消息ID',
                                 `message_type` tinyint NOT NULL DEFAULT '1' COMMENT '消息类型:1-文本,2-图片,3-语音,4-视频,5-文件,6-位置,7-系统消息',
                                 `content` text DEFAULT NULL COMMENT '消息内容',
                                 `media_url` varchar(500) DEFAULT NULL COMMENT '媒体文件URL',
                                 `media_size` bigint DEFAULT NULL COMMENT '媒体文件大小(字节)',
                                 `media_duration` int DEFAULT NULL COMMENT '媒体时长(秒)',
                                 `location_info` json DEFAULT NULL COMMENT '位置信息(JSON对象)',
                                 `extra_data` json DEFAULT NULL COMMENT '额外数据(JSON对象)',
                                 `is_recalled` tinyint NOT NULL DEFAULT '0' COMMENT '是否已撤回:0-否,1-是',
                                 `recalled_at` datetime DEFAULT NULL COMMENT '撤回时间',
                                 `read_count` int NOT NULL DEFAULT '0' COMMENT '已读人数',
                                 `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-已删除,1-正常',
                                 `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
                                 `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                 PRIMARY KEY (`id`),
                                 KEY `idx_room_id` (`room_id`),
                                 KEY `idx_sender_id` (`sender_id`),
                                 KEY `idx_message_type` (`message_type`),
                                 KEY `idx_created_at` (`created_at`),
                                 KEY `idx_reply_to` (`reply_to_message_id`),
                                 CONSTRAINT `fk_chat_messages_room_id` FOREIGN KEY (`room_id`) REFERENCES `chat_rooms` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `fk_chat_messages_sender_id` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `fk_chat_messages_reply_to` FOREIGN KEY (`reply_to_message_id`) REFERENCES `chat_messages` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='聊天消息表';

-- 17. 消息已读记录表
CREATE TABLE `message_read_records` (
                                        `id` varchar(32) NOT NULL COMMENT '已读记录ID',
                                        `message_id` varchar(32) NOT NULL COMMENT '消息ID',
                                        `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                        `read_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '已读时间',
                                        PRIMARY KEY (`id`),
                                        UNIQUE KEY `uk_message_user` (`message_id`, `user_id`),
                                        KEY `idx_user_id` (`user_id`),
                                        CONSTRAINT `fk_message_read_message_id` FOREIGN KEY (`message_id`) REFERENCES `chat_messages` (`id`) ON DELETE CASCADE,
                                        CONSTRAINT `fk_message_read_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='消息已读记录表';

-- 18. 文件上传记录表
CREATE TABLE `uploads` (
                           `id` varchar(32) NOT NULL COMMENT '上传记录ID',
                           `user_id` varchar(32) NOT NULL COMMENT '上传用户ID',
                           `original_filename` varchar(255) NOT NULL COMMENT '原始文件名',
                           `stored_filename` varchar(255) NOT NULL COMMENT '存储文件名',
                           `file_path` varchar(500) NOT NULL COMMENT '文件存储路径',
                           `file_url` varchar(500) NOT NULL COMMENT '文件访问URL',
                           `file_type` varchar(50) NOT NULL COMMENT '文件类型:image,video,audio,document',
                           `mime_type` varchar(100) NOT NULL COMMENT 'MIME类型',
                           `file_size` bigint NOT NULL COMMENT '文件大小(字节)',
                           `width` int DEFAULT NULL COMMENT '图片宽度(像素)',
                           `height` int DEFAULT NULL COMMENT '图片高度(像素)',
                           `duration` int DEFAULT NULL COMMENT '音视频时长(秒)',
                           `upload_source` varchar(50) NOT NULL COMMENT '上传来源:avatar,post,comment,chat,task,reward',
                           `source_id` varchar(32) DEFAULT NULL COMMENT '来源对象ID',
                           `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:1-正常,2-审核中,3-审核失败,4-已删除',
                           `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
                           `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                           PRIMARY KEY (`id`),
                           KEY `idx_user_id` (`user_id`),
                           KEY `idx_file_type` (`file_type`),
                           KEY `idx_upload_source` (`upload_source`),
                           KEY `idx_source_id` (`source_id`),
                           KEY `idx_status` (`status`),
                           KEY `idx_created_at` (`created_at`),
                           CONSTRAINT `fk_uploads_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='文件上传记录表';

-- 19. 系统配置表
CREATE TABLE `app_configs` (
                               `id` int AUTO_INCREMENT NOT NULL COMMENT '配置ID',
                               `config_key` varchar(100) NOT NULL COMMENT '配置键名',
                               `config_value` text NOT NULL COMMENT '配置值',
                               `config_type` varchar(20) NOT NULL DEFAULT 'string' COMMENT '配置类型:string,number,boolean,json',
                               `category` varchar(50) NOT NULL COMMENT '配置分类',
                               `description` varchar(500) DEFAULT NULL COMMENT '配置描述',
                               `is_public` tinyint NOT NULL DEFAULT '0' COMMENT '是否公开:0-仅后台,1-客户端可见',
                               `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序权重',
                               `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                               `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                               PRIMARY KEY (`id`),
                               UNIQUE KEY `uk_config_key` (`config_key`),
                               KEY `idx_category` (`category`),
                               KEY `idx_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统配置表';

-- 20. 系统通知表
CREATE TABLE `notifications` (
                                 `id` varchar(32) NOT NULL COMMENT '通知ID',
                                 `user_id` varchar(32) DEFAULT NULL COMMENT '接收用户ID(NULL表示系统广播)',
                                 `title` varchar(200) NOT NULL COMMENT '通知标题',
                                 `content` text NOT NULL COMMENT '通知内容',
                                 `type` varchar(50) NOT NULL COMMENT '通知类型:system,post_like,post_comment,task_completed,reward_exchange,chat_message',
                                 `source_type` varchar(50) DEFAULT NULL COMMENT '来源类型:post,comment,task,reward,chat',
                                 `source_id` varchar(32) DEFAULT NULL COMMENT '来源对象ID',
                                 `action_type` varchar(50) DEFAULT NULL COMMENT '动作类型:like,comment,reply,complete,exchange,message',
                                 `action_user_id` varchar(32) DEFAULT NULL COMMENT '动作发起用户ID',
                                 `extra_data` json DEFAULT NULL COMMENT '额外数据(JSON对象)',
                                 `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '是否已读:0-未读,1-已读',
                                 `read_at` datetime DEFAULT NULL COMMENT '已读时间',
                                 `is_push_sent` tinyint NOT NULL DEFAULT '0' COMMENT '是否已推送:0-未推送,1-已推送',
                                 `push_sent_at` datetime DEFAULT NULL COMMENT '推送时间',
                                 `expires_at` datetime DEFAULT NULL COMMENT '过期时间',
                                 `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                 `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                 PRIMARY KEY (`id`),
                                 KEY `idx_user_id` (`user_id`),
                                 KEY `idx_type` (`type`),
                                 KEY `idx_source_type_id` (`source_type`, `source_id`),
                                 KEY `idx_action_user_id` (`action_user_id`),
                                 KEY `idx_is_read` (`is_read`),
                                 KEY `idx_created_at` (`created_at`),
                                 CONSTRAINT `fk_notifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `fk_notifications_action_user_id` FOREIGN KEY (`action_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统通知表';

-- 21. 用户关注关系表
CREATE TABLE `user_follows` (
                                `id` varchar(32) NOT NULL COMMENT '关注记录ID',
                                `follower_id` varchar(32) NOT NULL COMMENT '关注者ID',
                                `following_id` varchar(32) NOT NULL COMMENT '被关注者ID',
                                `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
                                PRIMARY KEY (`id`),
                                UNIQUE KEY `uk_follower_following` (`follower_id`, `following_id`),
                                KEY `idx_following_id` (`following_id`),
                                CONSTRAINT `fk_user_follows_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                                CONSTRAINT `fk_user_follows_following` FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户关注关系表';

-- 22. 举报记录表
CREATE TABLE `reports` (
                           `id` varchar(32) NOT NULL COMMENT '举报记录ID',
                           `reporter_id` varchar(32) NOT NULL COMMENT '举报人ID',
                           `reported_type` varchar(50) NOT NULL COMMENT '被举报对象类型:user,post,comment,chat_message',
                           `reported_id` varchar(32) NOT NULL COMMENT '被举报对象ID',
                           `reported_user_id` varchar(32) DEFAULT NULL COMMENT '被举报用户ID',
                           `reason` varchar(100) NOT NULL COMMENT '举报原因',
                           `description` text DEFAULT NULL COMMENT '举报说明',
                           `evidence_urls` json DEFAULT NULL COMMENT '证据图片URLs(JSON数组)',
                           `status` tinyint NOT NULL DEFAULT '1' COMMENT '处理状态:1-待处理,2-处理中,3-已处理,4-已忽略',
                           `handler_id` varchar(32) DEFAULT NULL COMMENT '处理人员ID',
                           `handle_result` text DEFAULT NULL COMMENT '处理结果',
                           `handled_at` datetime DEFAULT NULL COMMENT '处理时间',
                           `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '举报时间',
                           `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                           PRIMARY KEY (`id`),
                           KEY `idx_reporter_id` (`reporter_id`),
                           KEY `idx_reported_type_id` (`reported_type`, `reported_id`),
                           KEY `idx_reported_user_id` (`reported_user_id`),
                           KEY `idx_status` (`status`),
                           KEY `idx_created_at` (`created_at`),
                           CONSTRAINT `fk_reports_reporter_id` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                           CONSTRAINT `fk_reports_reported_user_id` FOREIGN KEY (`reported_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
                           CONSTRAINT `fk_reports_handler_id` FOREIGN KEY (`handler_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='举报记录表';

-- 23. 系统日志表
CREATE TABLE `system_logs` (
                               `id` bigint AUTO_INCREMENT NOT NULL COMMENT '日志ID',
                               `user_id` varchar(32) DEFAULT NULL COMMENT '操作用户ID',
                               `action` varchar(100) NOT NULL COMMENT '操作动作',
                               `resource_type` varchar(50) DEFAULT NULL COMMENT '资源类型',
                               `resource_id` varchar(32) DEFAULT NULL COMMENT '资源ID',
                               `ip_address` varchar(45) NOT NULL COMMENT 'IP地址',
                               `user_agent` text DEFAULT NULL COMMENT '用户代理信息',
                               `request_data` json DEFAULT NULL COMMENT '请求数据(JSON对象)',
                               `response_data` json DEFAULT NULL COMMENT '响应数据(JSON对象)',
                               `level` varchar(10) NOT NULL DEFAULT 'INFO' COMMENT '日志级别:DEBUG,INFO,WARN,ERROR',
                               `message` text DEFAULT NULL COMMENT '日志消息',
                               `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                               PRIMARY KEY (`id`),
                               KEY `idx_user_id` (`user_id`),
                               KEY `idx_action` (`action`),
                               KEY `idx_resource_type_id` (`resource_type`, `resource_id`),
                               KEY `idx_level` (`level`),
                               KEY `idx_created_at` (`created_at`),
                               CONSTRAINT `fk_system_logs_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统日志表';

-- 设置外键约束检查
SET FOREIGN_KEY_CHECKS = 1;

-- ====================================
-- 初始化基础数据
-- ====================================

-- 插入帖子分类
INSERT INTO `post_categories` (`name`, `description`, `color`, `sort_order`) VALUES
                                                                                 ('校园生活', '分享校园日常生活点滴', '#FF6B6B', 1),
                                                                                 ('学习交流', '学习资料分享和学术讨论', '#4ECDC4', 2),
                                                                                 ('兼职招聘', '校园兼职和实习机会发布', '#45B7D1', 3),
                                                                                 ('二手交易', '闲置物品买卖交换', '#96CEB4', 4),
                                                                                 ('活动通知', '校园活动和讲座通知', '#FFEAA7', 5),
                                                                                 ('表白墙', '匿名表白和情感交流', '#FD79A8', 6),
                                                                                 ('失物招领', '丢失和拾取物品信息', '#FDCB6E', 7),
                                                                                 ('吃喝玩乐', '美食推荐和娱乐分享', '#6C5CE7', 8);

-- 插入任务分类
INSERT INTO `task_categories` (`name`, `description`, `icon`, `color`, `sort_order`) VALUES
                                                                                         ('日常签到', '每日签到获得积分', 'checkin', '#FF6B6B', 1),
                                                                                         ('发帖互动', '发布帖子和评论互动', 'post', '#4ECDC4', 2),
                                                                                         ('校园活动', '参与校园组织的各类活动', 'activity', '#45B7D1', 3),
                                                                                         ('志愿服务', '校园志愿服务活动', 'volunteer', '#96CEB4', 4),
                                                                                         ('学习打卡', '学习相关的打卡任务', 'study', '#FFEAA7', 5),
                                                                                         ('环保行动', '环保相关的实践活动', 'eco', '#00B894', 6);

-- 插入系统配置
INSERT INTO `app_configs` (`config_key`, `config_value`, `config_type`, `category`, `description`, `is_public`) VALUES
                                                                                                                    ('app_name', '郑州轻工业大学校园圈', 'string', 'basic', '应用名称', 1),
                                                                                                                    ('app_version', '1.0.0', 'string', 'basic', '应用版本', 1),
                                                                                                                    ('daily_checkin_points', '10', 'number', 'points', '每日签到积分奖励', 0),
                                                                                                                    ('post_points', '5', 'number', 'points', '发布帖子积分奖励', 0),
                                                                                                                    ('comment_points', '2', 'number', 'points', '评论积分奖励', 0),
                                                                                                                    ('max_upload_size', '10485760', 'number', 'upload', '最大上传文件大小(字节)', 0),
                                                                                                                    ('allowed_image_types', '["jpg","jpeg","png","gif","webp"]', 'json', 'upload', '允许的图片类型', 0),
                                                                                                                    ('post_audit_enabled', 'false', 'boolean', 'audit', '是否开启帖子审核', 0),
                                                                                                                    ('comment_audit_enabled', 'false', 'boolean', 'audit', '是否开启评论审核', 0);