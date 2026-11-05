import 'package:flutter/material.dart';

import '../assets.dart';

/// 상단 헤더의 UPM 로고.
///
/// 제공된 로고 이미지(배경 투명)를 비율 그대로(BoxFit.contain) 표시합니다.
/// 이미지를 다시 그리거나 글자로 대신하지 않습니다. 파일 경로는 [AppAssets.logo] 에서 바꿀 수 있습니다.
class UpmLogo extends StatelessWidget {
  const UpmLogo({super.key, this.height = 64});

  /// 로고 높이. 너비는 이미지 비율에 맞춰 자동으로 정해집니다.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'UPM 로고',
      // 파일이 없거나 경로가 틀려도 앱이 멈추지 않도록, 같은 높이의 빈 자리만 남깁니다.
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        debugPrint('UPM 로고를 불러오지 못했습니다 (${AppAssets.logo}): $error');
        return SizedBox(height: height);
      },
    );
  }
}
