import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config.dart';
import '../format.dart';
import '../status_controller.dart';
import '../theme.dart';
import '../widgets/connection_status.dart';
import '../widgets/optimize_button.dart';
import '../widgets/upm_card.dart';
import '../widgets/upm_toast.dart';

/// 설정 탭 — 연결 정보와 앱 정보.
///
/// 알림 설정·고객센터처럼 아직 실제 동작이 없는 항목은 넣지 않았습니다.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final StatusController controller;

  Future<void> _copyServerUrl(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: AppConfig.baseUrl));
    if (!context.mounted) return;
    showUpmToast(context, type: ToastType.info, title: '서버 주소를 복사했어요.');
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: '버전 ${AppConfig.appVersion}',
      applicationLegalese: '동양미래대학교 컴퓨터소프트웨어공학과 졸업작품\nUniversal PC Manager',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          final LinkStatus status = controller.linkStatus;

          return ListView(
            padding: screenListPadding(context),
            children: <Widget>[
              const ScreenTitle(title: '설정'),
              const SizedBox(height: 14),
              UpmCard(
                title: '연결 정보',
                icon: Icons.link_rounded,
                trailing: ConnectionStatusBadge(status: status, chip: true, fontSize: 11),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _InfoRow(label: 'PC 이름', value: controller.machineId ?? 'N/A'),
                    _InfoRow(
                      label: '서버 주소',
                      value: AppConfig.baseUrl,
                      action: IconButton(
                        onPressed: () => _copyServerUrl(context),
                        tooltip: '주소 복사',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.content_copy_rounded,
                            size: 18, color: UpmColors.textSecondary),
                      ),
                    ),
                    _InfoRow(label: '마지막 수신', value: formatClock(controller.lastSuccessAt)),
                    const SizedBox(height: 14),
                    PrimaryActionButton(
                      icon: Icons.refresh_rounded,
                      label: '다시 연결',
                      height: 46,
                      onPressed: controller.reconnect,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              UpmCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  onTap: () => _showAppInfo(context),
                  leading: const Icon(Icons.info_outline_rounded, color: UpmColors.textPrimary),
                  title: const Text(
                    '앱 정보',
                    style: TextStyle(
                      color: UpmColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    '${AppConfig.appName}  ·  버전 ${AppConfig.appVersion}',
                    style: TextStyle(color: UpmColors.textSecondary, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: UpmColors.textMuted),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "항목명 …… 값" 한 줄. 값이 길면 줄바꿈됩니다.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.action});

  final String label;
  final String value;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(color: UpmColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: UpmColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
