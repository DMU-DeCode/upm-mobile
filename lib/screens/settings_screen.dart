import 'package:flutter/material.dart';

import '../config.dart';
import '../format.dart';
import '../status_controller.dart';
import '../theme.dart';
import '../widgets/connection_status.dart';
import '../widgets/upm_card.dart';

/// 설정 탭 — 연결 정보와 앱 정보.
///
/// 알림 설정·다크모드 전환처럼 아직 실제 동작이 없는 항목은 넣지 않았습니다.
/// (동작하지 않는 스위치를 화면에만 두지 않기 위해서입니다.)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final StatusController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          final LinkStatus status = controller.linkStatus;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: <Widget>[
              const ScreenTitle(title: '설정'),
              const SizedBox(height: 16),
              UpmCard(
                title: '연결 정보',
                icon: Icons.link_rounded,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _InfoRow(
                      label: '연결 상태',
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ConnectionStatusBadge(status: status),
                      ),
                    ),
                    _InfoRow.text(label: 'PC 이름', value: controller.machineId ?? 'N/A'),
                    const _InfoRow.text(label: '서버 주소', value: AppConfig.baseUrl),
                    _InfoRow.text(
                      label: '마지막 수신',
                      value: formatClock(controller.lastSuccessAt),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: controller.reconnect,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          '다시 연결',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: UpmColors.cyan,
                          side: const BorderSide(color: UpmColors.cyan, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(UpmRadius.button),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const UpmCard(
                title: '앱 정보',
                icon: Icons.info_outline_rounded,
                accent: UpmColors.purple,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _InfoRow.text(label: '앱 이름', value: AppConfig.appName),
                    _InfoRow.text(label: '버전', value: AppConfig.appVersion),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "항목명 …… 값" 한 줄.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.child}) : value = null;

  const _InfoRow.text({required this.label, required this.value}) : child = null;

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final String? text = value;
    final Widget? custom = child;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(color: UpmColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: custom ??
                Text(
                  text ?? 'N/A',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: UpmColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
