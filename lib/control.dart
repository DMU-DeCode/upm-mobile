import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class ControlService {
  // 서버 주소는 config.dart 한 곳에서 관리합니다.
  static const String baseUrl = AppConfig.baseUrl;

  // 시스템 최적화 명령 전송 함수
  static Future<bool> optimizeSystem() async {
    try {
      final url = Uri.parse('$baseUrl/optimize'); // 서버에 작성한 최적화 API 경로
      
      // 서버로 최적화 신호 보냄
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint("Optimization Success");
        return true;
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Connection Failed: $e");
      return false;
    }
  }

  // PC 전원 끄기 명령 전송 함수
  static Future<bool> shutdownSystem() async {
    try {
      final url = Uri.parse('$baseUrl/shutdown');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint("Shutdown Success");
        return true;
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Connection Failed: $e");
      return false;
    }
  }

  // PC 재시작 명령 전송 함수
  static Future<bool> restartSystem() async {
    try {
      final url = Uri.parse('$baseUrl/restart');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint("Restart Success");
        return true;
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Connection Failed: $e");
      return false;
    }
  }
}
