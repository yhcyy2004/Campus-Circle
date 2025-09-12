import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/section_model.dart';
import 'create_post_page.dart';
import 'post_detail_page.dart';

class SectionDetailPage extends StatefulWidget {
  final String sectionId;

  const SectionDetailPage({Key? key, required this.sectionId}) : super(key: key);

  @override
  _SectionDetailPageState createState() => _SectionDetailPageState();
}

class _SectionDetailPageState extends State<SectionDetailPage>
    with SingleTickerProviderStateMixin {
  Section? section;
  List<SectionPost> posts = [];
  bool isLoading = true;
  bool isLoadingPosts = false;
  String errorMessage = '';
  String sortType = 'latest'; // latest, hot, top
  late TabController _tabController;
  int currentPage = 1;
  bool hasMorePosts = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    _loadSectionDetail();
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingPosts &&
        hasMorePosts) {
      _loadMorePosts();
    }
  }

  Future<void> _loadSectionDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService().get('/api/v1/sections/${widget.sectionId}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          section = Section.fromJson(response.data['data']['section']);
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

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      posts.clear();
      hasMorePosts = true;
    }

    try {
      setState(() {
        isLoadingPosts = true;
      });

      final response = await ApiService().get(
        '/api/v1/sections/${widget.sectionId}/posts',
        queryParameters: {
          'page': currentPage.toString(),
          'limit': '20',
          'sort': sortType,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> postsData = response.data['data']['posts'];
        final newPosts = postsData.map((data) => SectionPost.fromJson(data)).toList();
        
        setState(() {
          if (refresh) {
            posts = newPosts;
          } else {
            posts.addAll(newPosts);
          }
          
          final pagination = response.data['data']['pagination'];
          hasMorePosts = currentPage < pagination['totalPages'];
          currentPage++;
          isLoadingPosts = false;
        });
      } else {
        setState(() {
          isLoadingPosts = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingPosts = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (!hasMorePosts || isLoadingPosts) return;
    await _loadPosts();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadSectionDetail(),
      _loadPosts(refresh: true),
    ]);
  }

  void _changeSortType(String newSortType) {
    if (sortType != newSortType) {
      setState(() {
        sortType = newSortType;
      });
      _loadPosts(refresh: true);
    }
  }

  Future<void> _joinSection() async {
    try {
      final response = await ApiService().post('/api/v1/sections/${widget.sectionId}/join', data: {});
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? '加入成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSectionDetail(); // 重新加载分区信息
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? '操作失败'),
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
                onPressed: _loadSectionDetail,
                child: Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(section?.name ?? '分区'),
        backgroundColor: _parseColor(section?.color ?? '#4A90E2'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeSortType,
            icon: Icon(Icons.sort),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'latest',
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20),
                    SizedBox(width: 8),
                    Text('最新'),
                    if (sortType == 'latest') 
                      Expanded(child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Icon(Icons.check, size: 16)]
                      )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hot',
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 20),
                    SizedBox(width: 8),
                    Text('热门'),
                    if (sortType == 'hot') 
                      Expanded(child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Icon(Icons.check, size: 16)]
                      )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'top',
                child: Row(
                  children: [
                    Icon(Icons.push_pin, size: 20),
                    SizedBox(width: 8),
                    Text('置顶'),
                    if (sortType == 'top') 
                      Expanded(child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Icon(Icons.check, size: 16)]
                      )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 分区信息头部
            SliverToBoxAdapter(
              child: _buildSectionHeader(),
            ),
            // 帖子列表
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < posts.length) {
                    return _buildPostCard(posts[index]);
                  } else if (hasMorePosts && isLoadingPosts) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (!hasMorePosts && posts.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '没有更多帖子了',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
                childCount: posts.length + (hasMorePosts ? 1 : 1),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostPage(sectionId: widget.sectionId),
            ),
          ).then((result) {
            if (result == true) {
              _loadPosts(refresh: true); // 发帖成功后刷新列表
            }
          });
        },
        backgroundColor: _parseColor(section?.color ?? '#4A90E2'),
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget _buildSectionHeader() {
    if (section == null) return SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _parseColor(section!.color),
            _parseColor(section!.color).withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconByName(section!.icon),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section!.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '创建者：${section!.creatorName ?? '未知'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (section!.description?.isNotEmpty == true) ...[
                  SizedBox(height: 16),
                  Text(
                    section!.description!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${section!.memberCount}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '成员',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${section!.postCount}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '帖子',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _joinSection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _parseColor(section!.color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('加入分区'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(SectionPost post) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(
                sectionId: widget.sectionId,
                postId: post.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和置顶标识
              Row(
                children: [
                  if (post.isPinned) ...[
                    Icon(Icons.push_pin, size: 16, color: Colors.red),
                    SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // 内容预览
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              
              // 底部信息
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      post.isAnonymous 
                          ? '匿' 
                          : (post.authorName?.substring(0, 1) ?? '?'),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.isAnonymous ? '匿名用户' : (post.authorName ?? '未知用户'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatTime(post.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatIcon(Icons.visibility, post.viewCount),
                  SizedBox(width: 8),
                  _buildStatIcon(Icons.thumb_up_outlined, post.likeCount),
                  SizedBox(width: 8),
                  _buildStatIcon(Icons.comment_outlined, post.commentCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        SizedBox(width: 2),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
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

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (e) {
      return Color(0xFF4A90E2);
    }
  }

  IconData _getIconByName(String? iconName) {
    switch (iconName) {
      case 'school': return Icons.school;
      case 'book': return Icons.book;
      case 'group': return Icons.group;
      case 'shopping': return Icons.shopping_bag;
      case 'work': return Icons.work;
      case 'heart': return Icons.favorite;
      case 'find': return Icons.search;
      case 'food': return Icons.restaurant;
      default: return Icons.forum;
    }
  }
}