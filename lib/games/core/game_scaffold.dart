import 'package:flutter/material.dart';

import '../../theme/qc_theme.dart';
import '../../widgets/qc_interactions.dart';

class GameStat {
  final String label;
  final String value;

  const GameStat({required this.label, required this.value});
}

class GameScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<GameStat> stats;
  final Widget body;
  final List<Widget> actions;
  final Widget? footer;

  const GameScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.body,
    this.actions = const [],
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1, QcColors.bg2],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(title: title, subtitle: subtitle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats
                  .map(
                    (s) => _StatPill(label: s.label, value: s.value),
                  )
                  .toList(),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 10, children: actions),
            ],
            const SizedBox(height: 14),
            body,
            if (footer != null) ...[
              const SizedBox(height: 14),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class GameActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool primary;

  const GameActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: primary ? QcColors.cyan : QcColors.panel,
        border: Border.all(
          color: primary ? QcColors.cyan : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: primary ? QcColors.bg0 : QcColors.text),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: primary ? QcColors.bg0 : QcColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    return QcPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QcColors.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: QcColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: QcColors.textDim, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: QcColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: QcColors.textMuted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: QcColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
