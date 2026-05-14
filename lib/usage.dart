import 'package:http/http.dart' as http;
import 'dart:convert';

class UsageService {
  static const String baseUrl = 'https://powdering-carry-uneasy.ngrok-free.dev';

  // 과거 데이터 내역을 가져오는 함수
  static Future<List<Map<String, dynamic>>> getUsageHistory() async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/metrics/history');
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        // List<Map<String, dynamic>> 형태로 캐스팅하여 반환
        return body.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print("History Fetch Failed: $e");
      return [];
    }
  }
}