import 'package:flutter/material.dart';

import '../status_controller.dart';
import '../theme.dart';
import '../widgets/connection_status.dart';
import '../widgets/segmented.dart';
import '../widgets/upm_card.dart';
import '../widgets/usage_chart.dart';

/// 그래프 탭 — CPU / RAM / GPU 중 하나를 골라 실시간 추이와 통계를 봅니다.
///
/// 그리는 값과 통계는 [StatusController] 가 서버에서 실제로 받은 값뿐입니다.
class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key, required this.controller, this.onBack});

  final StatusController controller;

  /// 제목 옆 "<" 를 눌렀을 때 (홈 탭으로 이동).
  final VoidCallback? onBack;

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  UsageMetric _metric = UsageMetric.cpu;
  int _rangeSeconds = kChartRanges.first;

  @override
  Widget build(BuildContext context) {
    final StatusController controller = widget.controller;

    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          final UsageStats stats =
              UsageStats.from(controller.history, _metric, _rangeSeconds);
          final LinkStatus status = controller.linkStatus;

          return ListView(
            padding: screenListPadding(context),
            children: <Widget>[
              ScreenTitle(
                title: '그래프',
                onBack: widget.onBack,
                trailing: LiveChip(status: status),
              ),
              const SizedBox(height: 14),
              UpmSegmented<UsageMetric>(
                options: UsageMetric.values,
                selected: _metric,
                onChanged: (UsageMetric value) => setState(() => _metric = value),
                labelOf: (UsageMetric value) => value.label,
                expand: true,
              ),
              const SizedBox(height: UpmSpace.section),
              UpmCard(
                title: '${_metric.label} 사용률',
                icon: Icons.query_stats_rounded,
                accent: _metric.color,
                trailing: RangeSelector(
                  seconds: _rangeSeconds,
                  onChanged: (int value) => setState(() => _rangeSeconds = value),
                ),
                child: UsageChart(
                  history: controller.history,
                  metrics: <UsageMetric>[_metric],
                  windowSeconds: _rangeSeconds,
                  height: 210,
                ),
              ),
              const SizedBox(height: UpmSpace.section),
              UpmCard(
                title: '사용량 통계',
                icon: Icons.insights_rounded,
                trailing: Text('최근 ${rangeLabel(_rangeSeconds)}', style: UpmText.caption),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _StatRow(icon: Icons.timer_outlined, label: '현재 사용률', value: stats.current),
                    _StatRow(icon: Icons.arrow_upward_rounded, label: '최대 사용률', value: stats.max),
                    _StatRow(icon: Icons.functions_rounded, label: '평균 사용률', value: stats.average),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '그래프와 통계는 앱이 켜진 뒤 PC에서 받은 실제 값으로 그립니다.',
                  style: TextStyle(color: UpmColors.textMuted, fontSize: 11, height: 1.4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final double? v = value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: UpmColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: UpmColors.textSecondary, fontSize: 13),
            ),
          ),
          Text(
            v == null ? 'N/A' : '${v.round()}%',
            style: const TextStyle(
              color: UpmColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
