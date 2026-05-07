import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'usage.dart';
import 'control.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 실시간 수치를 담을 변수 (0.0 ~ 1.0)
  double _cpuPercent = 0.0;
  double _ramPercent = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 즉시 첫 데이터 요청
    _fetchStatus();
    // [수정] 2초에서 1초(Duration(seconds: 1))마다 반복 실행으로 변경
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel(); // 화면을 나갈 때 타이머를 종료하여 메모리 누수 방지
    super.dispose();
  }

  // 서버에서 데이터를 가져오는 핵심 함수
  Future<void> _fetchStatus() async {
    try {
      // 맥북의 IP 주소와 포트 (사용자님의 환경에 맞게 유지)
      final url = Uri.parse('http://192.168.35.122:8000/status'); 
      // 1초 주기에 맞춰 타임아웃을 800ms로 설정하여 요청이 밀리지 않게 함
      final response = await http.get(url).timeout(const Duration(milliseconds: 800));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // 서버 응답 수치를 0.0 ~ 1.0 범위로 변환
          _cpuPercent = (data['cpu'] ?? 0.0) / 100.0;
          _ramPercent = (data['ram'] ?? 0.0) / 100.0;
        });
      }
    } catch (e) {
      debugPrint("데이터 동기화 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1E28), // 어두운 테마 배경
      appBar: AppBar(
        title: const Text(
          "UPM Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. 애니메이션 게이지 영역
            Row(
              children: [
                _buildGaugeCard("CPU", _cpuPercent, Colors.cyanAccent),
                const SizedBox(width: 15),
                _buildGaugeCard("RAM", _ramPercent, Colors.purpleAccent),
              ],
            ),
            const SizedBox(height: 30),

            // 2. 메뉴 타일 영역
            _buildMenuTile(
              context,
              icon: Icons.auto_graph_rounded,
              title: "Performance History",
              subtitle: "과거 리소스 사용량 추이 확인",
              color: Colors.blueAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UsageScreen())),
            ),
            const SizedBox(height: 15),
            _buildMenuTile(
              context,
              icon: Icons.power_settings_new_rounded,
              title: "System Control",
              subtitle: "원격 PC 전원 제어 및 관리",
              color: Colors.redAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ControlScreen())),
            ),
          ],
        ),
      ),
    );
  }

  // --- 부드러운 애니메이션 게이지 위젯 ---
  Widget _buildGaugeCard(String label, double percent, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF252936),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 15),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: percent),
                    // [수정] 1초 주기에 맞춰 애니메이션 속도를 0.5초(500ms)로 최적화
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: Colors.white10,
                        color: color,
                      );
                    },
                  ),
                ),
                // 숫자 텍스트 애니메이션
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Text(
                      "${(value * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 하단 메뉴 타일 위젯
  Widget _buildMenuTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF252936),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}