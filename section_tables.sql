-- ====================================
-- 分区交流功能数据库表结构
-- 用于郑州轻工业大学校园圈分区讨论功能
-- ====================================

-- 1. 分区表
CREATE TABLE `sections` (
                            `id` varchar(32) NOT NULL COMMENT '分区ID',
                            `name` varchar(100) NOT NULL COMMENT '分区名称',
                            `description` text DEFAULT NULL COMMENT '分区描述',
                            `icon` varchar(100) DEFAULT NULL COMMENT '分区图标',
                            `cover_image` varchar(500) DEFAULT NULL COMMENT '分区封面图片URL',
                            `color` varchar(10) DEFAULT '#007AFF' COMMENT '分区主题颜色',
                            `creator_id` varchar(32) NOT NULL COMMENT '创建者用户ID',
                            `moderator_ids` json DEFAULT NULL COMMENT '版主用户ID列表(JSON数组)',
                            `member_count` int NOT NULL DEFAULT '0' COMMENT '成员数量',
                            `post_count` int NOT NULL DEFAULT '0' COMMENT '帖子数量',
                            `is_public` tinyint NOT NULL DEFAULT '1' COMMENT '是否公开:0-私有,1-公开',
                            `join_permission` tinyint NOT NULL DEFAULT '1' COMMENT '加入权限:1-自由加入,2-需要审核,3-仅邀请',
                            `post_permission` tinyint NOT NULL DEFAULT '1' COMMENT '发帖权限:1-所有成员,2-仅版主,3-审核后发布',
                            `rules` text DEFAULT NULL COMMENT '分区规则',
                            `tags` json DEFAULT NULL COMMENT '分区标签(JSON数组)',
                            `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序权重',
                            `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-禁用,1-正常,2-审核中',
                            `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            PRIMARY KEY (`id`),
                            KEY `idx_creator_id` (`creator_id`),
                            KEY `idx_status` (`status`),
                            KEY `idx_is_public` (`is_public`),
                            KEY `idx_sort_order` (`sort_order`),
                            KEY `idx_created_at` (`created_at`),
                            CONSTRAINT `fk_sections_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='分区表';

-- 2. 分区成员表
CREATE TABLE `section_members` (
                                   `id` varchar(32) NOT NULL COMMENT '成员记录ID',
                                   `section_id` varchar(32) NOT NULL COMMENT '分区ID',
                                   `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                   `role` tinyint NOT NULL DEFAULT '1' COMMENT '角色:1-普通成员,2-版主,3-创建者',
                                   `join_reason` text DEFAULT NULL COMMENT '加入原因',
                                   `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-已退出,1-正常,2-被禁言,3-被踢出',
                                   `mute_until` datetime DEFAULT NULL COMMENT '禁言到期时间',
                                   `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
                                   `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                   PRIMARY KEY (`id`),
                                   UNIQUE KEY `uk_section_user` (`section_id`, `user_id`),
                                   KEY `idx_user_id` (`user_id`),
                                   KEY `idx_role` (`role`),
                                   KEY `idx_status` (`status`),
                                   CONSTRAINT `fk_section_members_section_id` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
                                   CONSTRAINT `fk_section_members_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='分区成员表';

-- 3. 分区帖子表
CREATE TABLE `section_posts` (
                                 `id` varchar(32) NOT NULL COMMENT '帖子ID',
                                 `section_id` varchar(32) NOT NULL COMMENT '分区ID',
                                 `user_id` varchar(32) NOT NULL COMMENT '发布用户ID',
                                 `title` varchar(200) NOT NULL COMMENT '帖子标题',
                                 `content` text NOT NULL COMMENT '帖子内容',
                                 `content_type` tinyint NOT NULL DEFAULT '1' COMMENT '内容类型:1-文字,2-图片,3-视频,4-链接',
                                 `images` json DEFAULT NULL COMMENT '图片URLs(JSON数组)',
                                 `video_url` varchar(500) DEFAULT NULL COMMENT '视频URL',
                                 `link_url` varchar(500) DEFAULT NULL COMMENT '链接URL',
                                 `tags` json DEFAULT NULL COMMENT '帖子标签(JSON数组)',
                                 `is_anonymous` tinyint NOT NULL DEFAULT '0' COMMENT '是否匿名:0-否,1-是',
                                 `is_pinned` tinyint NOT NULL DEFAULT '0' COMMENT '是否置顶:0-否,1-是',
                                 `is_hot` tinyint NOT NULL DEFAULT '0' COMMENT '是否热门:0-否,1-是',
                                 `is_locked` tinyint NOT NULL DEFAULT '0' COMMENT '是否锁定(不允许回复):0-否,1-是',
                                 `view_count` int NOT NULL DEFAULT '0' COMMENT '浏览次数',
                                 `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞数',
                                 `comment_count` int NOT NULL DEFAULT '0' COMMENT '评论数',
                                 `share_count` int NOT NULL DEFAULT '0' COMMENT '分享次数',
                                 `last_comment_time` datetime DEFAULT NULL COMMENT '最后评论时间',
                                 `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态:0-删除,1-正常,2-审核中,3-审核失败,4-被举报',
                                 `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                 `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                 PRIMARY KEY (`id`),
                                 KEY `idx_section_id` (`section_id`),
                                 KEY `idx_user_id` (`user_id`),
                                 KEY `idx_status` (`status`),
                                 KEY `idx_created_at` (`created_at`),
                                 KEY `idx_last_comment_time` (`last_comment_time`),
                                 KEY `idx_hot_pinned` (`is_hot`, `is_pinned`),
                                 CONSTRAINT `fk_section_posts_section_id` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `fk_section_posts_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='分区帖子表';

-- 4. 分区帖子点赞表
CREATE TABLE `section_post_likes` (
                                      `id` bigint AUTO_INCREMENT NOT NULL COMMENT '点赞记录ID',
                                      `post_id` varchar(32) NOT NULL COMMENT '帖子ID',
                                      `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                      `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
                                      PRIMARY KEY (`id`),
                                      UNIQUE KEY `uk_post_user` (`post_id`, `user_id`),
                                      KEY `idx_user_id` (`user_id`),
                                      CONSTRAINT `fk_section_post_likes_post_id` FOREIGN KEY (`post_id`) REFERENCES `section_posts` (`id`) ON DELETE CASCADE,
                                      CONSTRAINT `fk_section_post_likes_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='分区帖子点赞表';

-- 5. 分区帖子评论表
CREATE TABLE `section_post_comments` (
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
                                         CONSTRAINT `fk_section_post_comments_post_id` FOREIGN KEY (`post_id`) REFERENCES `section_posts` (`id`) ON DELETE CASCADE,
                                         CONSTRAINT `fk_section_post_comments_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
                                         CONSTRAINT `fk_section_post_comments_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `section_post_comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='分区帖子评论表';

-- 6. 分区帖子评论点赞表
CREATE TABLE `section_comment_likes` (
                                         `id` bigint AUTO_INCREMENT NOT NULL COMMENT '点赞记录ID',
                                         `comment_id` varchar(32) NOT NULL COMMENT '评论ID',
                                         `user_id` varchar(32) NOT NULL COMMENT '用户ID',
                                         `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
                                         PRIMARY KEY (`id`),
                                         UNIQUE KEY `uk_comment_user` (`comment_id`, `user_id`),
                                         KEY `idx_user_id` (`user_id`),
                                         CONSTRAINT `fk_section_comment_likes_comment_id` FOREIGN KEY (`comment_id`) REFERENCES `section_post_comments` (`id`) ON DELETE CASCADE,
                                         CONSTRAINT `fk_section_comment_likes_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='分区帖子评论点赞表';

-- 插入默认分区数据
INSERT INTO `sections` (`id`, `name`, `description`, `icon`, `color`, `creator_id`, `member_count`, `post_count`, `is_public`, `join_permission`, `post_permission`) VALUES
                                                                                                                                                                        ('section_001', '校园生活', '分享校园日常生活、学习经历和趣事', 'school', '#FF6B6B', '1', 0, 0, 1, 1, 1),
                                                                                                                                                                        ('section_002', '学习交流', '学术讨论、学习资料分享和经验交流', 'book', '#4ECDC4', '1', 0, 0, 1, 1, 1),
                                                                                                                                                                        ('section_003', '社团活动', '各类社团活动发布和讨论', 'group', '#45B7D1', '1', 0, 0, 1, 1, 1),
                                                                                                                                                                        ('section_004', '二手交易', '闲置物品买卖和交换', 'shopping', '#96CEB4', '1', 0, 0, 1, 1, 1),
                                                                                                                                                                        ('section_005', '兼职招聘', '校园兼职和实习机会分享', 'work', '#FFEAA7', '1', 0, 0, 1, 1, 1),
                                                                                                                                                                        ('section_006', '表白墙', '匿名表白和情感交流', 'heart', '#FD79A8', '1', 0, 0, 1, 1, 1),
                                                                                                                                                                        ('section_007', '失物招领', '丢失和拾取物品信息发布', 'find', '#FDCB6E', '1', 0, 0, 1, 1, 1),
                                                                                                                                                                        ('section_008', '美食推荐', '校园及周边美食分享和推荐', 'food', '#6C5CE7', '1', 0, 0, 1, 1, 1);

-- 添加系统配置
INSERT INTO `app_configs` (`config_key`, `config_value`, `config_type`, `category`, `description`, `is_public`) VALUES
                                                                                                                    ('section_create_points', '50', 'number', 'points', '创建分区所需积分', 0),
                                                                                                                    ('max_sections_per_user', '5', 'number', 'section', '每用户最大创建分区数量', 0),
                                                                                                                    ('section_post_points', '3', 'number', 'points', '分区发帖积分奖励', 0),
                                                                                                                    ('section_comment_points', '1', 'number', 'points', '分区评论积分奖励', 0);