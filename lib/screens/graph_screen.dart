import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../status_controller.dart';
import '../theme.dart';
import '../widgets/connection_status.dart';
import '../widgets/upm_card.dart';

/// 그래프 탭 — CPU 사용량 추이 (최근 60초).
///
/// 기존 dashboard.dart 의 "CPU 사용량 추이 (실시간)" 그래프를 그대로 옮긴 것입니다.
/// 그리는 값은 [StatusController] 가 서버에서 실제로 받은 값뿐입니다.
class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key, required this.controller});

  final StatusController controller;

  /// 그래프에 표시할 범위(초). 기존과 동일하게 60초.
  static const int _windowSeconds = 60;

  // 기록된 시각을 "지금으로부터 몇 초 전" (x = -60 ~ 0) 으로 바꿉니다.
  List<FlSpot> _cpuSpots() {
    final DateTime now = DateTime.now();
    final List<FlSpot> spots = <FlSpot>[];
    for (final UsageSample sample in controller.history) {
      final double? cpu = sample.cpu;
      if (cpu == null) continue;
      final double secondsAgo = now.difference(sample.time).inMilliseconds / 1000.0;
      if (secondsAgo > _windowSeconds) continue;
      final double x = secondsAgo < 0 ? 0.0 : -secondsAgo;
      spots.add(FlSpot(x, cpu.clamp(0.0, 100.0)));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          final LinkStatus status = controller.linkStatus;
          final List<FlSpot> spots = _cpuSpots();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: <Widget>[
              ScreenTitle(
                title: '사용량 추이',
                subtitle: '최근 $_windowSeconds초 동안 받은 실제 데이터입니다.',
                trailing: ConnectionStatusBadge(status: status),
              ),
              const SizedBox(height: 16),
              UpmCard(
                title: 'CPU 사용량 추이 (실시간)',
                icon: Icons.show_chart_rounded,
                accent: UpmColors.green,
                child: spots.isEmpty
                    ? const _EmptyChart()
                    : SizedBox(height: 220, child: _CpuChart(spots: spots, windowSeconds: _windowSeconds)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Center(
        child: Text(
          '표시할 데이터가 없습니다.\nPC에서 데이터가 들어오면 그래프가 그려집니다.',
          textAlign: TextAlign.center,
          style: TextStyle(color: UpmColors.textMuted, fontSize: 13, height: 1.5),
        ),
      ),
    );
  }
}

class _CpuChart extends StatelessWidget {
  const _CpuChart({required this.spots, required this.windowSeconds});

  final List<FlSpot> spots;
  final int windowSeconds;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        minX: -windowSeconds.toDouble(),
        maxX: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (double value) {
            return const FlLine(color: Colors.white10, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 15,
              getTitlesWidget: (double value, TitleMeta meta) {
                const Map<int, String> labels = <int, String>{
                  -60: '-60s',
                  -45: '-45s',
                  -30: '-30s',
                  -15: '-15s',
                  0: 'Now',
                };
                final String? label = labels[value.round()];
                if (label == null) return const SizedBox.shrink();
                return Text(
                  label,
                  style: const TextStyle(color: Colors.white30, fontSize: 9),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 25,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.round()}',
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.15,
            color: UpmColors.green,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: UpmColors.green.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.linear,
    );
  }
}
