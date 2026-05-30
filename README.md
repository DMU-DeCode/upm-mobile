<div align="center">

# 🎓 동양미래대학교 컴퓨터소프트웨어공학과 졸업작품

## 💻 PC 하드웨어 모니터링 및 원격 최적화 시스템 — 모바일 파트

> 언제 어디서나 내 PC의 상태를 확인하고, 원격으로 최적화까지.  
> Flutter 기반의 크로스플랫폼 모바일 클라이언트입니다.

<br/>

![Flutter](https://img.shields.io/badge/Flutter-v3.41.9-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/State-Provider-7B61FF?style=for-the-badge&logo=flutter&logoColor=white)
![REST API](https://img.shields.io/badge/Network-REST%20API-FF6C37?style=for-the-badge&logo=postman&logoColor=white)
![WebSocket](https://img.shields.io/badge/Realtime-WebSocket%20%2F%20Polling-009688?style=for-the-badge&logo=socket.io&logoColor=white)
![ngrok](https://img.shields.io/badge/Tunnel-ngrok-1F1E37?style=for-the-badge&logo=ngrok&logoColor=white)

</div>

---

## 📋 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [모바일 앱의 역할 (기능 상세)](#3-모바일-앱의-역할-기능-상세)
4. [UI/UX 및 대시보드 구조](#4-uiux-및-대시보드-구조)
5. [서버 및 API 연동 방식](#5-서버-및-api-연동-방식)
6. [디렉토리 구조](#6-디렉토리-구조)
7. [설치 및 실행 방법](#7-설치-및-실행-방법)

---

## 1. 프로젝트 개요

### 🔍 왜 이 앱이 필요한가?

현대인은 고성능 PC를 사용하면서도 **자리를 비운 순간에는 PC 상태를 전혀 알 수 없습니다.**  
렌더링 작업, 서버 운영, 장시간 연산 처리 중 발생하는 **발열, 메모리 과부하, 프로세스 이상** 등은 실시간으로 감지하지 못하면 심각한 손실로 이어질 수 있습니다.

본 모바일 앱은 이러한 문제를 해결하기 위해 설계되었습니다.

| 기존 방식의 한계 | 본 앱의 해결책 |
|:-:|:-:|
| PC 앞에 직접 앉아야만 상태 확인 가능 | 📱 스마트폰으로 **언제 어디서나** 실시간 확인 |
| 문제 발생 시 뒤늦게 발견 | 🔔 이상 감지 시 **즉각 모니터링** 가능 |
| 수동으로 프로그램 종료 및 정리 필요 | ⚙️ 앱에서 바로 **원격 최적화 명령** 전송 |
| 사내망 전용 솔루션 | 🌐 **ngrok 터널**을 통한 외부 네트워크 접근 지원 |

### 🗂️ 전체 프로젝트 레포지토리 구성

본 프로젝트는 팀 GitHub Organization 내 3개의 독립 레포지토리로 구성됩니다.

| 레포지토리 | 담당 파트 | 기술 |
|:---:|:---:|:---:|
| `Server` | 백엔드 API 서버 | Python (Flask / FastAPI) |
| `Mobile` | 모바일 클라이언트 ← **현재 레포** | Flutter / Dart |
| `Decode` | 데스크탑 에이전트 | C# (.NET) |

---

## 2. 시스템 아키텍처

### 🏗️ 전체 데이터 흐름

```
┌─────────────────────────────────────────────────────────────────────┐
│                      전체 시스템 흐름도                              │
└─────────────────────────────────────────────────────────────────────┘

  [ 사용자의 PC ]                [ 클라우드 / 외부망 ]       [ 사용자 스마트폰 ]
  ┌────────────┐   로컬 전송    ┌─────────────┐   ngrok 터널   ┌─────────────┐
  │  C# 데스크탑 │ ──────────► │ Python 서버  │ ◄──────────── │ Flutter 앱  │
  │   에이전트  │  (localhost) │  (REST API) │   HTTPS 통신   │  (Mobile)   │
  │            │              │             │                │             │
  │ · CPU 사용률│              │ · 데이터 수집│                │ · 대시보드  │
  │ · 메모리    │              │ · 데이터 저장│                │ · 실시간 차트│
  │ · GPU 온도 │              │ · API 응답  │                │ · 원격 제어 │
  │ · 디스크    │              │ · 명령 수신  │                │ · 알림 수신 │
  └────────────┘              └─────────────┘                └─────────────┘
         │                           ▲                               │
         │      하드웨어 데이터 수집   │      HTTP/WebSocket 요청      │
         └───────────────────────────┘───────────────────────────────┘
```

### 📡 통신 레이어 상세

```
Flutter App (Mobile)
       │
       │  HTTPS Request (REST API)
       │  WebSocket / Polling (실시간)
       ▼
  ngrok Public URL
  (https://xxxx-xx-xx.ngrok.io)
       │
       │  터널링 (TCP Forwarding)
       ▼
  Python Server (localhost:PORT)
       │
       │  내부 소켓 / HTTP
       ▼
  C# Desktop Agent
  (하드웨어 데이터 수집 및 명령 실행)
```

---

## 3. 모바일 앱의 역할 (기능 상세)

### 📊 실시간 하드웨어 모니터링

앱은 Python 서버의 REST API 또는 WebSocket을 통해 아래 하드웨어 데이터를 **실시간**으로 수신하고 시각화합니다.

| 모니터링 항목 | 표시 방식 | 갱신 주기 |
|:---:|:---:|:---:|
| 🖥️ CPU 사용률 (%) | 원형 게이지 + 꺾은선 그래프 | 실시간 (Polling / WS) |
| 🧠 메모리 사용량 (GB / %) | 막대 그래프 + 수치 표시 | 실시간 |
| 🎮 GPU 사용률 (%) | 카드 위젯 + 진행 바 | 실시간 |
| 🌡️ CPU / GPU 온도 (°C) | 온도 게이지 (색상 경고 포함) | 실시간 |
| 💾 디스크 사용량 | 도넛 차트 | 주기적 갱신 |
| 🌐 네트워크 I/O | 수치 표시 | 실시간 |

### ⚙️ 원격 PC 최적화 및 제어

사용자는 앱에서 직접 PC에 최적화 명령을 전송할 수 있습니다.

```
[앱 내 제어 기능]

  ┌─────────────────────────────────┐
  │  🧹 메모리 최적화 실행           │  ← 불필요한 프로세스 메모리 해제
  │  ❌ 특정 프로세스 종료           │  ← 실행 중인 프로세스 목록 조회 후 종료
  │  🔄 시스템 캐시 정리             │  ← 임시 파일 및 캐시 정리 명령
  │  📋 실행 중 프로세스 목록 조회   │  ← 현재 프로세스 리스트 확인
  └─────────────────────────────────┘
```

---

## 4. UI/UX 및 대시보드 구조

### 🎨 화면 구성 (Screen Flow)

```
앱 실행
  │
  ▼
┌─────────────────┐
│   서버 연결 화면  │  ← ngrok URL 입력 및 연결 상태 확인
└────────┬────────┘
         │ 연결 성공
         ▼
┌─────────────────┐
│  메인 대시보드   │  ← 핵심 하드웨어 상태 한눈에 요약
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌────────────┐
│ 상세 모│ │  원격 제어  │
│니터링  │ │   화면     │
│화면    │ │            │
│        │ │ · 프로세스  │
│· CPU   │ │   목록     │
│· Memory│ │ · 최적화   │
│· GPU   │ │   명령     │
│· Temp  │ │            │
└────────┘ └────────────┘
```

### 🧩 주요 위젯 구성

| 위젯명 | 역할 | 위치 |
|:---:|:---:|:---:|
| `ServerConnectWidget` | URL 입력 및 연결 관리 | 연결 화면 |
| `HardwareSummaryCard` | 핵심 지표 카드 요약 | 메인 대시보드 |
| `CpuGaugeWidget` | CPU 사용률 원형 게이지 | 상세 모니터링 |
| `MemoryBarWidget` | 메모리 막대 그래프 | 상세 모니터링 |
| `GpuTempWidget` | GPU 온도 및 사용률 카드 | 상세 모니터링 |
| `ProcessListWidget` | 실행 중인 프로세스 목록 | 원격 제어 화면 |
| `OptimizeButtonWidget` | 최적화 명령 전송 버튼 | 원격 제어 화면 |

### 🎨 디자인 원칙

- **다크 테마 기반** UI로 하드웨어 모니터링 앱 특유의 전문적인 느낌 구현
- **색상 경고 시스템**: 온도·사용률 수치에 따라 초록 → 노랑 → 빨강으로 색상 자동 변경
- **반응형 레이아웃**: 다양한 스마트폰 해상도에 대응하는 유연한 위젯 배치

---

## 5. 서버 및 API 연동 방식

### 🌐 ngrok 터널 연동 메커니즘

외부에서 로컬 Python 서버에 접근하기 위해 **ngrok** 터널 주소를 활용합니다.

```
1. 사용자가 PC에서 Python 서버 실행
   └─ python server.py  (예: localhost:8000)

2. ngrok으로 외부 URL 생성
   └─ ngrok http 8000
   └─ 결과: https://abcd-123-456.ngrok-free.app

3. 앱의 '서버 연결' 화면에 위 URL 입력
   └─ 이후 모든 API 요청은 해당 URL 베이스로 전송
```

### 📡 API 요청 구조

```dart
// 예시: 하드웨어 데이터 요청
final response = await http.get(
  Uri.parse('$baseUrl/api/hardware/status'),
  headers: {'Content-Type': 'application/json'},
);

// 예시: 원격 최적화 명령 전송
final response = await http.post(
  Uri.parse('$baseUrl/api/control/optimize'),
  body: jsonEncode({'action': 'memory_clean'}),
);
```

### 🔄 실시간 데이터 수신 방식

```
방식 1. Polling (주기적 HTTP 요청)
  ┌─────────────────────────────────────────┐
  │  Timer.periodic(Duration(seconds: 2))   │
  │    └─ GET /api/hardware/status 요청      │
  │    └─ 응답 데이터로 UI 상태 업데이트     │
  └─────────────────────────────────────────┘

방식 2. WebSocket (지속 연결 스트림)
  ┌─────────────────────────────────────────┐
  │  WebSocket.connect('ws://baseUrl/ws')   │
  │    └─ 서버 푸시 데이터 실시간 수신      │
  │    └─ StreamBuilder로 UI 자동 갱신      │
  └─────────────────────────────────────────┘
```

### 🗺️ 주요 API 엔드포인트 (연동 목록)

| 메서드 | 엔드포인트 | 설명 |
|:---:|:---|:---|
| `GET` | `/api/hardware/status` | 전체 하드웨어 현황 조회 |
| `GET` | `/api/hardware/cpu` | CPU 사용률 및 온도 |
| `GET` | `/api/hardware/memory` | 메모리 사용량 |
| `GET` | `/api/hardware/gpu` | GPU 사용률 및 온도 |
| `GET` | `/api/process/list` | 실행 중 프로세스 목록 |
| `POST` | `/api/control/optimize` | 최적화 명령 전송 |
| `POST` | `/api/process/kill` | 특정 프로세스 종료 |
| `WS` | `/ws` | WebSocket 실시간 스트림 |

---

## 6. 디렉토리 구조

```
mobile/
├── android/                  # Android 네이티브 빌드 설정
├── ios/                      # iOS 네이티브 빌드 설정
├── lib/
│   ├── main.dart             # 앱 엔트리포인트, Provider 초기화
│   │
│   ├── models/               # 데이터 모델 (JSON 직렬화)
│   │   ├── hardware_status.dart
│   │   ├── cpu_data.dart
│   │   ├── memory_data.dart
│   │   ├── gpu_data.dart
│   │   └── process_info.dart
│   │
│   ├── services/             # 네트워크 통신 레이어
│   │   ├── api_service.dart      # HTTP REST API 요청 처리
│   │   ├── websocket_service.dart # WebSocket 연결 관리
│   │   └── server_config.dart    # ngrok URL 설정 관리
│   │
│   ├── providers/            # 상태 관리 (Provider 패턴)
│   │   ├── hardware_provider.dart
│   │   ├── connection_provider.dart
│   │   └── control_provider.dart
│   │
│   ├── screens/              # 화면 단위 UI
│   │   ├── connect_screen.dart   # 서버 연결 화면
│   │   ├── dashboard_screen.dart # 메인 대시보드
│   │   ├── monitor_screen.dart   # 상세 모니터링
│   │   └── control_screen.dart   # 원격 제어 화면
│   │
│   └── widgets/              # 재사용 가능한 UI 위젯
│       ├── hardware_summary_card.dart
│       ├── cpu_gauge_widget.dart
│       ├── memory_bar_widget.dart
│       ├── gpu_temp_widget.dart
│       ├── process_list_widget.dart
│       └── optimize_button_widget.dart
│
├── pubspec.yaml              # 패키지 의존성 정의
└── README.md
```

---

## 7. 설치 및 실행 방법

### ✅ 사전 요구사항

| 항목 | 최소 버전 | 확인 명령어 |
|:---:|:---:|:---:|
| Flutter SDK | 3.41.9 이상 | `flutter --version` |
| Dart SDK | 3.x 이상 | `dart --version` |
| Android Studio / Xcode | 최신 권장 | — |
| 연결된 기기 or 에뮬레이터 | — | `flutter devices` |

### 🚀 설치 및 실행 순서

**1단계 — 레포지토리 클론**

```bash
git clone https://github.com/<Organization>/Mobile.git
cd Mobile
```

**2단계 — 패키지 의존성 설치**

```bash
flutter pub get
```

**3단계 — 서버 측 준비 (선행 조건)**

> 📌 Mobile 앱을 실행하기 전, **Server 레포지토리**의 Python 서버와 ngrok이 먼저 실행 중이어야 합니다.

```bash
# [Server 레포 - 별도 터미널]
python server.py

# [ngrok 터널 생성 - 별도 터미널]
ngrok http 8000
# → 출력된 https://xxxx.ngrok-free.app URL을 복사해 앱에 입력
```

**4단계 — 앱 실행**

```bash
# 연결된 기기 목록 확인
flutter devices

# 앱 실행 (디버그 모드)
flutter run

# 특정 기기 지정 실행
flutter run -d <device_id>

# 릴리즈 모드 빌드 (성능 테스트용)
flutter run --release
```

**5단계 — APK 빌드 (Android 실기기 배포)**

```bash
flutter build apk --release
# 빌드 결과: build/app/outputs/flutter-apk/app-release.apk
```

### 🧪 에뮬레이터 vs 실기기 테스트

| 항목 | Android 에뮬레이터 | iOS 시뮬레이터 | 실기기 |
|:---:|:---:|:---:|:---:|
| 네트워크 접근 | ⚠️ 호스트 IP 설정 필요 | ⚠️ 동일 | ✅ 직접 접근 |
| ngrok URL 연동 | ✅ 외부 URL이므로 바로 사용 | ✅ | ✅ |
| 권장 여부 | 개발 초기 테스트 | iOS 확인용 | **최종 테스트 권장** |

> 💡 **ngrok URL은 외부 HTTPS 주소**이므로 에뮬레이터에서도 별도 설정 없이 바로 연결 가능합니다.

### 🔧 주요 패키지 (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.x.x          # 상태 관리
  http: ^1.x.x               # REST API 통신
  web_socket_channel: ^2.x.x # WebSocket 통신
  fl_chart: ^0.x.x           # 차트 및 그래프 위젯
  shared_preferences: ^2.x.x # 서버 URL 로컬 저장
```

---

<div align="center">

## 👥 개발 정보

| 항목 | 내용 |
|:---:|:---:|
| 학교 | 동양미래대학교 |
| 학과 | 컴퓨터소프트웨어공학과 |
| 구분 | 졸업작품 (2025) |
| 담당 파트 | 모바일 앱 개발 (Flutter) |

<br/>

*본 레포지토리는 팀 프로젝트의 모바일 파트 단독 레포지토리입니다.*  
*전체 시스템 구성을 위해 **Server**, **Decode(Desktop)** 레포지토리를 함께 참고해 주세요.*

</div>
