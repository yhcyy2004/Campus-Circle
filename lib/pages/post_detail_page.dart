import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/section_model.dart';

class PostDetailPage extends StatefulWidget {
  final String sectionId;
  final String postId;

  const PostDetailPage({
    Key? key,
    required this.sectionId,
    required this.postId,
  }) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  SectionPost? post;
  List<SectionPostComment> comments = [];
  bool isLoading = true;
  bool isLoadingComment = false;
  String errorMessage = '';
  bool isLiked = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPostDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService().get('/api/v1/sections/${widget.sectionId}/posts/${widget.postId}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          post = SectionPost.fromJson(response.data['data']['post']);
          comments = (response.data['data']['comments'] as List)
              .map((data) => SectionPostComment.fromJson(data))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.data['message'] ?? '加载失败';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '网络错误：$e';
        isLoading = false;
      });
    }
  }

  Future<void> _likePost() async {
    if (post == null) return;

    try {
      final response = await ApiService().post('/api/v1/sections/${widget.sectionId}/posts/${widget.postId}/like', data: {});

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          isLiked = response.data['data']['liked'];
          if (post != null) {
            final newLikeCount = isLiked ? post!.likeCount + 1 : post!.likeCount - 1;
            post = post!.copyWith(likeCount: newLikeCount);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入评论内容')),
      );
      return;
    }

    setState(() {
      isLoadingComment = true;
    });

    try {
      final response = await ApiService().post(
        '/api/v1/sections/${widget.sectionId}/posts/${widget.postId}/comments',
        data: {
          'content': _commentController.text.trim(),
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        _commentController.clear();
        _loadPostDetail(); // 重新加载以获取最新评论
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('评论成功'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? '评论失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('网络错误：$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingComment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('加载中...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('错误')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(errorMessage, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPostDetail,
                child: Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('帖子详情'),
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPostDetail,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // 帖子内容
                  _buildPostContent(),
                  SizedBox(height: 24),
                  
                  // 评论区标题
                  Row(
                    children: [
                      Icon(Icons.comment_outlined, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        '评论 (${comments.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // 评论列表
                  ...comments.map((comment) => _buildCommentItem(comment)).toList(),
                  
                  if (comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.chat_bubble_outline, 
                                 size: 48, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              '暂无评论',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '快来发表第一条评论吧！',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // 评论输入框
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    if (post == null) return SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                if (post!.isPinned) ...[
                  Icon(Icons.push_pin, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    post!.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // 作者信息
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    post!.isAnonymous 
                        ? '匿' 
                        : (post!.authorName?.substring(0, 1) ?? '?'),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post!.isAnonymous ? '匿名用户' : (post!.authorName ?? '未知用户'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(post!.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // 内容
            Text(
              post!.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            // 操作按钮
            Row(
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  label: post!.likeCount.toString(),
                  onTap: _likePost,
                  color: isLiked ? Colors.blue : null,
                ),
                SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: post!.commentCount.toString(),
                  onTap: () {},
                ),
                SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.visibility_outlined,
                  label: post!.viewCount.toString(),
                  onTap: () {},
                ),
                Spacer(),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '分享',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(SectionPostComment comment) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    comment.isAnonymous 
                        ? '匿' 
                        : (comment.authorName?.substring(0, 1) ?? '?'),
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.isAnonymous 
                            ? '匿名用户' 
                            : (comment.authorName ?? '未知用户'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(comment.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              comment.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (comment.likeCount > 0) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.thumb_up_outlined, size: 12, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    comment.likeCount.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '写评论...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: isLoadingComment ? null : _addComment,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isLoadingComment
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? Colors.grey[600],
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }
}