import 'package:flutter/material.dart';

import '../control.dart';
import '../theme.dart';
import 'upm_toast.dart';

/// "⚡ 최적화 실행" 버튼.
///
/// 기존과 같은 POST /optimize 를 호출합니다 ([ControlService.requestOptimize]).
/// 서버가 PC 프로그램에 전달해 PC의 빠른 최적화 버튼과 같은 동작을 실행합니다.
/// 요청 중에는 버튼이 "최적화 중…" 으로 바뀌고 다시 누를 수 없습니다.
class OptimizeButton extends StatefulWidget {
  const OptimizeButton({super.key, this.compact = false});

  /// true 면 글자 길이만큼의 알약 버튼(⚡ 최적화 실행 ›), false 면 가로로 꽉 찬 버튼.
  final bool compact;

  @override
  State<OptimizeButton> createState() => _OptimizeButtonState();
}

class _OptimizeButtonState extends State<OptimizeButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    final OptimizeResult result = await ControlService.requestOptimize();
    if (!mounted) return;
    setState(() => _busy = false);

    final int? cleared = result.clearedCount;
    if (!result.success) {
      showUpmToast(
        context,
        type: ToastType.error,
        title: '최적화를 완료하지 못했어요.',
        message: result.message ?? '잠시 후 다시 시도해 주세요.',
      );
    } else if (cleared == 0) {
      showUpmToast(
        context,
        type: ToastType.info,
        title: 'PC가 이미 쾌적한 상태예요.',
        message: '정리할 프로세스가 없습니다.',
      );
    } else {
      showUpmToast(
        context,
        type: ToastType.success,
        title: '최적화가 완료되었어요.',
        message: cleared == null ? null : '불필요한 프로세스 $cleared개를 정리했어요.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryActionButton(
      icon: Icons.bolt_rounded,
      label: _busy ? '최적화 중…' : '최적화 실행',
      busy: _busy,
      onPressed: _busy ? null : _run,
      pill: widget.compact,
      expand: !widget.compact,
      showChevron: widget.compact,
      height: widget.compact ? 36 : 48, // 알약 버튼은 시안 크기(약 132 x 36pt)
    );
  }
}

/// 블루 → 퍼플 그라데이션의 주 버튼 (최적화 실행, 다시 연결 등).
///
/// 글자는 말줄임(…) 없이 항상 한 줄로 전부 표시합니다. 공간이 모자라면 줄바꿈 대신
/// 버튼 안 내용 전체가 같은 비율로 조금 작아집니다.
/// 누르는 동안 살짝 작아졌다가 돌아오는 피드백이 있습니다.
class PrimaryActionButton extends StatefulWidget {
  const PrimaryActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.height = 48,
    this.pill = false,
    this.expand = true,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final double height;

  /// true 면 완전히 둥근 알약 모양.
  final bool pill;

  /// true 면 가로로 꽉 채우고, false 면 내용 길이만큼만 차지합니다.
  final bool expand;

  /// true 면 글자 오른쪽에 › 표시.
  final bool showChevron;

  @override
  State<PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<PrimaryActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final BorderRadius radius = BorderRadius.circular(widget.pill ? UpmRadius.chip : UpmRadius.button);
    final double fontSize = widget.pill ? 13.5 : 15;
    final double iconSize = widget.pill ? 17 : 20;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.busy)
          SizedBox(
            width: iconSize - 2,
            height: iconSize - 2,
            child: const CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          )
        else
          Icon(widget.icon, color: Colors.white, size: iconSize),
        const SizedBox(width: 6),
        Text(
          widget.label,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
        if (widget.showChevron && !widget.busy) ...<Widget>[
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: Colors.white, size: iconSize + 1),
        ],
      ],
    );

    // 구조: DecoratedBox(그라데이션 + 같은 모양의 그림자) → 투명 Material(버튼 모양으로 자름) → InkWell
    // 그림자는 바깥 DecoratedBox 가 그리므로 잘리지 않고, 터치 물결만 버튼 모양 안에 그려집니다.
    // (예전에는 그림자를 Ink 로 그려서, Material 이 사각형으로 잘라 버튼 뒤에 네모 테두리가 보였습니다.)
    Widget button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: UpmGradients.primaryButton,
        boxShadow: UpmShadows.button,
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          child: SizedBox(
            height: widget.height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.pill ? 18 : 14),
              // 한 줄 유지: 공간이 부족할 때만 내용 전체를 비율대로 줄입니다 (말줄임 없음).
              child: Center(
                widthFactor: 1,
                child: FittedBox(fit: BoxFit.scaleDown, child: content),
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Listener(
      onPointerDown: enabled ? (_) => _setPressed(true) : null,
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: UpmMotion.fast,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          duration: UpmMotion.normal,
          opacity: enabled || widget.busy ? 1 : 0.5,
          child: button,
        ),
      ),
    );
  }
}
