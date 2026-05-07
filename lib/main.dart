import 'package:flutter/material.dart';
import 'dashboard.dart'; // 대시보드 파일과 연결

void main() {
  runApp(const MaterialApp(
    title: 'UPM Mobile App',
    home: DashboardScreen(), // 첫 화면을 DashboardScreen으로 설정
    debugShowCheckedModeBanner: false, // 오른쪽 위 디버그 띠 제거
  ));
}