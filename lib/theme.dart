import 'package:flutter/material.dart';

/// ألوان التطبيق، مطابقة لتصميم الشاشات.
class AppColors {
  static const ground = Color(0xFFF6F3EE);
  static const ink = Color(0xFF1B1F24);
  static const muted = Color(0xFF5C6166);
  static const line = Color(0xFFDDD7CC);
  static const teal = Color(0xFF0F5F5C);
  static const tealSoft = Color(0xFFDCEBE9);
  static const amber = Color(0xFFE8A04C);
  static const amberDeep = Color(0xFF8A5A1C);
  static const amberSoft = Color(0xFFF4E3CC);
  static const night = Color(0xFF1B1F24);
  static const nightCard = Color(0xFF2A3037);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.amber,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.ground,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ground,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.teal,
        minimumSize: const Size(0, 44),
        side: const BorderSide(color: AppColors.teal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

/// بطاقة بيضاء بحواف دائرية، تُستخدم في أغلب الشاشات.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.border});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: border,
      ),
      child: child,
    );
  }
}

/// مربع الحرف الأول من اسم الشركة.
class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({super.key, required this.letter, this.warm = false, this.size = 48});

  final String letter;
  final bool warm;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: warm ? AppColors.amberSoft : AppColors.tealSoft,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: warm ? AppColors.amberDeep : AppColors.teal,
        ),
      ),
    );
  }
}
