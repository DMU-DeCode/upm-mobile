import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

/// 화면에 보여 줄 연결 상태.
enum LinkStatus {
  /// 앱을 켠 직후, 아직 서버 응답을 받지 못한 상태.
  connecting,

  /// 서버에 연결됐고 PC 데이터도 들어오는 상태.
  connected,

  /// 서버에는 연결됐지만 PC 프로그램에서 새 데이터가 오지 않는 상태.
  pcIdle,

  /// 서버에 연결할 수 없는 상태.
  disconnected,
}

enum _ServerLink { connecting, connected, disconnected }

enum _PcLink { unknown, live, stale, noData }

/// 그래프용 사용률 기록 1건. 서버에서 실제로 받은 값만 담습니다.
class UsageSample {
  const UsageSample({required this.time, this.cpu, this.ram, this.gpu});

  /// 휴대폰이 이 값을 받은 시각.
  final DateTime time;
  final double? cpu;
  final double? ram;
  final double? gpu;
}

/// PC 상태를 서버에서 주기적으로 받아 와 보관하는 컨트롤러.
///
/// 기존에는 dashboard.dart 의 State 안에 있던 1초 폴링(Timer.periodic → GET /status)을
/// 화면 밖으로 옮긴 것입니다. 하단 탭의 모든 화면이 이 컨트롤러 하나를 함께 봅니다.
///
/// 사용하는 API (모두 기존 서버에 있는 것이며 요청/응답 형식을 바꾸지 않습니다):
///  - GET /status              : CPU / RAM / GPU 실시간 값 (기존과 동일)
///  - GET /api/v1/logs?limit=1 : 가장 최근 로그 1건 → PC 이름(machineId), 수신 여부 판단
class StatusController extends ChangeNotifier {
  /// [client] 와 [clock] 은 테스트에서 가짜 서버·가짜 시계를 넣기 위한 것입니다.
  StatusController({http.Client? client, DateTime Function()? clock})
      : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _clock = clock ?? DateTime.now;

  final http.Client _client;
  final bool _ownsClient;
  final DateTime Function() _clock;

  Timer? _timer;
  bool _disposed = false;
  bool _statusInFlight = false;
  bool _pcInfoInFlight = false;
  int _failures = 0;
  DateTime? _lastPcInfoAttempt;
  Object? _lastLogId;
  DateTime? _lastLogChangeAt;

  _ServerLink _serverLink = _ServerLink.connecting;
  _PcLink _pcLink = _PcLink.unknown;

  double? _cpu;
  double? _ram;
  double? _gpu;
  double? _gpuTemp;
  double? _ramUsedGb;
  double? _ramTotalGb;
  String? _machineId;
  DateTime? _lastSuccessAt;
  DateTime? _lastTelemetryAt;
  final List<UsageSample> _history = <UsageSample>[];

  /// CPU 사용률(%). 아직 받은 값이 없으면 null.
  double? get cpu => _cpu;

  /// 메모리 사용률(%). 아직 받은 값이 없으면 null.
  double? get ram => _ram;

  /// GPU 사용률(%). 아직 받은 값이 없으면 null.
  double? get gpu => _gpu;

  /// GPU 온도(°C). 서버가 값을 주지 않거나 1 미만이면 null (기존의 "N/A" 기준과 동일).
  double? get gpuTemp => _gpuTemp;

  /// 사용 중인 메모리(GB). 값이 없으면 null.
  double? get ramUsedGb => _ramUsedGb;

  /// 전체 메모리(GB). 값이 없으면 null.
  double? get ramTotalGb => _ramTotalGb;

  /// PC 이름. 서버가 알려 주기 전에는 null.
  String? get machineId => _machineId;

  /// 휴대폰 시계 기준, /status 를 마지막으로 정상 수신한 시각.
  DateTime? get lastSuccessAt => _lastSuccessAt;

  /// PC 시계 기준, 서버에 저장된 가장 최근 데이터의 시각.
  DateTime? get lastTelemetryAt => _lastTelemetryAt;

  /// 최근 사용률 기록 (오래된 것 → 최신 순).
  List<UsageSample> get history => UnmodifiableListView<UsageSample>(_history);

  /// 화면에 보여 줄 연결 상태.
  LinkStatus get linkStatus {
    return switch (_serverLink) {
      _ServerLink.connecting => LinkStatus.connecting,
      _ServerLink.disconnected => LinkStatus.disconnected,
      _ServerLink.connected =>
        (_pcLink == _PcLink.stale || _pcLink == _PcLink.noData)
            ? LinkStatus.pcIdle
            : LinkStatus.connected,
    };
  }

  /// 폴링 시작. 즉시 한 번 가져온 뒤 1초마다 반복합니다.
  void start() {
    if (_timer != null || _disposed) return;
    _tick();
    _timer = Timer.periodic(AppConfig.pollInterval, (Timer timer) => _tick());
  }

  /// 폴링 중지.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 지금 바로 한 번 더 가져옵니다 (당겨서 새로고침용).
  Future<void> refresh() async {
    await Future.wait<void>(<Future<void>>[_fetchStatus(), _fetchPcInfo()]);
  }

  /// "다시 연결" 버튼용. 상태를 "연결 중"으로 되돌리고 즉시 다시 시도합니다.
  Future<void> reconnect() async {
    if (_disposed) return;
    _failures = 0;
    _serverLink = _ServerLink.connecting;
    notifyListeners();
    await refresh();
  }

