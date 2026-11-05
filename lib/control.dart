import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class ControlService {
  // 서버 주소는 config.dart 한 곳에서 관리합니다.
  static const String baseUrl = AppConfig.baseUrl;

  // 시스템 최적화 명령 전송 함수 (성공 여부만 필요할 때)
  static Future<bool> optimizeSystem() async {
    final OptimizeResult result = await requestOptimize();
    return result.success;
  }

  // 시스템 최적화 명령 전송 + 결과(정리한 프로세스 수, 실패 사유) 받기
  // 서버가 PC 프로그램에 전달해 실제 최적화를 실행하므로, 기다리는 시간을 넉넉히 둡니다.
  static Future<OptimizeResult> requestOptimize() async {
    try {
      final url = Uri.parse('$baseUrl/optimize'); // 서버에 작성한 최적화 API 경로

      // 서버로 최적화 신호 보냄
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 30));

      final Object? body = _decode(response.bodyBytes);
      if (response.statusCode == 200) {
        debugPrint("Optimization Success");
        final Object? cleared = body is Map ? body['clearedProcesses'] : null;
        return OptimizeResult(success: true, clearedCount: cleared is num ? cleared.toInt() : null);
      }
      debugPrint("Server Error: ${response.statusCode}");
      final Object? detail = body is Map ? body['detail'] : null;
      return OptimizeResult(success: false, message: detail is String ? detail : null);
    } catch (e) {
      debugPrint("Connection Failed: $e");
      return const OptimizeResult(success: false);
    }
  }

  static Object? _decode(List<int> bytes) {
    try {
      return json.decode(utf8.decode(bytes));
    } catch (_) {
      return null;
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

/// 빠른 최적화 요청 결과.
class OptimizeResult {
  const OptimizeResult({required this.success, this.clearedCount, this.message});

  final bool success;

  /// PC에서 정리한 프로세스 수. 서버가 알려 주지 않으면 null.
  final int? clearedCount;

  /// 실패했을 때 서버가 알려 준 사유. 없으면 null.
  final String? message;
}
