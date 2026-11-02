import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// 사용률(0~100)에 따른 색. PC 프로그램의 색 보간 로직을 그대로 옮긴 것입니다.
/// (기존 dashboard.dart 의 getUsageHeatColor 와 같은 결과)
Color usageHeatColor(double percent) {
  final double v = percent.clamp(0.0, 100.0);
  final double u = v / 25.0;

  if (u <= 1) return Color.lerp(UpmColors.green, UpmColors.yellow, u)!;
  if (u <= 2) return Color.lerp(UpmColors.yellow, UpmColors.orange, u - 1)!;
  if (u <= 3) return Color.lerp(UpmColors.orange, UpmColors.red, u - 2)!;
  return UpmColors.red;
}

/// CPU / 메모리 / GPU 원형 게이지 1개.
///
/// 주어진 폭 안에서 스스로 크기를 줄이므로, 화면이 좁아도 넘치지 않습니다.
class MetricGauge extends StatelessWidget {
  const MetricGauge({
    super.key,
    required this.label,
    required this.value,
    this.centerCaption,
    this.detail,
    this.maxDiameter = 84,
  });

  /// 게이지 아래 항목명 (예: "CPU 사용률").
  final String label;

  /// 사용률(0~100). 아직 받은 값이 없으면 null → "N/A" 로 표시합니다.
  final double? value;

  /// 숫자 바로 아래 작은 글씨 (예: GPU 온도).
  final String? centerCaption;

  /// 항목명 아래 보조 글씨 (예: "9.8GB / 16GB").
  final String? detail;

  final double maxDiameter;

  @override
  Widget build(BuildContext context) {
    final double? v = value;
    final String? caption = centerCaption;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available =
            constraints.maxWidth.isFinite ? constraints.maxWidth : maxDiameter;
        final double diameter = math.max(48.0, math.min(maxDiameter, available - 8));

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned.fill(
                    child: Padding(
                      // 선 굵기(8)의 절반만큼 안쪽으로 그려 원이 잘리지 않게 합니다.
                      padding: const EdgeInsets.all(4),
                      child: CustomPaint(
                        painter: GaugePainter(
                          percent: v == null ? 0.0 : (v / 100).clamp(0.0, 1.0),
                          trackColor: UpmColors.track,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: diameter * 0.2),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            v == null ? 'N/A' : '${v.toInt()}%',
                            style: TextStyle(
                              color: v == null ? UpmColors.textMuted : UpmColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (caption != null)
                            Text(
                              caption,
                              style: const TextStyle(color: UpmColors.textSecondary, fontSize: 9),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: v == null ? UpmColors.textMuted : usageHeatColor(v),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: UpmColors.textSecondary, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              detail ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: UpmColors.textMuted, fontSize: 9),
            ),
          ],
        );
      },
    );
  }
}

/// 270도 호 형태의 게이지를 그립니다. (기존 dashboard.dart 에서 그대로 옮김)
class GaugePainter extends CustomPainter {
  GaugePainter({required this.percent, required this.trackColor});

  final double percent;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    const double startAngle = 0.75 * math.pi; // 시작 지점 (7시 방향)
    const double sweepAngle = 1.5 * math.pi; // 270도 (호의 총 길이)

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // 1. 배경 트랙
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    // 받은 값이 없거나 0% 이면 채움 부분은 그리지 않습니다.
    // (둥근 선 끝 때문에 0% 에서도 점이 찍혀 보이는 것을 막습니다.)
    if (percent <= 0) return;

    // 2. 그라데이션 레이어
    final Paint activePaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: <Color>[
          Color(0xFF34C759), // 0% (초록)
          Color(0xFFFFD60A), // 25% (노랑)
          Color(0xFFFF9F0A), // 50% (주황)
          Color(0xFFFF453A), // 75% (빨강)
          Color(0xFF34C759), // 이후를 다시 초록으로 덮어 시작점 노이즈 제거
        ],
        stops: <double>[0.0, 0.25, 0.5, 0.74, 0.75],
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * percent, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.trackColor != trackColor;
}
