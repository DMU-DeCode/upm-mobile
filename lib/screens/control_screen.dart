import 'package:flutter/material.dart';

import '../control.dart';
import '../status_controller.dart';
import '../theme.dart';
import '../widgets/connection_status.dart';
import '../widgets/upm_card.dart';

/// 제어 탭 — 빠른 최적화 / 전원 끄기 / PC 재시작.
///
/// 기존 dashboard.dart 의 "빠른 제어" 카드를 그대로 옮긴 것입니다.
/// 호출하는 함수([ControlService])와 확인창·안내 문구는 기존과 같습니다.
class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key, required this.controller});

  final StatusController controller;

  Future<void> _optimize(BuildContext context) async {
    final bool success = await ControlService.optimizeSystem();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '🚀 시스템 최적화가 완료되었습니다!' : '❌ 최적화 요청에 실패했습니다.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _shutdown(BuildContext context) async {
    final bool confirmed = await _confirm(
      context,
      title: '전원 끄기',
      message: 'PC를 종료하시겠습니까?',
      confirmLabel: '종료',
      confirmColor: UpmColors.red,
    );
    if (!confirmed) return;

    final bool success = await ControlService.shutdownSystem();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'PC를 종료합니다.' : '❌ 전원 끄기 요청에 실패했습니다.'),
        backgroundColor: success ? UpmColors.red : Colors.red,
      ),
    );
  }

  Future<void> _restart(BuildContext context) async {
    final bool confirmed = await _confirm(
      context,
      title: 'PC 재시작',
      message: 'PC를 재시작하시겠습니까?',
      confirmLabel: '재시작',
      confirmColor: UpmColors.orange,
    );
    if (!confirmed) return;

    final bool success = await ControlService.restartSystem();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'PC를 재시작합니다.' : '❌ 재시작 요청에 실패했습니다.'),
        backgroundColor: success ? UpmColors.orange : Colors.red,
      ),
    );
  }

  /// 위험한 명령을 보내기 전에 띄우는 확인창. "취소"를 누르거나 바깥을 누르면 false.
  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: UpmColors.surfaceHigh,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          ListenableBuilder(
            listenable: controller,
            builder: (BuildContext context, Widget? child) {
              return ScreenTitle(
                title: 'PC 제어',
                subtitle: '명령은 서버를 거쳐 PC로 전달됩니다.',
                trailing: ConnectionStatusBadge(status: controller.linkStatus),
              );
            },
          ),
          const SizedBox(height: 16),
          UpmCard(
            title: '빠른 제어',
            icon: Icons.tune_rounded,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ControlButton(
                  icon: Icons.speed,
                  label: '빠른 최적화',
                  color: UpmColors.green,
                  onPressed: () => _optimize(context),
                ),
                const SizedBox(height: 10),
                _ControlButton(
                  icon: Icons.power_settings_new,
                  label: '전원 끄기',
                  color: UpmColors.red,
                  onPressed: () => _shutdown(context),
                ),
                const SizedBox(height: 10),
                _ControlButton(
                  icon: Icons.restart_alt,
                  label: 'PC 재시작',
                  color: UpmColors.orange,
                  onPressed: () => _restart(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UpmRadius.button)),
        ),
      ),
    );
  }
}
