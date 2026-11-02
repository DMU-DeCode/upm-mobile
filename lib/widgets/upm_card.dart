import 'package:flutter/material.dart';

import '../theme.dart';

/// 모든 화면에서 쓰는 공통 카드.
///
/// [title] 을 주면 카드 위쪽에 제목 줄(아이콘 + 제목 + [trailing])이 붙습니다.
class UpmCard extends StatelessWidget {
  const UpmCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.trailing,
    this.accent = UpmColors.cyan,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final Widget? trailing;

  /// 제목 아이콘 색.
  final Color accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final String? titleText = title;
    final IconData? titleIcon = icon;
    final Widget? titleTrailing = trailing;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[UpmColors.surfaceHigh, UpmColors.surface],
        ),
        borderRadius: BorderRadius.circular(UpmRadius.card),
        border: Border.all(color: UpmColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (titleText != null) ...<Widget>[
            Row(
              children: <Widget>[
                if (titleIcon != null) ...<Widget>[
                  Icon(titleIcon, size: 18, color: accent),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    titleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: UpmColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ?titleTrailing,
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

/// 각 탭 화면 맨 위의 제목.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final String? subtitleText = subtitle;
    final Widget? trailingWidget = trailing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: UpmColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitleText != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: UpmColors.textSecondary, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        if (trailingWidget != null) ...<Widget>[
          const SizedBox(width: 12),
          trailingWidget,
        ],
      ],
    );
  }
}
