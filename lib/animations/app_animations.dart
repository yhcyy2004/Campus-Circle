import 'package:flutter/material.dart';

class AppAnimations {
  // 持续时间
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  // 缓动曲线
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  
  // 淡入动画
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    double delay = 0.0,
    Key? key,
  }) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        return TweenAnimationBuilder<double>(
          key: key,
          duration: Duration(milliseconds: duration.inMilliseconds + (delay * 1000).round()),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: easeOut,
          builder: (context, value, child) {
            final animValue = delay > 0 
              ? (value > delay ? (value - delay) / (1 - delay) : 0.0)
              : value;
            return Opacity(
              opacity: animValue.clamp(0.0, 1.0),
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }
  
  // 滑动进入动画
  static Widget slideIn({
    required Widget child,
    Duration duration = normal,
    Offset begin = const Offset(0, 1),
    double delay = 0.0,
    Key? key,
  }) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        return TweenAnimationBuilder<double>(
          key: key,
          duration: Duration(milliseconds: duration.inMilliseconds + (delay * 1000).round()),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: easeOut,
          builder: (context, value, child) {
            final animValue = delay > 0 
              ? (value > delay ? (value - delay) / (1 - delay) : 0.0)
              : value;
            final clampedValue = animValue.clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(
                begin.dx * (1 - clampedValue),
                begin.dy * (1 - clampedValue),
              ),
              child: Opacity(
                opacity: clampedValue,
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
  
  // 缩放动画
  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    double delay = 0.0,
    Key? key,
  }) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        return TweenAnimationBuilder<double>(
          key: key,
          duration: Duration(milliseconds: duration.inMilliseconds + (delay * 1000).round()),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: easeOut,
          builder: (context, value, child) {
            final animValue = delay > 0 
              ? (value > delay ? (value - delay) / (1 - delay) : 0.0)
              : value;
            final clampedValue = animValue.clamp(0.0, 1.0);
            return Transform.scale(
              scale: 0.8 + (clampedValue * 0.2), // 从0.8缩放到1.0
              child: Opacity(
                opacity: clampedValue,
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
  
  // 列表项动画
  static Widget listItemAnimation({
    required Widget child,
    required int index,
    Duration duration = normal,
  }) {
    return slideIn(
      delay: index * 0.1,
      duration: duration,
      child: child,
    );
  }
  
  // 页面过渡动画
  static Route<T> createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      reverseTransitionDuration: fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 滑动 + 淡入效果
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);
        
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        var fadeAnimation = animation.drive(fadeTween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
  
  // 底部弹出动画
  static Route<T> createBottomSheetRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      reverseTransitionDuration: fast,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
  
  // 卡片翻转动画
  static Widget flipCard({
    required Widget front,
    required Widget back,
    required bool showFront,
    Duration duration = slow,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        final rotateAnimation = Tween(begin: 0.5, end: 1.0).animate(animation);
        return AnimatedBuilder(
          animation: rotateAnimation,
          child: child,
          builder: (context, child) {
            if (rotateAnimation.value < 0.75) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotateAnimation.value * 3.14),
                child: front,
              );
            } else {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY((rotateAnimation.value - 0.5) * 3.14),
                child: back,
              );
            }
          },
        );
      },
      child: showFront
          ? Container(key: const ValueKey('front'), child: front)
          : Container(key: const ValueKey('back'), child: back),
    );
  }
  
  // 震动动画
  static Widget shake({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: trigger ? Tween(begin: 0.0, end: 1.0) : Tween(begin: 1.0, end: 1.0),
      builder: (context, value, child) {
        if (!trigger) return child!;
        
        final shake = value < 0.5 
          ? (value * 2) * 10 * (1 - value * 2)
          : ((1 - value) * 2) * 10 * (1 - (1 - value) * 2);
        
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: child,
    );
  }
  
  // 加载动画
  static Widget loadingDots({
    Color color = Colors.blue,
    double size = 8.0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (index * 200)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: size * 0.2),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3 + (value * 0.7)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}