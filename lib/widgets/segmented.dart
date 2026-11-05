import 'package:flutter/material.dart';

import '../theme.dart';

/// 알약 모양 세그먼트 컨트롤 (예: [1분] [5분], [CPU] [RAM] [GPU]).
///
/// - expand: true (화면 상단 탭) — 선택 항목을 블루로 채웁니다.
/// - expand: false (카드 제목 옆) — 연회색 바탕 위에 선택 항목만 흰 알약 + 블루 글자로 띄웁니다.
class UpmSegmented<T> extends StatelessWidget {
  const UpmSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelOf,
    this.expand = false,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T value) labelOf;

  /// true 면 가로로 꽉 채우고 항목을 같은 폭으로 나눕니다 (화면 상단 탭용).
  /// false 면 글자 길이만큼만 차지합니다 (카드 제목 옆용).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    // 작은 버전은 시안 크기(약 116 x 27pt)에 맞춤
    final double height = expand ? 40 : 23;
    final double fontSize = expand ? 13 : 12;

    final List<Widget> items = <Widget>[
      for (final T option in options)
        _Segment(
          label: labelOf(option),
          selected: option == selected,
          height: height,
          fontSize: fontSize,
          horizontalPadding: expand ? 0 : 13,
          filled: expand,
          onTap: () => onChanged(option),
        ),
    ];

    return Container(
      padding: EdgeInsets.all(expand ? 3 : 2),
      decoration: BoxDecoration(
        color: expand ? UpmColors.surfaceGlass : const Color(0xFFEEF1F9),
        borderRadius: BorderRadius.circular(UpmRadius.chip),
        border: expand ? Border.all(color: UpmColors.borderGlass) : null,
        boxShadow: expand ? UpmShadows.card : null,
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          for (final Widget item in items) expand ? Expanded(child: item) : item,
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.height,
    required this.fontSize,
    required this.horizontalPadding,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double height;
  final double fontSize;
  final double horizontalPadding;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: UpmMotion.normal,
          curve: Curves.easeOut,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? (filled ? UpmColors.blue : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(UpmRadius.chip),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: filled ? const Color(0x332563EB) : const Color(0x1A1E293B),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: selected ? (filled ? Colors.white : UpmColors.blue) : UpmColors.textMuted,
              fontSize: fontSize,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
