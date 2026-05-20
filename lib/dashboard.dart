import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:upm_app/control.dart'; // control.dart에서 최적화 함수 가져오기
import 'package:fl_chart/fl_chart.dart';
import 'package:upm_app/usage.dart'; // usage.dart에서 과거 데이터 함수 가져오기
// 전역 또는 상태 변수 공간에 그래프 데이터 배열 추가 (처음엔 빈 리스트)
List<FlSpot> _cpuChartSpots = [];
int _maxX = 60; // 그래프에 표시할 최대 데이터 점의 수 (예: 60초)

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _cpu = 0.0;
  double _ram = 0.0;
  double _gpu = 0.0;
  double _gpuTemp = 0.0;
  double _ramUsed = 0.0;
  double _ramTotal = 0.0;
  Timer? _timer;
  List<FlSpot> _cpuChartSpots = [];
  final int _maxX = 60;
  bool _showCpuChart = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // 1초마다 실시간 데이터를 가져오면서 그래프도 같이 업데이트합니다.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _fetchStatus());
  }

  Future<void> _fetchStatus() async {
    try {
      final url = Uri.parse('https://powdering-carry-uneasy.ngrok-free.dev/status');
      final response = await http.get(url).timeout(const Duration(milliseconds: 800));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cpu = (data['cpu'] ?? 0.0).toDouble();
          _ram = (data['ram'] ?? 0.0).toDouble();
          _gpu = (data['gpu'] ?? 0.0).toDouble();
          _gpuTemp = (data['gpu_temp'] ?? 0.0).toDouble();
          _ramUsed = (data['ram_used'] ?? 0.0).toDouble();
          _ramTotal = (data['ram_total'] ?? 0.0).toDouble();

          // 기존 점들을 1초씩 과거로 밀고 (x-1), 새 데이터를 x=0(Now)에 추가
          _cpuChartSpots = _cpuChartSpots.map((s) => FlSpot(s.x - 1, s.y)).toList();
          _cpuChartSpots.add(FlSpot(0, _cpu));
          // -_maxX보다 오래된 점 제거
          _cpuChartSpots.removeWhere((s) => s.x < -_maxX);
        });
      }
    } catch (e) {
      debugPrint("Sync Failed: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // PC 코드의 SKColor 보간 로직을 Dart로 이식
  Color getUsageHeatColor(double percent) {
    double v = percent.clamp(0.0, 100.0);
    double u = v / 25.0;

    const g = Color(0xFF34C759); // Green
    const y = Color(0xFFFFD60A); // Yellow
    const o = Color(0xFFFF9F0A); // Orange
    const r = Color(0xFFFF453A); // Red

    if (u <= 1) return _lerpColor(g, y, u);
    if (u <= 2) return _lerpColor(y, o, u - 1);
    if (u <= 3) return _lerpColor(o, r, u - 2);
    return r;
  }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.fromARGB(
      255,
      (a.red + (b.red - a.red) * t).round(),
      (a.green + (b.green - a.green) * t).round(),
      (a.blue + (b.blue - a.blue) * t).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("UPM MOBILE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            // 1. 실시간 모니터 카드 (기존 유지)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("실시간 모니터", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeatGauge("CPU 사용률", _cpu),
                      _buildHeatGauge(
                        "메모리 사용률", _ram,
                        detail: _ramTotal > 0
                            ? "${_ramUsed.toStringAsFixed(1)}GB / ${_ramTotal.toStringAsFixed(0)}GB"
                            : null,
                      ),
                      _buildHeatGauge("GPU 사용률", _gpu, temp: _gpuTemp),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. CPU 사용량 추이 그래프 카드 (토글)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showCpuChart = !_showCpuChart),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("CPU 사용량 추이 (실시간)",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Icon(
                          _showCpuChart ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  if (_showCpuChart) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          minX: -_maxX.toDouble(),
                          maxX: 0,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (value) {
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
                                  const labels = <int, String>{
                                    -60: '-60s',
                                    -45: '-45s',
                                    -30: '-30s',
                                    -15: '-15s',
                                    0: 'Now',
                                  };
                                  final label = labels[value.round()];
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
                                    "${value.round()}",
                                    style: const TextStyle(color: Colors.white30, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineTouchData: const LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _cpuChartSpots,
                              isCurved: true,
                              curveSmoothness: 0.15,
                              color: const Color(0xFF34C759),
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF34C759).withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.linear,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. 빠른 제어 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("빠른 제어",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        bool success = await ControlService.optimizeSystem();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? "🚀 시스템 최적화가 완료되었습니다!" : "❌ 최적화 요청에 실패했습니다."),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.speed),
                      label: const Text("빠른 최적화",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF34C759),
                        side: const BorderSide(color: Color(0xFF34C759), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E1E),
                            title: const Text("전원 끄기", style: TextStyle(color: Colors.white)),
                            content: const Text("PC를 종료하시겠습니까?", style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("취소", style: TextStyle(color: Colors.white70)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("종료", style: TextStyle(color: Color(0xFFFF453A))),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final success = await ControlService.shutdownSystem();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? "PC를 종료합니다." : "❌ 전원 끄기 요청에 실패했습니다."),
                                backgroundColor: success ? const Color(0xFFFF453A) : Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text("전원 끄기",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF453A),
                        side: const BorderSide(color: Color(0xFFFF453A), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
              ],
            ),
      ),
    );
  }

Widget _buildHeatGauge(String label, double value, {double? temp, String? detail}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: CustomPaint(
                painter: GaugePainter(
                  percent: value / 100,
                  trackColor: const Color(0xFF4C4E56),
                ),
              ),
            ),
            Column(
              children: [
                Text("${value.toInt()}%",
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                if (temp != null)
                  Text(
                    temp < 1.0 ? "N/A" : "${temp.toInt()}°C",
                    style: const TextStyle(color: Colors.white54, fontSize: 9),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: getUsageHeatColor(value), shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      const SizedBox(height: 3),
      Text(
        detail ?? "",
        style: const TextStyle(color: Colors.white38, fontSize: 9),
      ),
    ],
  );
}
}

class GaugePainter extends CustomPainter {
  final double percent;
  final Color trackColor;

  GaugePainter({required this.percent, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const startAngle = 0.75 * math.pi; // 시작 지점 (7시 방향)
    const sweepAngle = 1.5 * math.pi;  // 270도 (호의 총 길이)

    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. 배경 트랙
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    // 2. 그라데이션 레이어 (물리적 차단 버전)
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: const [
          Color(0xFF34C759), // 0% (초록)
          Color(0xFFFFD60A), // 25% (노랑)
          Color(0xFFFF9F0A), // 50% (주황)
          Color(0xFFFF453A), // 75% (빨강)
          Color(0xFF34C759), // 75.1% 이후를 다시 초록으로 덮어서 시작점 노이즈 제거
        ],
        // 0.75(270도) 지점 이후에 아주 미세한 간격을 두고 색상을 바꿔버림
        stops: const [0.0, 0.25, 0.5, 0.74, 0.75], 
        transform: GradientRotation(startAngle), 
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * percent, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) => oldDelegate.percent != percent;
}