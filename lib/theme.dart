import 'package:flutter/material.dart';

/// UPM MOBILE 색상 팔레트.
///
/// 짙은 남색 배경 위에 Cyan / Green / Purple 포인트를 은은하게 쓰는 구성입니다.
/// 게이지 색(green → yellow → orange → red)은 PC 프로그램과 동일한 값을 유지합니다.
class UpmColors {
  UpmColors._();

  // 배경 / 카드
  static const Color background = Color(0xFF0A0F1E);
  static const Color surface = Color(0xFF121A2F);
  static const Color surfaceHigh = Color(0xFF18223D);
  static const Color border = Color(0xFF243152);
  static const Color track = Color(0xFF2A3554);

  // 글자
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA3AECB);
  static const Color textMuted = Color(0xFF6B7697);

  // 포인트
  static const Color cyan = Color(0xFF22D3EE);
  static const Color blue = Color(0xFF3B82F6);
  static const Color purple = Color(0xFFA78BFA);

  // 상태 / 게이지 (기존 값 유지)
  static const Color green = Color(0xFF34C759);
  static const Color yellow = Color(0xFFFFD60A);
  static const Color orange = Color(0xFFFF9F0A);
  static const Color red = Color(0xFFFF453A);
}

/// 공통 모서리 반경.
class UpmRadius {
  UpmRadius._();

  static const double card = 18;
  static const double button = 14;
}

/// 앱 전체 테마.
ThemeData buildUpmTheme() {
  const ColorScheme scheme = ColorScheme.dark(
    primary: UpmColors.cyan,
    onPrimary: Color(0xFF04202A),
    secondary: UpmColors.purple,
    onSecondary: Color(0xFF1B1035),
    surface: UpmColors.surface,
    onSurface: UpmColors.textPrimary,
    error: UpmColors.red,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: UpmColors.background,
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: UpmColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: UpmColors.cyan.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((Set<WidgetState> states) {
        final bool selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? UpmColors.cyan : UpmColors.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((Set<WidgetState> states) {
        final bool selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? UpmColors.cyan : UpmColors.textMuted,
        );
      }),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: UpmColors.cyan),
  );
}
