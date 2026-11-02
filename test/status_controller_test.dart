// StatusController(폴링·연결 상태 판단) 단위 테스트.
//
// 실제 서버 대신 가짜 서버(MockClient)와 가짜 시계를 넣어서 확인합니다.
// 실행: flutter test

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:upm_app/status_controller.dart';

http.Response jsonResponse(Object body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: const <String, String>{'content-type': 'application/json'},
  );
}

/// 서버의 GET /status 응답과 같은 모양.
Map<String, Object> statusBody({Object cpu = 45.2, Object ram = 61, Object gpu = 32.0}) {
  return <String, Object>{
    'cpu': cpu,
    'ram': ram,
    'gpu': gpu,
    'gpuTemp': 0,
    'ram_used': 9.8,
    'ram_total': 16.0,
  };
}

/// 서버의 GET /api/v1/logs?limit=1 응답과 같은 모양.
List<Object> logsBody({required int id, required DateTime timestamp}) {
  return <Object>[
    <String, Object>{
      'id': id,
      'machineId': 'DESKTOP-TEST',
      'cpuUsage': 45.2,
      'ramUsage': 61.0,
      'gpuUsage': 32.0,
      'timestamp': timestamp.toIso8601String(),
    },
  ];
}

void main() {
  group('StatusController', () {
    test('서버가 응답하면 값이 반영되고 "연결됨"이 된다', () async {
      final DateTime now = DateTime(2026, 10, 8, 17, 0, 0);
      final StatusController controller = StatusController(
        clock: () => now,
        client: MockClient((http.Request request) async {
          if (request.url.path == '/status') {
            return jsonResponse(statusBody());
          }
          if (request.url.path == '/api/v1/logs') {
            return jsonResponse(logsBody(id: 1, timestamp: now));
          }
          return http.Response('', 404);
        }),
      );

      // 응답을 받기 전에는 0 이 아니라 "값 없음" 이어야 합니다.
      expect(controller.linkStatus, LinkStatus.connecting);
      expect(controller.cpu, isNull);

      await controller.refresh();

      expect(controller.linkStatus, LinkStatus.connected);
      expect(controller.cpu, 45.2);
      expect(controller.ram, 61.0);
      expect(controller.gpu, 32.0);
      expect(controller.gpuTemp, isNull); // 서버가 0 을 주면 N/A
      expect(controller.ramUsedGb, 9.8);
      expect(controller.ramTotalGb, 16.0);
      expect(controller.machineId, 'DESKTOP-TEST');
      expect(controller.lastSuccessAt, now);
      expect(controller.history, hasLength(1));

      controller.dispose();
    });

    test('연속으로 3번 실패해야 "연결 안 됨"이 된다', () async {
      final StatusController controller = StatusController(
        client: MockClient((http.Request request) async => http.Response('error', 500)),
      );

      await controller.refresh();
      expect(controller.linkStatus, LinkStatus.connecting);
      await controller.refresh();
      expect(controller.linkStatus, LinkStatus.connecting);
      await controller.refresh();
      expect(controller.linkStatus, LinkStatus.disconnected);

      // 연결에 실패했을 때 임의의 값(0 등)을 만들어 넣지 않습니다.
      expect(controller.cpu, isNull);
      expect(controller.history, isEmpty);

      controller.dispose();
    });

    test('끊긴 뒤 "다시 연결"하면 복구된다', () async {
      final DateTime now = DateTime(2026, 10, 8, 17, 0, 0);
      bool online = false;
      final StatusController controller = StatusController(
        clock: () => now,
        client: MockClient((http.Request request) async {
          if (!online) return http.Response('error', 500);
          if (request.url.path == '/status') {
            return jsonResponse(statusBody());
          }
          return jsonResponse(logsBody(id: 1, timestamp: now));
        }),
      );

      await controller.refresh();
      await controller.refresh();
      await controller.refresh();
      expect(controller.linkStatus, LinkStatus.disconnected);

      online = true;
      await controller.reconnect();
      expect(controller.linkStatus, LinkStatus.connected);
      expect(controller.cpu, 45.2);

      controller.dispose();
    });

    test('PC에서 새 데이터가 오지 않으면 "PC 응답 없음"이 되고 그래프에 기록하지 않는다', () async {
      DateTime now = DateTime(2026, 10, 8, 17, 0, 0);
      final DateTime oldTelemetry = DateTime(2026, 10, 8, 16, 0, 0); // 1시간 전 데이터
      int logId = 7;
      final StatusController controller = StatusController(
        clock: () => now,
        client: MockClient((http.Request request) async {
          if (request.url.path == '/status') {
            return jsonResponse(statusBody(cpu: 10, ram: 20, gpu: 30));
          }
          return jsonResponse(logsBody(id: logId, timestamp: oldTelemetry));
        }),
      );

      await controller.refresh();
      expect(controller.linkStatus, LinkStatus.pcIdle);
      final int recorded = controller.history.length;

      // 로그 id 가 그대로면(= PC 가 새 데이터를 보내지 않으면) 계속 "PC 응답 없음"
      now = now.add(const Duration(seconds: 3));
      await controller.refresh();
      expect(controller.linkStatus, LinkStatus.pcIdle);
      expect(controller.history, hasLength(recorded));

      // 로그 id 가 바뀌면(= PC 가 새 데이터를 보내면) "연결됨"
      logId = 8;
      now = now.add(const Duration(seconds: 3));
      await controller.refresh();
      expect(controller.linkStatus, LinkStatus.connected);

      // 그 뒤 15초 넘게 id 가 그대로면 다시 "PC 응답 없음"
      now = now.add(const Duration(seconds: 16));
      await controller.refresh();
      expect(controller.linkStatus, LinkStatus.pcIdle);

      controller.dispose();
    });

    test('GPU 온도는 gpu_temp / gpuTemp 두 이름을 모두 읽는다', () async {
      String key = 'gpu_temp';
      final StatusController controller = StatusController(
        client: MockClient((http.Request request) async {
          if (request.url.path == '/status') {
            return jsonResponse(<String, Object>{'cpu': 1, 'ram': 2, 'gpu': 3, key: 58.0});
          }
          return http.Response('', 404);
        }),
      );

      await controller.refresh();
      expect(controller.gpuTemp, 58.0);

      key = 'gpuTemp';
      await controller.refresh();
      expect(controller.gpuTemp, 58.0);

      // 서버가 주지 않는 값은 0 으로 채우지 않습니다.
      expect(controller.ramUsedGb, isNull);
      expect(controller.ramTotalGb, isNull);

      controller.dispose();
    });
  });
}
