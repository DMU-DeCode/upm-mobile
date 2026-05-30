<div align="center">

# 🎓 동양미래대학교 컴퓨터소프트웨어공학과 졸업작품

## 💻 PC 하드웨어 모니터링 및 원격 최적화 시스템 — 모바일 파트

> 언제 어디서나 내 PC의 상태를 확인하고, 원격으로 최적화까지.  
> Flutter 기반의 크로스플랫폼 모바일 클라이언트입니다.

<br/>

![Flutter](https://img.shields.io/badge/Flutter-v3.41.9-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-v3.11.5-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![fl_chart](https://img.shields.io/badge/fl__chart-^1.2.0-009688?style=for-the-badge&logo=chartdotjs&logoColor=white)
![ngrok](https://img.shields.io/badge/Tunnel-ngrok-1F1E37?style=for-the-badge&logo=ngrok&logoColor=white)

</div>

---

## 📋 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [모바일 앱의 역할 (기능 상세)](#3-모바일-앱의-역할)
4. [UI/UX 및 대시보드 구조](#4-uiux-및-대시보드-구조)
5. [서버 및 API 연동 방식](#5-서버-및-api-연동-방식)
6. [설치 및 실행 방법](#6-설치-및-실행-방법)

---

## 1. 프로젝트 개요

### 🔍 왜 이 앱이 필요한가?

현대인은 고성능 PC를 사용하면서도 **자리를 비운 순간에는 PC 상태를 전혀 알 수 없습니다.**  
렌더링 작업, 서버 운영, 장시간 연산 처리 중 발생하는 **발열, 메모리 과부하, 프로세스 이상** 등은 실시간으로 감지하지 못하면 심각한 손실로 이어질 수 있습니다.

본 모바일 앱은 이러한 문제를 해결하기 위해 설계되었습니다.

| 기존 방식의 한계 | 본 앱의 해결책 |
|:-:|:-:|
| PC 앞에 직접 앉아야만 상태 확인 가능 | 📱 스마트폰으로 **언제 어디서나** 실시간 확인 |
| 문제 발생 시 뒤늦게 발견 | 🌡️ CPU / GPU / 메모리 **1초 단위** 실시간 모니터링 |
| 수동으로 프로그램 종료 및 정리 필요 | ⚙️ 앱에서 버튼 하나로 **원격 최적화 명령** 전송 |
| 사내망 전용 솔루션 | 🌐 **ngrok 터널**을 통한 외부 네트워크 접근 지원 |

### 🗂️ 전체 프로젝트 레포지토리 구성

본 프로젝트는 팀 GitHub Organization 내 3개의 독립 레포지토리로 구성됩니다.

| 레포지토리 | 담당 파트 | 기술 |
|:---:|:---:|:---:|
| `Server` | 백엔드 API 서버 | Python |
| `Mobile` | 모바일 클라이언트 ← **현재 레포** | Flutter / Dart |
| `Decode` | 데스크탑 에이전트 | C# (.NET) |

---

## 2. 시스템 아키텍처

### 🏗️ 전체 데이터 흐름

```
┌─────────────────────────────────────────────────────────────────────┐
│                      전체 시스템 흐름도                              │
└─────────────────────────────────────────────────────────────────────┘

  [ 사용자의 PC ]                [ 클라우드 / 외부망 ]        [ 사용자 스마트폰 ]
  ┌────────────┐   로컬 전송    ┌─────────────┐   ngrok 터널   ┌─────────────┐
  │  C# 데스크탑│ ──────────►   │ Python 서버 │ ◄────────────  │ Flutter 앱  │
  │   에이전트  │  (localhost)  │  (REST API) │   HTTPS 통신   │  (Mobile)   │
  │            │               │             │                │             │
  │ · CPU 사용률│               │ · 데이터 수집│                │ · 대시보드  │
  │ · 메모리    │               │ · 데이터 저장│                │ · 실시간 게이지│
  │ · GPU 온도  │               │ · API 응답  │                │ · CPU 차트  │
  │ · 디스크    │               │ · 명령 수신  │                │ · 원격 제어 │
  └────────────┘               └─────────────┘                └─────────────┘
```

### 📡 통신 레이어 상세

```

C# Desktop Agent
       │
       │  HTTP POST /api/v1/metrics (주기적 PUSH)
       ▼
  Python Server (FastAPI)
       │
       │  MySQL에 저장
       ▼
  MySQL DB
       │
       │  GET /status → 최신 행 조회
       ▼
  Python Server (FastAPI)
       │
       │  ngrok 터널링 (HTTPS)
       ▼
  Flutter App (Mobile)
       │
       │  HTTP Polling (1초, Timer.periodic)
       └─ GET /status 반복 요청

```

---

## 3. 모바일 앱의 역할

### 📊 실시간 하드웨어 모니터링

앱은 Python 서버의 `/status` 엔드포인트를 **1초마다 자동 호출**하여 아래 하드웨어 데이터를 실시간으로 수신하고 시각화합니다.

| 모니터링 항목 | JSON 키 | 표시 방식 | 갱신 주기 |
|:---:|:---:|:---:|:---:|
| 🖥️ CPU 사용률 (%) | `cpu` | 원형 게이지 + 꺾은선 그래프 | **1초** |
| 🧠 메모리 사용률 (%) | `ram` | 원형 게이지 | **1초** |
| 🧠 메모리 사용량 (GB) | `ram_used` / `ram_total` | 게이지 하단 수치 표시 | **1초** |
| 🎮 GPU 사용률 (%) | `gpu` | 원형 게이지 | **1초** |
| 🌡️ GPU 온도 (°C) | `gpu_temp` | 게이지 중앙 수치 (N/A 처리 포함) | **1초** |

### 📈 CPU 사용량 추이 그래프

- 최근 **60초** 분량의 CPU 사용률을 꺾은선 그래프로 시각화
- 카드 헤더 탭으로 **토글(열기/닫기)** 가능
- `fl_chart`의 `LineChart` 사용, x축은 `-60s ~ Now`, y축은 `0 ~ 100%`

### ⚙️ 원격 PC 제어

앱의 "빠른 제어" 카드에서 버튼 하나로 PC에 명령을 전송할 수 있습니다.

| 버튼 | API | 동작 |
|:---:|:---:|:---|
| 🚀 빠른 최적화 | `POST /optimize` | 서버를 통해 PC 메모리 및 시스템 최적화 실행 |
| 🔴 전원 끄기 | `POST /shutdown` | 확인 다이얼로그 후 PC 원격 종료 명령 전송 |

### 🌡️ 색상 경고 시스템 (Heat Color)

C# Desktop 에이전트의 색상 보간 로직을 Dart로 이식한 `getUsageHeatColor()` 함수를 통해,  
사용률에 따라 게이지 색상이 자동으로 변합니다.

```
  0% ──────── 25% ──────── 50% ──────── 75% ──── 100%
  🟢 초록    🟡 노랑     🟠 주황     🔴 빨강
 #34C759   #FFD60A    #FF9F0A    #FF453A
```

---

## 4. UI/UX 및 대시보드 구조

### 🎨 화면 구성

앱은 **단일 스크린(DashboardScreen)** 구조로, 스크롤 가능한 카드 레이아웃으로 구성됩니다.

```

```

### 🧩 주요 위젯 및 클래스

| 클래스 / 위젯 | 파일 | 역할 |
|:---:|:---:|:---|
| `DashboardScreen` | `dashboard.dart` | 앱의 메인(유일한) 화면, StatefulWidget |
| `_buildHeatGauge()` | `dashboard.dart` | CPU / 메모리 / GPU 원형 게이지 빌더 |
| `GaugePainter` | `dashboard.dart` | CustomPainter 기반 그라데이션 게이지 |
| `getUsageHeatColor()` | `dashboard.dart` | 사용률 → 색상 보간 함수 |
| `ControlService` | `control.dart` | 최적화 / 전원 끄기 HTTP 요청 서비스 |
| `UsageService` | `usage.dart` | 과거 사용 이력 조회 서비스 |

### 🎨 디자인 원칙

- **다크 테마**: 배경 `#121212`, 카드 `#1E1E1E`
- **색상 경고 시스템**: 사용률에 따라 초록 → 노랑 → 주황 → 빨강 자동 변경
- **반응형 스크롤 레이아웃**: `SingleChildScrollView` 기반, 다양한 화면 크기 대응
- **피드백**: 제어 명령 성공/실패 시 `SnackBar`로 즉각 안내

---

## 5. 서버 및 API 연동 방식

### 🌐 ngrok 터널 연동 메커니즘

외부에서 로컬 Python 서버에 접근하기 위해 **ngrok** 터널 주소를 활용합니다.  
현재 앱 내 `baseUrl`은 `control.dart` / `usage.dart`에 상수로 선언되어 있으며, ngrok 주소 변경 시 해당 값을 업데이트합니다.

```
1. PC에서 Python 서버 실행
   └─ python server.py  (예: localhost:8000)

2. ngrok으로 외부 HTTPS URL 생성
   └─ ngrok http 8000
   └─ 결과: https://xxxx-xx-xx.ngrok-free.app

3. control.dart / usage.dart 의 baseUrl 상수를 해당 URL로 변경
   └─ static const String baseUrl = 'https://xxxx.ngrok-free.app';

4. 앱 재빌드 또는 hot restart 후 사용
```

### 🔄 실시간 데이터 수신 방식 — HTTP Polling

```dart
// dashboard.dart — 1초마다 /status 호출
_timer = Timer.periodic(const Duration(seconds: 1), (timer) => _fetchStatus());

Future<void> _fetchStatus() async {
  final response = await http.get(
    Uri.parse('$baseUrl/status'),
  ).timeout(const Duration(milliseconds: 800));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
      _cpu  = data['cpu'].toDouble();
      _ram  = data['ram'].toDouble();
      _gpu  = data['gpu'].toDouble();
      // ...
    });
  }
}
```

### 🗺️ API 엔드포인트 (실제 연동 목록)

| 메서드 | 엔드포인트 | 파일 | 설명 |
|:---:|:---|:---:|:---|
| `GET` | `/status` | `dashboard.dart` | CPU / RAM / GPU 실시간 현황 |
| `POST` | `/optimize` | `control.dart` | 시스템 최적화 명령 전송 |
| `POST` | `/shutdown` | `control.dart` | PC 원격 종료 명령 전송 |
| `GET` | `/api/v1/metrics/history` | `usage.dart` | 과거 하드웨어 사용 이력 조회 |

### 📦 `/status` 응답 형식 예시

```json
{
  "cpu": 45.2,
  "ram": 61.0,
  "ram_used": 9.8,
  "ram_total": 16.0,
  "gpu": 32.0,
  "gpu_temp": 58.0
}
```

---

## 6. 설치 및 실행 방법

### ✅ 사전 요구사항

| 항목 | 버전 | 확인 명령어 |
|:---:|:---:|:---:|
| Flutter SDK | 3.41.9 이상 | `flutter --version` |
| Dart SDK | ^3.11.5 | `dart --version` |
| Android Studio / VS Code | 최신 권장 | — |
| 연결된 기기 또는 에뮬레이터 | — | `flutter devices` |

### 🚀 설치 및 실행 순서

**1단계 — 레포지토리 클론**

```bash
git clone https://github.com/DMU-DeCode/UPM_Mobile.git
cd UPM_Mobile
```

**2단계 — 패키지 의존성 설치**

```bash
flutter pub get
```

**3단계 — ngrok URL 설정**

> 📌 앱 실행 전 **Server 레포지토리**의 Python 서버와 ngrok이 먼저 실행되어 있어야 합니다.

```bash
# [Server 레포 — 별도 터미널]
python server.py

# [ngrok 터널 생성 — 별도 터미널]
ngrok http 8000
# → 출력된 https://xxxx.ngrok-free.dev 주소를 복사
```

이후 `lib/control.dart`와 `lib/usage.dart`의 `baseUrl` 상수를 복사한 주소로 변경합니다.

```dart
// control.dart, usage.dart 공통
static const String baseUrl = 'https://your-ngrok-url.ngrok-free.dev';
```

**4단계 — 앱 실행**

```bash
# 연결된 기기 목록 확인
flutter devices

# 앱 실행 (디버그 모드)
flutter run

# 특정 기기 지정 실행
flutter run -d <device_id>

# 릴리즈 모드 (성능 테스트용)
flutter run --release
```

**5단계 — APK 빌드 (Android 실기기 배포)**

```bash
flutter build apk --release
# 결과물: build/app/outputs/flutter-apk/app-release.apk
```

### 🔧 실제 패키지 의존성 (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8    # iOS 스타일 아이콘
  http: ^1.1.0               # REST API HTTP 통신
  fl_chart: ^1.2.0           # 꺾은선 그래프 (CPU 추이)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

### 🧪 에뮬레이터 vs 실기기 테스트

| 항목 | Android 에뮬레이터 | iOS 시뮬레이터 | 실기기 |
|:---:|:---:|:---:|:---:|
| ngrok URL 접근 | ✅ 외부 URL이므로 바로 사용 | ✅ | ✅ |
| 실시간 성능 확인 | ⚠️ 에뮬레이터 특성상 제한 | ⚠️ | ✅ **최종 테스트 권장** |

> 💡 **ngrok URL은 외부 HTTPS 주소**이므로 에뮬레이터에서도 별도 네트워크 설정 없이 바로 연결 가능합니다.

---

<div align="center">

## 👥 개발 정보

| 항목 | 내용 |
|:---:|:---:|
| 학교 | 동양미래대학교 |
| 학과 | 컴퓨터소프트웨어공학과 |
| 구분 | 졸업작품 (2026) |
| 담당 파트 | 모바일 앱 개발 (Flutter) |

<br/>

*본 레포지토리는 팀 프로젝트의 모바일 파트 단독 레포지토리입니다.*  
*전체 시스템 구성을 위해 **Server**, **Decode(Desktop)** 레포지토리를 함께 참고해 주세요.*

</div>
