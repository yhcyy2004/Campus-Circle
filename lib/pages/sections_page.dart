import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../models/section_model.dart';
import 'section_detail_page.dart';
import 'create_section_page.dart';

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
      appBar: AppBar(
        title: Text('讨论分区'),
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateSectionPage()),
              ).then((result) {
                if (result == true) {
                  _loadSections(); // 创建成功后重新加载
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部装饰
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '发现有趣的讨论区',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '加入分区，参与讨论交流',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSections,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSections,
              child: Text('重试'),
            ),
          ],
        ),
      );
    }

    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '还没有分区',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              '快来创建第一个分区吧！',
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
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
              icon: Icon(Icons.add),
              label: Text('创建分区'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return _buildSectionCard(section);
      },
    );
  }

  Widget _buildSectionCard(Section section) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SectionDetailPage(sectionId: section.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _parseColor(section.color),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconByName(section.icon),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '创建者：${section.creatorName ?? '未知'}',
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
              if (section.description?.isNotEmpty == true) ...[
                SizedBox(height: 12),
                Text(
                  section.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.people_outline,
                    label: '${section.memberCount}人',
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  _buildStatChip(
                    icon: Icons.article_outlined,
                    label: '${section.postCount}帖',
                    color: Colors.green,
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () => _joinSection(section.id),
                    child: Text('加入'),
                    style: TextButton.styleFrom(
                      foregroundColor: _parseColor(section.color),
                    ),
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
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (e) {
      return Color(0xFF4A90E2); // 默认蓝色
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