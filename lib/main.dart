import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'status_controller.dart';
import 'theme.dart';

void main() {
  runApp(const UpmApp());
}

class UpmApp extends StatefulWidget {
  const UpmApp({super.key, this.controller});

  /// 테스트에서 가짜 서버를 쓰는 컨트롤러를 넣을 때만 사용합니다.
  /// 비워 두면 앱이 직접 만들고 1초 폴링을 시작합니다.
  final StatusController? controller;

  @override
  State<UpmApp> createState() => _UpmAppState();
}

class _UpmAppState extends State<UpmApp> {
  late final StatusController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    final StatusController? injected = widget.controller;
    if (injected != null) {
      _controller = injected;
      _ownsController = false;
    } else {
      _controller = StatusController()..start();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPM Mobile App',
      debugShowCheckedModeBanner: false, // 오른쪽 위 디버그 띠 제거
      theme: buildUpmTheme(),
      // 휴대폰 '글자 크기' 설정이 커도 디자인 비율이 무너지지 않도록 글자 배율을 최대 1.0 으로 고정합니다.
      builder: (BuildContext context, Widget? child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: child ?? const SizedBox.shrink(),
      ),
      home: AppShell(controller: _controller), // 첫 화면: 하단 탭의 홈
    );
  }
}
