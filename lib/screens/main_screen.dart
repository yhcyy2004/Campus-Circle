import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/sections_page.dart';
import '../pages/chat_page.dart';
import '../pages/task_page.dart';
import '../pages/profile_page.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    SectionsPage(),
    const ChatPage(),
    const TaskPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    print('主页面已加载');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppWidget.gradientBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _buildFuturisticBottomNav(),
    );
  }

  Widget _buildFuturisticBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textTertiary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home, '首页', 0),
            _buildNavItem(Icons.forum_outlined, Icons.forum, '分区', 1),
            _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, '聊天', 2),
            _buildNavItem(Icons.task_alt_outlined, Icons.task_alt, '任务', 3),
            _buildNavItem(Icons.person_outline, Icons.person, '我的', 4),
          ],
        ),
      ),
    );
  }
  
  BottomNavigationBarItem _buildNavItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              )
            : null,
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? Colors.white : AppTheme.textTertiary,
          size: 24,
        ),
      ),
      label: label,
    );
  }
}