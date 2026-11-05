import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'optimize_button.dart';
import 'upm_card.dart';

/// 빠른 최적화 메인 액션 카드 (홈 · 제어 화면 공통).
///
/// 왼쪽: 유리 질감의 로켓 일러스트 / 오른쪽: 안내 문구 + 오른쪽 정렬된 "최적화 실행" 버튼.
class QuickOptimizeCard extends StatelessWidget {
  const QuickOptimizeCard({super.key, this.title});

  /// 주면 카드 위쪽에 제목 줄이 붙습니다 (예: 제어 화면의 "빠른 최적화").
  final String? title;

  @override
  Widget build(BuildContext context) {
    return UpmCard(
      title: title,
      icon: title == null ? null : Icons.bolt_rounded,
      padding: const EdgeInsets.fromLTRB(8, 18, UpmSpace.card, 16),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // 시안 비율: 왼쪽 일러스트 약 37%, 오른쪽 글·버튼 약 63%.
          // 화면이 좁아도 일러스트가 너무 작아지거나, 글 영역이 좁아지지 않도록 범위를 정합니다.
          final double illustration = (constraints.maxWidth * 0.37).clamp(92.0, 128.0);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _RocketIllustration(size: illustration),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // 항상 한 줄. 공간이 모자랄 때만 글자 크기를 살짝 줄입니다 (줄바꿈·잘림 없음).
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('지금 바로 최적화해보세요!', maxLines: 1, softWrap: false, style: UpmText.headline),
                    ),
                    SizedBox(height: 7),
                    Text(
                      '불필요한 프로세스를 정리하고\nPC를 더 쾌적하게 만들어 드려요.',
                      style: TextStyle(color: UpmColors.textSecondary, fontSize: 11.5, height: 1.45),
                    ),
                    SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OptimizeButton(compact: true),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 유리 큐브 위의 로켓 + 둘러싼 고리 + 반짝임.
class _RocketIllustration extends StatelessWidget {
  const _RocketIllustration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double cube = size * 0.62;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          // 바닥의 은은한 빛
          Positioned(
            bottom: size * 0.06,
            child: Container(
              width: size * 0.8,
              height: size * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[UpmColors.blueBright.withValues(alpha: 0.22), Colors.transparent],
                ),
              ),
            ),
          ),
          // 뒤쪽 고리
          CustomPaint(size: Size(size, size), painter: _RingPainter(front: false)),
          // 유리 큐브
          Transform.rotate(
            angle: -0.12,
            child: Container(
              width: cube,
              height: cube,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cube * 0.28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFF4F8FF), Color(0xFFCFDDFF), Color(0xFFB9CCFF)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x333B82F6), blurRadius: 18, offset: Offset(0, 10)),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) => const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: <Color>[Color(0xFF60A5FA), UpmColors.blue],
                  ).createShader(bounds),
                  child: Icon(Icons.rocket_launch_rounded, size: cube * 0.56, color: Colors.white),
                ),
              ),
            ),
          ),
          // 앞쪽 고리
          CustomPaint(size: Size(size, size), painter: _RingPainter(front: true)),
          // 반짝임
          Positioned(
            top: size * 0.04,
            right: size * 0.04,
            child: const Icon(Icons.auto_awesome, size: 16, color: UpmColors.blueBright),
          ),
        ],
      ),
    );
  }
}

/// 큐브를 비스듬히 감싸는 타원 고리. 뒤쪽 절반과 앞쪽 절반을 나눠 그려 입체감을 냅니다.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.front});

  final bool front;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.62);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.28);
    final Rect oval = Rect.fromCenter(center: Offset.zero, width: size.width * 0.98, height: size.height * 0.3);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: <Color>[
          Colors.white.withValues(alpha: front ? 0.95 : 0.6),
          const Color(0xFFBFD3FF).withValues(alpha: front ? 0.9 : 0.5),
        ],
      ).createShader(oval);
    // 앞쪽: 아래 절반(0 ~ π), 뒤쪽: 위 절반(π ~ 2π)
    canvas.drawArc(oval, front ? 0 : math.pi, math.pi, false, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.front != front;
}
