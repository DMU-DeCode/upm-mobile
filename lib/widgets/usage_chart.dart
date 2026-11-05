import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../status_controller.dart';
import '../theme.dart';
import 'segmented.dart';

/// 그래프에 그릴 수 있는 항목.
enum UsageMetric {
  cpu('CPU', UpmColors.cpu, UpmColors.cpuLight, Icons.memory_rounded),
  ram('RAM', UpmColors.ram, UpmColors.ramLight, Icons.developer_board_rounded),
  gpu('GPU', UpmColors.gpu, UpmColors.gpuLight, Icons.videogame_asset_outlined);

  const UsageMetric(this.label, this.color, this.lightColor, this.icon);

  final String label;
  final Color color;

  /// 게이지 그라데이션의 시작(연한) 색.
  final Color lightColor;

  /// 게이지 아래 라벨 아이콘.
  final IconData icon;

  /// 기록 1건에서 이 항목의 값을 꺼냅니다. 없으면 null.
  double? valueOf(UsageSample sample) => switch (this) {
        UsageMetric.cpu => sample.cpu,
        UsageMetric.ram => sample.ram,
        UsageMetric.gpu => sample.gpu,
      };
}

/// 선택할 수 있는 그래프 시간 범위(초): 1분 / 5분.
const List<int> kChartRanges = <int>[60, 300];

String rangeLabel(int seconds) {
  if (seconds >= 3600) return '${seconds ~/ 3600}시간';
  if (seconds >= 60) return '${seconds ~/ 60}분';
  return '$seconds초';
}

/// 범위 안의 실제 기록만 골라 (몇 초 전, 값) 점으로 바꿉니다.
List<FlSpot> spotsFor(
  List<UsageSample> history,
  UsageMetric metric,
  int windowSeconds, {
  DateTime? now,
}) {
  final DateTime reference = now ?? DateTime.now();
  final List<FlSpot> spots = <FlSpot>[];
  for (final UsageSample sample in history) {
    final double? value = metric.valueOf(sample);
    if (value == null) continue;
    final double secondsAgo = reference.difference(sample.time).inMilliseconds / 1000.0;
    if (secondsAgo > windowSeconds) continue;
    spots.add(FlSpot(secondsAgo < 0 ? 0.0 : -secondsAgo, value.clamp(0.0, 100.0)));
  }
  return spots;
}

/// 범위 안 기록의 현재 / 최대 / 평균. 기록이 없으면 모두 null.
class UsageStats {
  const UsageStats({this.current, this.max, this.average});

  factory UsageStats.from(List<UsageSample> history, UsageMetric metric, int windowSeconds) {
    final List<double> values =
        spotsFor(history, metric, windowSeconds).map((FlSpot s) => s.y).toList();
    if (values.isEmpty) return const UsageStats();
    return UsageStats(
      current: values.last,
      max: values.reduce(math.max),
      average: values.reduce((double a, double b) => a + b) / values.length,
    );
  }

  final double? current;
  final double? max;
  final double? average;
}

/// CPU / RAM / GPU 사용률 꺾은선 그래프.
///
/// 서버에서 실제로 받은 값만 그립니다. 기록이 없으면 안내 문구를 보여 줍니다.
class UsageChart extends StatelessWidget {
  const UsageChart({
    super.key,
    required this.history,
    required this.metrics,
    required this.windowSeconds,
    this.height = 200,
    this.compact = false,
  });

  final List<UsageSample> history;
  final List<UsageMetric> metrics;
  final int windowSeconds;
  final double height;

  /// true 면 축 글씨와 격자 없이 부드러운 곡선과 옅은 채움만 그립니다 (홈 화면용).
  final bool compact;

  // x축 글씨 — 1분: -60s … Now / 5분: -5m … Now
  String _xLabel(double value) {
    final int seconds = (-value).round();
    if (seconds == 0) return 'Now';
    return windowSeconds <= 60 ? '-${seconds}s' : '-${(seconds / 60).round()}m';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final List<LineChartBarData> bars = <LineChartBarData>[];
    for (final UsageMetric metric in metrics) {
      final List<FlSpot> spots = spotsFor(history, metric, windowSeconds, now: now);
      if (spots.isEmpty) continue;
      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: compact ? 0.35 : 0.15,
          preventCurveOverShooting: true,
          color: metric.color,
          barWidth: 2.2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                // 선이 하나면 진하게, 여러 개면 겹쳐도 지저분하지 않게 옅게
                metric.color.withValues(alpha: metrics.length == 1 ? 0.20 : 0.12),
                metric.color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      );
    }

    if (bars.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            '표시할 데이터가 없습니다.\nPC에서 데이터가 들어오면 그래프가 그려집니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: UpmColors.textMuted, fontSize: 12, height: 1.5),
          ),
        ),
      );
    }

    final double interval = windowSeconds / 4;
    const TextStyle axisStyle = TextStyle(color: UpmColors.textMuted, fontSize: 9);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          minX: -windowSeconds.toDouble(),
          maxX: 0,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: !compact,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (double value) {
              return const FlLine(color: UpmColors.border, strokeWidth: 1, dashArray: <int>[4, 4]);
            },
          ),
          titlesData: FlTitlesData(
            show: !compact,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !compact,
                reservedSize: 22,
                interval: interval,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final double steps = value / interval;
                  if ((steps - steps.round()).abs() > 0.01) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_xLabel(value), style: axisStyle),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !compact,
                reservedSize: 36,
                interval: 25,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text('${value.round()}%', style: axisStyle);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: bars,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
      ),
    );
  }
}

/// 그래프 아래 범례 (● CPU  ● RAM  ● GPU).
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.metrics});

  final List<UsageMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 4,
      children: <Widget>[
        for (final UsageMetric metric in metrics)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: metric.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                metric.label,
                style: const TextStyle(color: UpmColors.textPrimary, fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }
}

/// [1분] [5분] 시간 범위 선택.
class RangeSelector extends StatelessWidget {
  const RangeSelector({super.key, required this.seconds, required this.onChanged});

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return UpmSegmented<int>(
      options: kChartRanges,
      selected: seconds,
      onChanged: onChanged,
      labelOf: rangeLabel,
    );
  }
}
