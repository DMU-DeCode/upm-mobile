import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// CPU / RAM / GPU 원형 게이지 1개.
///
/// 큰 숫자 + 작은 %, 아래에 아이콘과 항목명. 숫자가 바뀌면 링과 숫자가 부드럽게 따라 움직입니다.
/// 주어진 폭 안에서 스스로 크기를 줄이므로 화면이 좁아도 넘치지 않습니다.
class MetricGauge extends StatelessWidget {
  const MetricGauge({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.lightColor,
    this.caption,
    this.maxDiameter = 93, // 시안의 게이지 지름
  });

  /// 게이지 아래 항목명 (예: "CPU").
  final String label;

  /// 항목명 왼쪽 아이콘.
  final IconData icon;

  /// 사용률(0~100). 아직 받은 값이 없으면 null → "N/A" 로 표시합니다.
  final double? value;

  /// 링 끝 색 / 시작(연한) 색.
  final Color color;
  final Color lightColor;

  /// 항목명 아래 보조 글씨 (예: "9.8 / 16GB", "58°C"). 값이 없으면 표시하지 않습니다.
  final String? caption;

  final double maxDiameter;

  @override
  Widget build(BuildContext context) {
    final double? v = value;
    final String? captionText = caption;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available =
            constraints.maxWidth.isFinite ? constraints.maxWidth : maxDiameter;
        final double diameter = math.max(56.0, math.min(maxDiameter, available - 10));
        final double numberSize = diameter * 0.26; // 지름 93 → 숫자 24

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: diameter,
              height: diameter,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: v ?? 0),
                duration: UpmMotion.gauge,
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, double animated, Widget? child) {
                  return CustomPaint(
                    painter: RingGaugePainter(
                      percent: v == null ? 0 : (animated / 100).clamp(0.0, 1.0),
                      color: color,
                      lightColor: lightColor,
                      trackColor: const Color(0xFFEEF1FA),
                      strokeWidth: math.max(6.0, diameter * 0.08),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: diameter * 0.16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: v == null
                              ? Text(
                                  'N/A',
                                  style: TextStyle(
                                    color: UpmColors.textMuted,
                                    fontSize: numberSize * 0.75,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Text.rich(
                                  TextSpan(
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: '${animated.round()}',
                                        style: TextStyle(
                                          fontSize: numberSize,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '%',
                                        style: TextStyle(
                                          fontSize: numberSize * 0.54,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(color: Color(0xFF1B2559)),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 17, color: UpmColors.textPrimary),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: UpmColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (captionText != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                captionText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: UpmColors.textSecondary, fontSize: 10),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// 12시 방향에서 시계 방향으로 채워지는 원형 링 (연한 색 → 진한 색 그라데이션, 둥근 끝).
class RingGaugePainter extends CustomPainter {
  RingGaugePainter({
    required this.percent,
    required this.color,
    required this.lightColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double percent;
  final Color color;
  final Color lightColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 받은 값이 없거나 0% 이면 채움 부분은 그리지 않습니다.
    if (percent <= 0) return;

    const double start = -math.pi / 2;
    final double sweep = 2 * math.pi * percent;
    final Paint activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: <Color>[lightColor, color],
        stops: <double>[0, percent.clamp(0.02, 1.0)],
        transform: const GradientRotation(start),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant RingGaugePainter oldDelegate) =>
      oldDelegate.percent != percent ||
      oldDelegate.color != color ||
      oldDelegate.lightColor != lightColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
