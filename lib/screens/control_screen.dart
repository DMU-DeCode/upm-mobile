import 'package:flutter/material.dart';

import '../control.dart';
import '../status_controller.dart';
import '../theme.dart';
import '../widgets/connection_status.dart';
import '../widgets/quick_optimize_card.dart';
import '../widgets/upm_card.dart';
import '../widgets/upm_toast.dart';

/// 제어 탭 — 빠른 최적화 / 전원 끄기 / 다시 시작.
///
/// 호출하는 함수([ControlService])와 확인창 문구는 기존과 같습니다.
/// 서버에 기능이 없는 항목(절전 모드, 프로그램 종료 등)은 넣지 않았습니다.
class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key, required this.controller});

  final StatusController controller;

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _busy = false;

  Future<void> _shutdown() async {
    final bool confirmed = await _confirm(
      title: '전원 끄기',
      message: 'PC를 종료하시겠습니까?',
      confirmLabel: '종료',
      confirmColor: UpmColors.red,
    );
    if (!confirmed) return;
    await _send(
      ControlService.shutdownSystem,
      successTitle: 'PC를 종료합니다.',
      successMessage: '약 3초 뒤 PC 전원이 꺼져요.',
      failTitle: '전원 끄기 요청에 실패했어요.',
    );
  }

  Future<void> _restart() async {
    final bool confirmed = await _confirm(
      title: 'PC 재시작',
      message: 'PC를 재시작하시겠습니까?',
      confirmLabel: '재시작',
      confirmColor: UpmColors.blue,
    );
    if (!confirmed) return;
    await _send(
      ControlService.restartSystem,
      successTitle: 'PC를 재시작합니다.',
      successMessage: '약 3초 뒤 PC가 다시 시작돼요.',
      failTitle: '재시작 요청에 실패했어요.',
    );
  }

  Future<void> _send(
    Future<bool> Function() request, {
    required String successTitle,
    required String successMessage,
    required String failTitle,
  }) async {
    setState(() => _busy = true);
    final bool success = await request();
    if (!mounted) return;
    setState(() => _busy = false);
    if (success) {
      showUpmToast(context, type: ToastType.success, title: successTitle, message: successMessage);
    } else {
      showUpmToast(context, type: ToastType.error, title: failTitle, message: '잠시 후 다시 시도해 주세요.');
    }
  }

  /// 위험한 명령을 보내기 전에 띄우는 확인창. "취소"를 누르거나 바깥을 누르면 false.
  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title, style: const TextStyle(color: UpmColors.textPrimary)),
        content: Text(message, style: const TextStyle(color: UpmColors.textSecondary)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소', style: TextStyle(color: UpmColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmLabel,
              style: TextStyle(color: confirmColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: screenListPadding(context),
        children: <Widget>[
          ListenableBuilder(
            listenable: widget.controller,
            builder: (BuildContext context, Widget? child) {
              return ScreenTitle(
                title: '제어',
                trailing: ConnectionStatusBadge(
                  status: widget.controller.linkStatus,
                  chip: true,
                  fontSize: 11,
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const QuickOptimizeCard(title: '빠른 최적화'),
          const SizedBox(height: UpmSpace.section),
          UpmCard(
            title: '전원 관리',
            icon: Icons.power_settings_new_rounded,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _PowerTile(
                    icon: Icons.power_settings_new_rounded,
                    label: '전원 끄기',
                    color: UpmColors.red,
                    onTap: _busy ? null : _shutdown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PowerTile(
                    icon: Icons.restart_alt_rounded,
                    label: '다시 시작',
                    color: UpmColors.blue,
                    onTap: _busy ? null : _restart,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '전원 명령은 확인 후 서버를 거쳐 PC로 전달되며, 약 3초 뒤 실행됩니다.',
              style: TextStyle(color: UpmColors.textMuted, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 전원 관리의 정사각형 버튼 1개.
class _PowerTile extends StatelessWidget {
  const _PowerTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);
    return Material(
      color: color.withValues(alpha: 0.06),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconBubble(icon: icon, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
