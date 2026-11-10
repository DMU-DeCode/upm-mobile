/// 앱 전역 설정.
///
/// 서버(ngrok) 주소가 바뀌면 이 파일의 [baseUrl] 한 곳만 수정하면 됩니다.
/// (기존에는 dashboard.dart / control.dart / usage.dart 세 곳에 따로 적혀 있었습니다.)
class AppConfig {
  AppConfig._();

  static const String appName = 'UPM MOBILE';

  /// 앱 버전 표시용. pubspec.yaml 의 version 과 맞춰 주세요.
  static const String appVersion = '1.0.0';

  /// UPM 서버 주소 (ngrok 주소 사용).
  static const String baseUrl = 'https://attendee-sequence-blooper.ngrok-free.dev';

  /// /status 폴링 주기 — 기존과 동일하게 1초.
  static const Duration pollInterval = Duration(seconds: 1);

  /// /status 응답 대기 시간 — 기존과 동일하게 800ms.
  static const Duration statusTimeout = Duration(milliseconds: 800);

  /// /status 요청이 이 횟수만큼 연속으로 실패하면 "연결 안 됨"으로 표시합니다.
  /// (한 번의 지연으로 화면이 깜빡이지 않도록 여유를 둡니다.)
  static const int disconnectAfterFailures = 3;

  /// PC 이름·마지막 수신 정보(/api/v1/logs?limit=1) 조회 주기.
  static const Duration pcInfoInterval = Duration(seconds: 3);

  /// PC 이름·마지막 수신 정보 응답 대기 시간.
  static const Duration pcInfoTimeout = Duration(seconds: 3);

  /// PC 프로그램은 5초마다 서버로 데이터를 보냅니다.
  /// 이 시간 동안 새 데이터가 없으면 "PC 응답 없음"으로 표시합니다.
  static const Duration pcStaleAfter = Duration(seconds: 15);

  /// 앱을 켠 직후, 서버가 가진 마지막 데이터가 최근 것인지 판단할 때 허용하는
  /// PC 시계와 휴대폰 시계의 차이.
  static const Duration pcFreshTolerance = Duration(seconds: 60);

  /// 그래프용으로 보관하는 최근 데이터 범위 (그래프의 최대 선택 범위 '5분'과 같게).
  static const Duration historyWindow = Duration(minutes: 5);
}
