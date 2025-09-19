import 'package:flutter/material.dart';

/// TabController工厂类 - 面向对象设计，遵循开闭原则
class TabControllerFactory {
  TabController createTabController({
    required int length,
    required TickerProvider vsync,
    int initialIndex = 0,
  }) {
    return TabController(
      length: length,
      vsync: vsync,
      initialIndex: initialIndex,
    );
  }
}

/// TabController管理器 - 单例模式
class TabControllerManager {
  TabControllerManager._();

  static TabControllerManager? _instance;
  static TabControllerManager get instance => _instance ??= TabControllerManager._();

  late TabControllerFactory _factory;

  /// 初始化工厂
  void initialize({TabControllerFactory? factory}) {
    _factory = factory ?? TabControllerFactory();
  }

  /// 创建TabController
  TabController createController({
    required int length,
    required TickerProvider vsync,
    int initialIndex = 0,
  }) {
    return _factory.createTabController(
      length: length,
      vsync: vsync,
      initialIndex: initialIndex,
    );
  }
}

/// Tab配置基类
abstract class TabConfig {
  String get title;
  Widget? get icon;
  bool get isEnabled;
}

/// 默认Tab配置实现
class DefaultTabConfig implements TabConfig {
  const DefaultTabConfig({
    required this.title,
    this.icon,
    this.isEnabled = true,
  });

  @override
  final String title;

  @override
  final Widget? icon;

  @override
  final bool isEnabled;
}

/// TabBar构建器基类
abstract class TabBarBuilder {
  Widget buildTabBar({
    required TabController controller,
    required List<TabConfig> tabs,
    required BuildContext context,
  });

  PreferredSizeWidget buildPreferredSizeWidget({
    required TabController controller,
    required List<TabConfig> tabs,
    required BuildContext context,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: buildTabBar(
        controller: controller,
        tabs: tabs,
        context: context,
      ),
    );
  }
}

/// 默认TabBar构建器
class DefaultTabBarBuilder extends TabBarBuilder {
  DefaultTabBarBuilder({
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  @override
  Widget buildTabBar({
    required TabController controller,
    required List<TabConfig> tabs,
    required BuildContext context,
  }) {
    return TabBar(
      controller: controller,
      labelColor: labelColor ?? Theme.of(context).primaryColor,
      unselectedLabelColor: unselectedLabelColor ?? Colors.grey[600],
      indicatorColor: indicatorColor ?? Theme.of(context).primaryColor,
      labelStyle: labelStyle,
      unselectedLabelStyle: unselectedLabelStyle,
      tabs: tabs.map((config) => Tab(
        text: config.title,
        icon: config.icon,
      )).toList(),
    );
  }
}

/// 带主题的TabBar构建器
class ThemedTabBarBuilder extends TabBarBuilder {
  ThemedTabBarBuilder();

  @override
  Widget buildTabBar({
    required TabController controller,
    required List<TabConfig> tabs,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return TabBar(
      controller: controller,
      labelColor: theme.primaryColor,
      unselectedLabelColor: Colors.grey[600],
      indicatorColor: theme.primaryColor,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      tabs: tabs.map((config) => Tab(
        text: config.title,
        icon: config.icon,
      )).toList(),
    );
  }
}