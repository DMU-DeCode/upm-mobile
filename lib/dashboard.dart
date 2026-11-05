import 'package:flutter/material.dart';

import 'status_controller.dart';
import 'theme.dart';
import 'widgets/connection_status.dart';
import 'widgets/metric_gauge.dart';
import 'widgets/quick_optimize_card.dart';
import 'widgets/upm_card.dart';
import 'widgets/upm_logo.dart';
import 'widgets/usage_chart.dart';

/// 홈 탭 — 로고·연결 상태, 시스템 사용 현황, 실시간 사용률, 빠른 최적화.
///
/// 1초 폴링은 [StatusController] 가 하고, 이 화면은 그 값을 보여 주기만 합니다.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.controller, this.onOpenSettings});

  final StatusController controller;

  /// 설정 아이콘이나 연결 상태 알약을 눌렀을 때 (설정 탭으로 이동).
  final VoidCallback? onOpenSettings;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _rangeSeconds = kChartRanges.first;

  @override
  Widget build(BuildContext context) {
    final StatusController controller = widget.controller;

    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          final LinkStatus status = controller.linkStatus;

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: screenListPadding(context),
              children: <Widget>[
                _Header(
                  status: status,
                  machineId: controller.machineId,
                  onOpenSettings: widget.onOpenSettings,
                ),
                if (status == LinkStatus.disconnected || status == LinkStatus.pcIdle) ...<Widget>[
                  const SizedBox(height: 14),
                  LinkNotice(status: status, onRetry: controller.reconnect),
                ],
                const SizedBox(height: 16),
                UpmCard(
                  title: '시스템 사용 현황',
                  icon: Icons.desktop_windows_rounded,
                  trailing: LiveChip(status: status),
                  padding: const EdgeInsets.fromLTRB(UpmSpace.card, 16, UpmSpace.card, 15),
                  titleGap: 10,
                  child: _Gauges(controller: controller),
                ),
                const SizedBox(height: UpmSpace.section),
                UpmCard(
                  title: '실시간 사용률',
                  icon: Icons.bar_chart_rounded,
                  trailing: RangeSelector(
                    seconds: _rangeSeconds,
                    onChanged: (int value) => setState(() => _rangeSeconds = value),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      UsageChart(
                        history: controller.history,
                        metrics: UsageMetric.values,
                        windowSeconds: _rangeSeconds,
                        height: 104,
                        compact: true,
                      ),
                      const SizedBox(height: 16),
                      const ChartLegend(metrics: UsageMetric.values),
                    ],
                  ),
                ),
                const SizedBox(height: UpmSpace.section),
                const QuickOptimizeCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 상단: 로고 + "Universal PC Manager" · 설정 버튼 / 연결 상태 알약.
class _Header extends StatelessWidget {
  const _Header({required this.status, required this.machineId, required this.onOpenSettings});

  final LinkStatus status;
  final String? machineId;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // 로고 이미지 바깥의 빛 번짐 여백만큼 왼쪽으로 당겨, 글자 위치를 카드 왼쪽 선에 맞춥니다.
                  FractionalTranslation(
                    translation: Offset(-0.07, 0),
                    child: UpmLogo(height: 50),
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          'Universal PC Manager',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: UpmColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.auto_awesome, size: 13, color: UpmColors.blueBright),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: UpmShadows.floating,
              ),
              child: Material(
                type: MaterialType.transparency,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  onPressed: onOpenSettings,
                  tooltip: '설정',
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.settings_outlined, size: 22, color: UpmColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ConnectionPill(status: status, machineId: machineId, onTap: onOpenSettings),
      ],
    );
  }
}

/// "● 연결됨 | DESKTOP-CAQDV23 ›" 흰색 캡슐. 누르면 설정(연결 정보)으로 이동합니다.
class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.status, required this.machineId, required this.onTap});

  final LinkStatus status;
  final String? machineId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? pcName = machineId;
    final Color dot = linkStatusColor(status);
    final BorderRadius radius = BorderRadius.circular(UpmRadius.chip);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: radius,
        border: Border.all(color: UpmColors.borderGlass),
        boxShadow: UpmShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedContainer(
                  duration: UpmMotion.normal,
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text(
                  linkStatusLabel(status),
                  style: const TextStyle(
                    color: UpmColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (pcName != null) ...<Widget>[
                  Container(
                    width: 1,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: UpmColors.textMuted,
                  ),
                  Flexible(
                    child: Text(
                      pcName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: UpmColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 18, color: UpmColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CPU / RAM / GPU 게이지 3개를 한 줄에 같은 폭·같은 크기로 배치합니다.
class _Gauges extends StatelessWidget {
  const _Gauges({required this.controller});

  final StatusController controller;

  @override
  Widget build(BuildContext context) {
    final double? used = controller.ramUsedGb;
    final double? total = controller.ramTotalGb;
    final String? ramCaption = (used != null && used > 0 && total != null && total > 0)
        ? '${used.toStringAsFixed(1)} / ${total.toStringAsFixed(0)}GB'
        : null;

    final double? gpuTemp = controller.gpuTemp;
    final String? gpuCaption = gpuTemp == null ? null : '${gpuTemp.toInt()}°C';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _gauge(UsageMetric.cpu, controller.cpu, null)),
        Expanded(child: _gauge(UsageMetric.ram, controller.ram, ramCaption)),
        Expanded(child: _gauge(UsageMetric.gpu, controller.gpu, gpuCaption)),
      ],
    );
  }

  Widget _gauge(UsageMetric metric, double? value, String? caption) {
    return MetricGauge(
      label: metric.label,
      icon: metric.icon,
      value: value,
      color: metric.color,
      lightColor: metric.lightColor,
      caption: caption,
    );
  }
}
