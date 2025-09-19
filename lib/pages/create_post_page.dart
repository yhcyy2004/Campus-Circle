import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreatePostPage extends StatefulWidget {
  final String sectionId;

  const CreatePostPage({Key? key, required this.sectionId}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool isAnonymous = false;
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().post('/api/v1/sections/${widget.sectionId}/posts', data: {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'is_anonymous': isAnonymous ? 1 : 0,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? '发布成功'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // 返回成功标志
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? '发布失败'),
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
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发布帖子'),
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: isLoading ? null : _createPost,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    '发布',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '标题',
                hintText: '请输入帖子标题',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '标题不能为空';
                }
                if (value.length > 100) {
                  return '标题不能超过100个字符';
                }
                return null;
              },
              maxLength: 100,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '内容',
                hintText: '分享你的想法...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '内容不能为空';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('匿名发布'),
              subtitle: Text('其他用户将看不到你的昵称'),
              value: isAnonymous,
              onChanged: (value) => setState(() => isAnonymous = value),
              activeColor: Color(0xFF4A90E2),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          '发帖须知',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• 请遵守社区规则，文明发言\n'
                      '• 不得发布违法违规内容\n'
                      '• 尊重他人，理性讨论\n'
                      '• 禁止恶意刷屏和广告',
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}