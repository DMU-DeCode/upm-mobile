import 'package:flutter/material.dart';

import 'format.dart';
import 'status_controller.dart';
import 'theme.dart';
import 'widgets/connection_status.dart';
import 'widgets/metric_gauge.dart';
import 'widgets/upm_card.dart';

/// 홈 탭 — PC 연결 상태와 CPU / 메모리 / GPU 실시간 사용률.
///
/// 1초 폴링은 [StatusController] 로 옮겼고, 이 화면은 그 값을 보여 주기만 합니다.
/// (그래프는 그래프 탭, 빠른 제어는 제어 탭으로 옮겼습니다.)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller, this.onOpenSettings});

  final StatusController controller;

  /// 오른쪽 위 설정 아이콘을 눌렀을 때.
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          final LinkStatus status = controller.linkStatus;

          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: UpmColors.cyan,
            backgroundColor: UpmColors.surfaceHigh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                _Header(status: status, onOpenSettings: onOpenSettings),
                const SizedBox(height: 16),
                _PcSummary(
                  machineId: controller.machineId,
                  lastSuccessAt: controller.lastSuccessAt,
                ),
                if (status == LinkStatus.disconnected || status == LinkStatus.pcIdle) ...<Widget>[
                  const SizedBox(height: 12),
                  LinkNotice(status: status, onRetry: controller.reconnect),
                ],
                const SizedBox(height: 16),
                UpmCard(
                  title: '실시간 모니터',
                  icon: Icons.monitor_heart_outlined,
                  child: _Gauges(controller: controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 상단: UPM MOBILE 로고 · 연결 상태 · 설정 아이콘.
class _Header extends StatelessWidget {
  const _Header({required this.status, required this.onOpenSettings});

  final LinkStatus status;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) => const LinearGradient(
                colors: <Color>[UpmColors.cyan, UpmColors.blue, UpmColors.purple],
              ).createShader(bounds),
              child: const Text(
                'UPM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'MOBILE',
              style: TextStyle(
                color: UpmColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConnectionStatusBadge(status: status),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onOpenSettings,
          tooltip: '설정',
          icon: const Icon(Icons.settings_outlined, color: UpmColors.textPrimary),
        ),
      ],
    );
  }
}

/// 연결된 PC 이름과 마지막 수신 시각.
class _PcSummary extends StatelessWidget {
  const _PcSummary({required this.machineId, required this.lastSuccessAt});

  final String? machineId;
  final DateTime? lastSuccessAt;

  @override
  Widget build(BuildContext context) {
    // PC 이름은 서버가 알려 준 값만 표시합니다. 없으면 N/A.
    final String pcName = machineId ?? 'N/A';
    final String lastSeen = formatClock(lastSuccessAt);

    return UpmCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: UpmColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.desktop_windows_outlined, color: UpmColors.cyan, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '실시간 모니터링',
                  style: TextStyle(
                    color: UpmColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'PC  $pcName   ·   마지막 수신  $lastSeen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: UpmColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CPU / 메모리 / GPU 게이지 3개를 한 줄에 같은 폭으로 배치합니다.
class _Gauges extends StatelessWidget {
  const _Gauges({required this.controller});

  final StatusController controller;

  @override
  Widget build(BuildContext context) {
    final double? used = controller.ramUsedGb;
    final double? total = controller.ramTotalGb;
    final String? ramDetail = (used != null && total != null && total > 0)
        ? '${used.toStringAsFixed(1)}GB / ${total.toStringAsFixed(0)}GB'
        : null;

    final double? gpuTemp = controller.gpuTemp;
    final String? gpuCaption = controller.gpu == null
        ? null
        : (gpuTemp == null ? '온도 N/A' : '${gpuTemp.toInt()}°C');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: MetricGauge(label: 'CPU 사용률', value: controller.cpu)),
        Expanded(
          child: MetricGauge(label: '메모리 사용률', value: controller.ram, detail: ramDetail),
        ),
        Expanded(
          child: MetricGauge(
            label: 'GPU 사용률',
            value: controller.gpu,
            centerCaption: gpuCaption,
          ),
        ),
      ],
    );
  }
}
