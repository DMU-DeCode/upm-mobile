import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class UsageScreen extends StatelessWidget {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1E28),
      appBar: AppBar(
        title: const Text(
          "Resource History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CPU Usage Trend (Past 12 Hours)",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Average: 32.5%",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          // 방법 2: 실제 시간(오후/오전) 레이블 배열
                          // 0(현재)부터 2시간 간격으로 과거 시간을 매칭
                          const hours = ['8PM', '6PM', '4PM', '2PM', '12PM', '10AM', '8AM'];
                          
                          int index = (value / 2).toInt();
                          if (value % 2 == 0 && index < hours.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: Text(
                                hours[index],
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 30),  // 현재 (8PM)
                        FlSpot(2, 42),  // 2시간 전 (6PM)
                        FlSpot(4, 50),  // 4시간 전 (4PM)
                        FlSpot(6, 45),  // 6시간 전 (2PM)
                        FlSpot(8, 25),  // 8시간 전 (12PM)
                        FlSpot(10, 10), // 10시간 전 (10AM)
                      ],
                      isCurved: true,
                      color: const Color(0xFF4AF699),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true), // 실제 시간대 포인트를 강조하기 위해 점 표시
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF4AF699).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}