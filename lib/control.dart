import 'package:http/http.dart' as http;
import 'dart:convert';

class ControlService {
  // 서버 주소 (ngrok 주소 사용)
  static const String baseUrl = 'https://powdering-carry-uneasy.ngrok-free.dev';

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
        print("Optimization Success");
        return true;
      } else {
        print("Server Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Connection Failed: $e");
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
        print("Shutdown Success");
        return true;
      } else {
        print("Server Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Connection Failed: $e");
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
        print("Restart Success");
        return true;
      } else {
        print("Server Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Connection Failed: $e");
      return false;
    }
  }
}
