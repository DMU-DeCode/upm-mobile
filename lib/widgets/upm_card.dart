import 'package:flutter/material.dart';

import '../theme.dart';

/// 각 탭 화면 목록의 바깥 여백.
///
/// 하단 탭은 화면 아래 별도 영역에 고정되어 있어 콘텐츠와 겹치지 않습니다.
/// 마지막 카드 아래에 여유 여백만 둡니다.
EdgeInsets screenListPadding(BuildContext context) {
  final double bottomInset = MediaQuery.paddingOf(context).bottom;
  return EdgeInsets.fromLTRB(UpmSpace.screen, 8, UpmSpace.screen, 20 + bottomInset);
}

/// 모든 화면에서 쓰는 공통 카드 (반투명 흰색 + 은은한 그림자).
///
/// [title] 을 주면 카드 위쪽에 제목 줄(아이콘 + 제목 + [trailing])이 붙습니다.
class UpmCard extends StatelessWidget {
  const UpmCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.trailing,
    this.accent = UpmColors.blue,
    this.padding = const EdgeInsets.fromLTRB(UpmSpace.card, 16, UpmSpace.card, 16),
    this.titleGap = 14,
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final Widget? trailing;

  /// 제목 아이콘 색.
  final Color accent;
  final EdgeInsetsGeometry padding;

  /// 제목 줄과 내용 사이 간격.
  final double titleGap;

  @override
  Widget build(BuildContext context) {
    final String? titleText = title;
    final IconData? titleIcon = icon;
    final Widget? titleTrailing = trailing;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: UpmColors.surfaceGlass,
        borderRadius: BorderRadius.circular(UpmRadius.card),
        border: Border.all(color: UpmColors.borderGlass),
        boxShadow: UpmShadows.card,
      ),
      // 투명 Material: 카드 안 버튼의 배경(Ink)과 터치 물결이 흰 카드 '위'에 그려지게 합니다.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (titleText != null) ...<Widget>[
              Row(
                children: <Widget>[
                  if (titleIcon != null) ...<Widget>[
                    Icon(titleIcon, size: 22, color: accent),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      titleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UpmText.cardTitle,
                    ),
                  ),
                  if (titleTrailing != null) ...<Widget>[
                    const SizedBox(width: 8),
                    titleTrailing,
                  ],
                ],
              ),
              SizedBox(height: titleGap),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// 각 탭 화면 맨 위의 제목 (예: "< 그래프").
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.onBack, this.trailing});

  final String title;

  /// 주면 제목 왼쪽에 뒤로가기(<) 버튼이 생깁니다.
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? back = onBack;
    final Widget? trailingWidget = trailing;

    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          if (back != null)
            IconButton(
              onPressed: back,
              tooltip: '홈으로',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: UpmColors.textPrimary),
            ),
          Expanded(
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: UpmText.screenTitle),
          ),
          if (trailingWidget != null) ...<Widget>[
            const SizedBox(width: 12),
            trailingWidget,
          ],
        ],
      ),
    );
  }
}

/// 카드 안의 둥근 아이콘 배경.
class IconBubble extends StatelessWidget {
  const IconBubble({super.key, required this.icon, required this.color, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// 화면 배경: 라벤더와 블루가 섞인 옅은 그라데이션 + 오른쪽 위의 은은한 빛 덩어리.
class UpmBackground extends StatelessWidget {
  const UpmBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: UpmGradients.background),
      child: Stack(
        children: <Widget>[
          // 장식용 빛 (터치에 반응하지 않음)
          const Positioned(top: -120, right: -110, child: _Glow(size: 320, color: Color(0x667C9CFF))),
          const Positioned(top: 40, right: -60, child: _Glow(size: 180, color: Color(0x4DB4A6FF))),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: <Color>[color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
