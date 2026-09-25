import 'package:flutter/material.dart';

class QcPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const QcPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<QcPressable> createState() => _QcPressableState();
}

class _QcPressableState extends State<QcPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.965 : 1,
      duration: const Duration(milliseconds: 95),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: widget.child,
        ),
      ),
    );
  }
}

Route<T> qcDetailRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final scale = Tween<double>(begin: 0.955, end: 1).animate(fade);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.025),
        end: Offset.zero,
      ).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );
}

Future<T?> qcPushDetail<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(qcDetailRoute(page));
}