  void _tick() {
    unawaited(_fetchStatus());
    final DateTime now = _clock();
    final DateTime? last = _lastPcInfoAttempt;
    if (last == null || now.difference(last) >= AppConfig.pcInfoInterval) {
      unawaited(_fetchPcInfo());
    }
  }

  // 실시간 값 조회 — 기존 dashboard.dart 의 _fetchStatus 와 같은 요청입니다.
  Future<void> _fetchStatus() async {
    if (_statusInFlight || _disposed) return;
    _statusInFlight = true;
    bool ok = false;
    try {
      final http.Response response = await _client
          .get(Uri.parse('${AppConfig.baseUrl}/status'))
          .timeout(AppConfig.statusTimeout);
      if (!_disposed && response.statusCode == 200) {
        final Object? data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          _applyStatus(data);
          ok = true;
        }
      }
    } catch (e) {
      debugPrint('Sync Failed: $e');
    } finally {
      _statusInFlight = false;
    }
    if (_disposed) return;

    if (ok) {
      _failures = 0;
      _serverLink = _ServerLink.connected;
      _lastSuccessAt = _clock();
    } else {
      _failures += 1;
      if (_failures >= AppConfig.disconnectAfterFailures) {
        _serverLink = _ServerLink.disconnected;
      }
    }
    notifyListeners();
  }

  void _applyStatus(Map<String, dynamic> data) {
    _cpu = _toDouble(data['cpu']);
    _ram = _toDouble(data['ram']);
    _gpu = _toDouble(data['gpu']);
    _ramUsedGb = _toDouble(data['ram_used']);
    _ramTotalGb = _toDouble(data['ram_total']);

    // 앱은 원래 'gpu_temp' 를 읽었고, 현재 서버는 'gpuTemp' 로 보냅니다. 둘 다 받습니다.
    final double? temp = _toDouble(data['gpu_temp'] ?? data['gpuTemp']);
    _gpuTemp = (temp != null && temp >= 1.0) ? temp : null;

    // PC 프로그램이 꺼져 있어도 /status 는 마지막 값을 계속 돌려줍니다.
    // 그 값을 그래프에 계속 그리면 실제 측정값처럼 보이므로, PC 데이터가
    // 들어오지 않는 동안에는 기록하지 않습니다.
    final bool pcSilent = _pcLink == _PcLink.stale || _pcLink == _PcLink.noData;
    if (!pcSilent && (_cpu != null || _ram != null || _gpu != null)) {
      final DateTime now = _clock();
      _history.add(UsageSample(time: now, cpu: _cpu, ram: _ram, gpu: _gpu));
      final DateTime cutoff = now.subtract(AppConfig.historyWindow);
      _history.removeWhere((UsageSample s) => s.time.isBefore(cutoff));
    }
  }

  // PC 이름과 "PC 에서 데이터가 실제로 오고 있는지"를 확인합니다.
  Future<void> _fetchPcInfo() async {
    if (_pcInfoInFlight || _disposed) return;
    _pcInfoInFlight = true;
    _lastPcInfoAttempt = _clock();
    try {
      final http.Response response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/api/v1/logs?limit=1'),
        headers: const <String, String>{'ngrok-skip-browser-warning': 'true'},
      ).timeout(AppConfig.pcInfoTimeout);
      if (!_disposed && response.statusCode == 200) {
        final Object? body = json.decode(utf8.decode(response.bodyBytes));
        if (body is List) {
          _applyPcInfo(body);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('PC Info Failed: $e');
    } finally {
      _pcInfoInFlight = false;
    }
  }

  void _applyPcInfo(List<dynamic> rows) {
    final DateTime now = _clock();
    if (rows.isEmpty) {
      // 서버 DB 에 수집된 데이터가 한 건도 없음.
      _pcLink = _PcLink.noData;
      return;
    }
    final Object? row = rows.first;
    if (row is! Map) return;

    final Object? name = row['machineId'];
    if (name is String && name.isNotEmpty) {
      _machineId = name;
    }

    final Object? rawTime = row['timestamp'];
    final DateTime? telemetryAt = rawTime is String ? DateTime.tryParse(rawTime) : null;
    if (telemetryAt != null) {
      _lastTelemetryAt = telemetryAt;
    }

    // 새 데이터가 저장될 때마다 로그 id 가 바뀝니다. id 가 바뀌는지를 보면
    // PC 와 휴대폰의 시계가 달라도 "지금 데이터가 오고 있는지"를 알 수 있습니다.
    final Object? id = row['id'];
    if (_lastLogId == null) {
      // 처음 확인할 때만, 저장된 시각이 최근인지로 우선 추정합니다.
      _lastLogId = id;
      final bool looksFresh = telemetryAt != null &&
          now.difference(telemetryAt).abs() <= AppConfig.pcFreshTolerance;
      _lastLogChangeAt = looksFresh ? now : null;
    } else if (id != _lastLogId) {
      _lastLogId = id;
      _lastLogChangeAt = now;
    }

    final DateTime? changedAt = _lastLogChangeAt;
    final bool live =
        changedAt != null && now.difference(changedAt) <= AppConfig.pcStaleAfter;
    _pcLink = live ? _PcLink.live : _PcLink.stale;
  }

  static double? _toDouble(Object? value) => value is num ? value.toDouble() : null;

  @override
  void dispose() {
    _disposed = true;
    stop();
    if (_ownsClient) {
      _client.close();
    }
    super.dispose();
  }
}
