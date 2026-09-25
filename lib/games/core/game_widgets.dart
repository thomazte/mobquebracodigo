import 'package:flutter/material.dart';

import '../../theme/qc_theme.dart';

class GameStatusBanner extends StatelessWidget {
  final String message;
  final Color accent;
  final IconData icon;

  const GameStatusBanner({
    super.key,
    required this.message,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: QcColors.text, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: QcColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}
