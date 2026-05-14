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
  Timer? _timer;
  List<FlSpot> _cpuChartSpots = [];
  final int _maxX = 60;

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

          // 🚀 [여기서부터 추가] 실시간 그래프 데이터 누적 로직
          // 1. 현재 CPU 값을 그래프 점(FlSpot)으로 만들어 리스트 끝에 추가합니다.
          _cpuChartSpots.add(FlSpot(_cpuChartSpots.length.toDouble(), _cpu));

          // 2. 만약 데이터가 너무 많아지면(예: 60개 초과), 맨 왼쪽(가장 오래된) 데이터를 버립니다.
          if (_cpuChartSpots.length > _maxX) {
            _cpuChartSpots.removeAt(0);
            
            // 3. 데이터가 왼쪽으로 밀려나는 효과를 주기 위해 X축 좌표를 0부터 다시 정렬합니다.
            _cpuChartSpots = _cpuChartSpots.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.y);
            }).toList();
          }
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
        padding: const EdgeInsets.all(16),
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
                    children: [
                      _buildHeatGauge("CPU", _cpu),
                      _buildHeatGauge("메모리", _ram),
                      _buildHeatGauge("GPU", _gpu, temp: _gpuTemp),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16), // 카드 사이 간격

            // 2. 빠른 최적화 버튼 (control.dart 로직 연결 예정)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                    // 1. 최적화 함수 실행
                    bool success = await ControlService.optimizeSystem();

                    // 2. 결과 알림창(SnackBar) 표시
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🚀 시스템 최적화가 완료되었습니다!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("❌ 최적화 요청에 실패했습니다."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                icon: const Icon(Icons.speed, color: Colors.black),
                label: const Text("빠른 최적화 실행", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34C759), // 강조용 초록색
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. 과거 사용량 추이 그래프 카드 (usage.dart 데이터 연결 수정)
            // 🚀 [수정] 윈도우 작업관리자 스타일의 부드러운 실시간 그래프 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // 기존 PC 카드색 유지
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("CPU 사용량 추이 (실시간)", 
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      
                      // 그래프 영역
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 100,
                            maxX: _maxX.toDouble(),
                            minX: 0,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false, // 세로선 제거
                              horizontalInterval: 25, // 25% 단위로 가로선
                              // 🚀 [수정] value 외에 하나가 더 필요하거나 구조가 바뀐 버전을 대응합니다.
                              getDrawingHorizontalLine: (value) {
                                return const FlLine(color: Colors.white10, strokeWidth: 1);
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // 아래 시간축 제거
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  // 🚀 [수정] 최신 fl_chart는 (value, meta)가 아니라 (value, titleMeta) 구조이거나 가끔 명시적 타입이 필요합니다.
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Text(
                                      "${value.toInt()}", 
                                      style: const TextStyle(color: Colors.white30, fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false), // 테두리 제거
                            lineTouchData: const LineTouchData(enabled: false), // 터치 Interaction 끄기
                            lineBarsData: [
                              LineChartBarData(
                                spots: _cpuChartSpots,
                                isCurved: true, // 🚀 곡선 활성화 (부드러운 움직임의 핵심)
                                curveSmoothness: 0.15, // 곡선의 부드러운 정도 조정 (0~1)
                                color: const Color(0xFF34C759), // 게이지와 같은 초록색
                                barWidth: 2,
                                dotData: const FlDotData(show: false), // 점 숨기기
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF34C759).withOpacity(0.1), // 하단 음영
                                ),
                              ),
                            ],
                          ),
                          // [팁] 실시간 업데이트 시 차트 전체가 깜빡이는 것을 방지하기 위해 사용
                          duration: const Duration(milliseconds: 250), // 애니메이션 지속 시간
                          curve: Curves.linear, // 일정한 속도로 움직이도록 설정
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

Widget _buildHeatGauge(String label, double value, {double? temp}) {
    // [수정] 이제 단일 색상을 전달하지 않고, Painter 내부에서 계산합니다.
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 85,
              height: 85,
              child: CustomPaint(
                painter: GaugePainter(
                  percent: value / 100,
                  trackColor: const Color(0xFF4C4E56), // PC 배경 회색 
                ),
              ),
            ),
            Column(
              children: [
                Text("${value.toInt()}%",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                if (temp != null)
                  Text("${temp.toInt()}°C",
                      style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // [수정] 현재 수치에 맞는 색상을 점에 표시
            Container(
              width: 8, height: 8, 
              decoration: BoxDecoration(color: getUsageHeatColor(value), shape: BoxShape.circle)
            ),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
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