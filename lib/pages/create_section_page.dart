import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateSectionPage extends StatefulWidget {
  @override
  _CreateSectionPageState createState() => _CreateSectionPageState();
}

class _CreateSectionPageState extends State<CreateSectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  
  String selectedIcon = 'forum';
  String selectedColor = '#4A90E2';
  bool isPublic = true;
  int joinPermission = 1; // 1-自由加入, 2-需要审核, 3-仅邀请
  int postPermission = 1; // 1-所有成员, 2-仅版主, 3-审核后发布
  bool isLoading = false;

  final List<Map<String, dynamic>> iconOptions = [
    {'icon': Icons.forum, 'name': 'forum', 'label': '论坛'},
    {'icon': Icons.school, 'name': 'school', 'label': '校园'},
    {'icon': Icons.book, 'name': 'book', 'label': '学习'},
    {'icon': Icons.group, 'name': 'group', 'label': '社团'},
    {'icon': Icons.shopping_bag, 'name': 'shopping', 'label': '购物'},
    {'icon': Icons.work, 'name': 'work', 'label': '工作'},
    {'icon': Icons.favorite, 'name': 'heart', 'label': '情感'},
    {'icon': Icons.search, 'name': 'find', 'label': '寻找'},
    {'icon': Icons.restaurant, 'name': 'food', 'label': '美食'},
    {'icon': Icons.sports, 'name': 'sports', 'label': '运动'},
    {'icon': Icons.music_note, 'name': 'music', 'label': '音乐'},
    {'icon': Icons.camera, 'name': 'photo', 'label': '摄影'},
  ];

  final List<String> colorOptions = [
    '#4A90E2', '#FF6B6B', '#4ECDC4', '#45B7D1', 
    '#96CEB4', '#FFEAA7', '#FD79A8', '#FDCB6E',
    '#6C5CE7', '#A29BFE', '#74B9FF', '#00B894',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _createSection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().post('/api/v1/sections', data: {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'icon': selectedIcon,
        'color': selectedColor,
        'is_public': isPublic ? 1 : 0,
        'join_permission': joinPermission,
        'post_permission': postPermission,
        'rules': _rulesController.text.trim().isNotEmpty ? _rulesController.text.trim() : null,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分区创建成功！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // 返回成功标志
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? '创建失败'),
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
        title: Text('创建分区'),
        backgroundColor: _parseColor(selectedColor),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: isLoading ? null : _createSection,
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
                    '创建',
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
            // 预览卡片
            _buildPreviewCard(),
            SizedBox(height: 24),
            
            // 基本信息
            _buildSectionTitle('基本信息'),
            _buildTextField(
              controller: _nameController,
              label: '分区名称',
              hint: '请输入分区名称',
              required: true,
              maxLength: 50,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: '分区描述',
              hint: '简单介绍一下这个分区的主题',
              required: true,
              maxLines: 3,
              maxLength: 200,
            ),
            SizedBox(height: 24),

            // 外观设置
            _buildSectionTitle('外观设置'),
            _buildIconSelector(),
            SizedBox(height: 16),
            _buildColorSelector(),
            SizedBox(height: 24),

            // 权限设置
            _buildSectionTitle('权限设置'),
            _buildSwitchTile(
              title: '公开分区',
              subtitle: '其他用户可以搜索和查看该分区',
              value: isPublic,
              onChanged: (value) => setState(() => isPublic = value),
            ),
            SizedBox(height: 8),
            _buildPermissionSelector(
              title: '加入权限',
              value: joinPermission,
              options: [
                {'value': 1, 'label': '自由加入', 'subtitle': '任何人都可以直接加入'},
                {'value': 2, 'label': '需要审核', 'subtitle': '申请后需要版主审核'},
                {'value': 3, 'label': '仅邀请', 'subtitle': '只能通过邀请加入'},
              ],
              onChanged: (value) => setState(() => joinPermission = value),
            ),
            SizedBox(height: 16),
            _buildPermissionSelector(
              title: '发帖权限',
              value: postPermission,
              options: [
                {'value': 1, 'label': '所有成员', 'subtitle': '所有成员都可以发帖'},
                {'value': 2, 'label': '仅版主', 'subtitle': '只有版主可以发帖'},
                {'value': 3, 'label': '审核后发布', 'subtitle': '发帖需要审核通过'},
              ],
              onChanged: (value) => setState(() => postPermission = value),
            ),
            SizedBox(height: 24),

            // 规则设置
            _buildSectionTitle('分区规则（可选）'),
            _buildTextField(
              controller: _rulesController,
              label: '分区规则',
              hint: '制定一些规则来维护分区秩序...',
              maxLines: 5,
              maxLength: 500,
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '预览',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _parseColor(selectedColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconByName(selectedIcon),
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
                        _nameController.text.isEmpty ? '分区名称' : _nameController.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _descriptionController.text.isEmpty ? '分区描述' : _descriptionController.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        counterText: maxLength != null ? null : '',
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label不能为空';
              }
              return null;
            }
          : null,
      onChanged: (value) => setState(() {}), // 触发预览更新
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择图标',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: iconOptions.map((option) {
            final bool isSelected = selectedIcon == option['name'];
            return GestureDetector(
              onTap: () => setState(() => selectedIcon = option['name']),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? _parseColor(selectedColor) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? _parseColor(selectedColor) : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option['icon'],
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                    SizedBox(height: 2),
                    Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择颜色',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colorOptions.map((color) {
            final bool isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(color),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.grey[800]! : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: _parseColor(selectedColor),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPermissionSelector({
    required String title,
    required int value,
    required List<Map<String, dynamic>> options,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        ...options.map((option) {
          return RadioListTile<int>(
            title: Text(option['label']),
            subtitle: Text(option['subtitle']),
            value: option['value'],
            groupValue: value,
            onChanged: (newValue) => onChanged(newValue!),
            activeColor: _parseColor(selectedColor),
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (e) {
      return Color(0xFF4A90E2);
    }
  }

  IconData _getIconByName(String iconName) {
    final icon = iconOptions.firstWhere(
      (option) => option['name'] == iconName,
      orElse: () => iconOptions.first,
    );
    return icon['icon'];
  }
}