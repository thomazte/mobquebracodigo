import 'package:flutter/material.dart';

class QcColors {
  static const Color bg0 = Color(0xFF0A0F2C);
  static const Color bg1 = Color(0xFF111A3A);
  static const Color bg2 = Color(0xFF1C2E6C);
  static const Color bg3 = Color(0xFF3A1F78);
  static const Color panel = Color(0x99070A28);
  static const Color glass = Color(0x780E1432);
  static const Color text = Color(0xFFECEEFF);
  static const Color textDim = Color(0xFFC7CBEC);
  static const Color textMuted = Color(0xFF8A90BC);
  static const Color cyan = Color(0xFF00EAFF);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color green = Color(0xFF34D399);
}

class QcTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: QcColors.bg0,
      colorScheme: base.colorScheme.copyWith(
        primary: QcColors.cyan,
        secondary: QcColors.violet,
        surface: QcColors.bg1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: QcColors.bg1,
        foregroundColor: QcColors.text,
        iconTheme: IconThemeData(color: QcColors.cyan),
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: QcColors.text,
        displayColor: QcColors.text,
      ),
      splashFactory: InkRipple.splashFactory,
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: Colors.white12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return QcColors.cyan.withValues(alpha: 0.2);
            }
            return null;
          }),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 2;
            return 5;
          }),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: QcColors.cyan,
        foregroundColor: QcColors.bg0,
      ),
      cardTheme: CardThemeData(
        color: QcColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
