import 'package:flutter/material.dart';

import '../theme/qc_theme.dart';

class QcBackOverlay extends StatelessWidget {
  const QcBackOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: Colors.black.withValues(alpha: 0.28),
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: QcColors.cyan),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
      ),
    );
  }
}
