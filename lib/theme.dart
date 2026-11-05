import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// UPM MOBILE 디자인 시스템
//
// 색 · 글꼴 · 모서리 · 간격 · 그림자 · 애니메이션 값을 이 파일 한 곳에서 관리합니다.
// 화면 코드에서는 숫자를 직접 쓰지 말고 아래 상수를 사용해 주세요.
// ─────────────────────────────────────────────────────────────

/// 색상 팔레트 — 연한 라벤더·블루 배경 + 선명한 블루 포인트.
class UpmColors {
  UpmColors._();

  // 배경 (라벤더와 블루가 섞인 아주 옅은 그라데이션)
  static const Color background = Color(0xFFF7F8FF);
  static const Color backgroundBlue = Color(0xFFEAF0FF);
  static const Color backgroundLavender = Color(0xFFF1ECFF);

  // 카드
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xEBFFFFFF); // 흰색 92%
  static const Color surfaceMuted = Color(0xFFF1F4FB);
  static const Color border = Color(0xFFE6EAF5);
  static const Color borderGlass = Color(0xB3FFFFFF); // 흰색 70%
  static const Color track = Color(0xFFE5EAF6);

  // 글자
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color navInactive = Color(0xFF8A96B3); // 블루 그레이

  // 포인트
  static const Color blue = Color(0xFF2563EB);
  static const Color blueBright = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFF60A5FA);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color green = Color(0xFF22C55E);
  static const Color purple = Color(0xFF7C3AED);
  static const Color violet = Color(0xFF8B5CF6);

  // 상태
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);

  // 항목별 색 (게이지·그래프에서 같은 색을 씁니다)
  static const Color cpu = blue;
  static const Color ram = green;
  static const Color gpu = cyan;

  // 게이지 그라데이션의 시작(연한) 색
  static const Color cpuLight = Color(0xFF93C5FD);
  static const Color ramLight = Color(0xFFA7F3D0);
  static const Color gpuLight = Color(0xFFA5F3FC);
}

/// 그라데이션.
class UpmGradients {
  UpmGradients._();

  /// 주 버튼 (블루 → 퍼플).
  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[UpmColors.blueBright, UpmColors.violet],
  );

  /// 화면 배경.
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[UpmColors.backgroundBlue, UpmColors.backgroundLavender, UpmColors.background],
    stops: <double>[0.0, 0.45, 1.0],
  );
}

/// 글꼴 크기·굵기.
class UpmText {
  UpmText._();

  /// 화면 제목 (예: "그래프").
  static const TextStyle screenTitle = TextStyle(
    color: UpmColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  /// 카드 제목 (예: "시스템 사용 현황").
  static const TextStyle cardTitle = TextStyle(
    color: UpmColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  /// 강조 문구 (예: "지금 바로 최적화해보세요!").
  static const TextStyle headline = TextStyle(
    color: UpmColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static const TextStyle body = TextStyle(color: UpmColors.textSecondary, fontSize: 13, height: 1.45);
  static const TextStyle label = TextStyle(
    color: UpmColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle caption = TextStyle(color: UpmColors.textSecondary, fontSize: 11);
  static const TextStyle value = TextStyle(
    color: UpmColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
}

/// 모서리 반경.
class UpmRadius {
  UpmRadius._();

  static const double card = 24;
  static const double button = 14;
  static const double chip = 999;
  static const double nav = 30;
}

/// 간격.
class UpmSpace {
  UpmSpace._();

  // 값은 디자인 시안(가로 393pt)에서 직접 잰 수치입니다.

  /// 화면 좌우 여백.
  static const double screen = 17;

  /// 카드 사이 간격.
  static const double section = 20;

  /// 카드 안쪽 여백.
  static const double card = 20;
}

/// 그림자.
class UpmShadows {
  UpmShadows._();

  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: Color(0x122563EB), blurRadius: 28, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> button = <BoxShadow>[
    BoxShadow(color: Color(0x383B82F6), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(color: Color(0x1A1E293B), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

/// 애니메이션 시간.
class UpmMotion {
  UpmMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration gauge = Duration(milliseconds: 500);
}

/// 앱 전체 테마.
ThemeData buildUpmTheme() {
  const ColorScheme scheme = ColorScheme.light(
    primary: UpmColors.blue,
    onPrimary: Colors.white,
    secondary: UpmColors.violet,
    onSecondary: Colors.white,
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
      height: 64,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: UpmColors.blue.withValues(alpha: 0.10),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((Set<WidgetState> states) {
        final bool selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? UpmColors.blue : UpmColors.navInactive,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((Set<WidgetState> states) {
        final bool selected = states.contains(WidgetState.selected);
        return IconThemeData(size: 24, color: selected ? UpmColors.blue : UpmColors.navInactive);
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: UpmColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UpmRadius.card)),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: UpmColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: UpmColors.blue),
  );
}
