import 'package:flutter/material.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  void _confirmShutdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("PC 종료 명령"),
        content: const Text("대상 PC를 지금 종료하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          ElevatedButton(
            onPressed: () {
              // 여기에 shutdown API 호출 코드 작성
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("종료 실행"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Remote Control")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_settings_new, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmShutdown(context),
              child: const Text("Power Off PC"),
            ),
          ],
        ),
      ),
    );
  }
}