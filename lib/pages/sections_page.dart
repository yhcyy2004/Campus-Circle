import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../models/section_model.dart';
import 'section_detail_page.dart';
import 'create_section_page.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../animations/app_animations.dart';

class SectionsPage extends StatefulWidget {
  @override
  _SectionsPageState createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  List<Section> sections = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService().get('/sections');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> sectionsData = response.data['data']['sections'];
        setState(() {
          sections = sectionsData.map((data) => Section.fromJson(data)).toList();
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

  Future<void> _joinSection(String sectionId) async {
    try {
      final response = await ApiService().post('/sections/$sectionId/join', data: {});
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? '加入成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSections(); // 重新加载列表
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
    return Scaffold(
      body: AppWidget.gradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 自定义AppBar
              _buildCustomAppBar(context),
              
              // 内容区域
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadSections,
                  color: AppTheme.primaryColor,
                  backgroundColor: AppTheme.cardBackground,
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppWidget.glowIcon(
            icon: Icons.forum,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '讨论分区',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    shadows: [
                      Shadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Text(
                  '发现有趣的讨论社区',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return AppWidget.neonFAB(
      icon: Icons.add,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateSectionPage()),
        ).then((result) {
          if (result == true) {
            _loadSections();
          }
        });
      },
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: AppWidget.glassCard(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                '正在加载分区...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: AppWidget.glassCard(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.accentSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                '加载失败',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppWidget.gradientButton(
                text: '重试',
                onPressed: _loadSections,
                height: 40,
              ),
            ],
          ),
        ),
      );
    }

    if (sections.isEmpty) {
      return Center(
        child: AppWidget.glassCard(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppWidget.glowIcon(
                icon: Icons.forum_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                '暂无分区',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '成为第一个创建分区的人吧！',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              AppWidget.gradientButton(
                text: '创建分区',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateSectionPage()),
                  ).then((result) {
                    if (result == true) {
                      _loadSections();
                    }
                  });
                },
                height: 44,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        return AppAnimations.listItemAnimation(
          index: index,
          child: _buildSectionCard(sections[index]),
        );
      },
    );
  }

  Widget _buildSectionCard(Section section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AppWidget.glassCard(
        padding: const EdgeInsets.all(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SectionDetailPage(sectionId: section.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 图标容器
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _parseColor(section.color),
                          _parseColor(section.color).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _parseColor(section.color).withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconByName(section.icon),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 标题和创建者
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              section.creatorName ?? '未知',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 加入按钮
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _joinSection(section.id),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            '加入',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // 描述
              if (section.description?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  section.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 16),
              
              // 统计信息
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.people_outline,
                    label: '${section.memberCount}',
                    subtitle: '成员',
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    icon: Icons.article_outlined,
                    label: '${section.postCount}',
                    subtitle: '帖子',
                    color: AppTheme.accentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (e) {
      return AppTheme.primaryColor; // 使用主题色作为默认色
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