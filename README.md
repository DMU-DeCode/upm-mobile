# 📱 Real-time Sensor Monitoring Mobile App (Flutter)

이 레포지토리는 C# 데이터 생성기와 Python 서버로부터 전송되는 실시간 센서 데이터를 모니터링하는 **Flutter 모바일 애플리케이션**입니다.

---

## 🛠️ 시스템 아키텍처 (System Architecture)
본 앱은 단독으로 작동하지 않으며, 아래 구성 요소와 함께 작동합니다.
1. **Data Source (C#)**: 실시간 센서 데이터 생성
2. **Backend (Python)**: FastAPI/Uvicorn 서버 (Port: 8000)
3. **Tunneling (ngrok)**: 로컬 서버를 외부로 노출
4. **Mobile App (Flutter)**: ngrok 주소를 통해 실시간 데이터 시각화

---

## ⚙️ 사전 설정 (Prerequisites)
### 1. Android Studio 설치
### 2. flutter 설치
### 3. 프로젝트 경로 (중요)
* **빌드 오류 방지**: Windows 환경에서 Flutter 빌드 시 한글 경로 에러가 발생할 수 있습니다.
* **권장 경로**: ex) `C:\Mobile` (반드시 영문 경로 사용)

### 4. 기기 연결
* 스마트폰의 **USB 디버깅** 모드 활성화
* PC와 USB 케이블로 연결된 상태 확인

### 5. 패키지 추가
* 프로젝트 폴더에서 아래 명령어를 실행하여 패키지를 추가하세요.
  ```bash
  flutter pub add fl_chart
  ```

---

## 🚀 실행 가이드 (Execution Guide)
PC를 켤 때마다 아래 순서대로 실행해야 데이터가 정상적으로 연동됩니다. 
### **1. DB 실행**
 
### **2. 데이터 생성 및 서버 가동**
* **C# 프로그램**: `UPM_Decode`를 실행하여 데이터 송신 상태로 만듭니다. 
* **Python 서버**: 터미널에서 프로젝트 루트 예)`C:\Users\USER\Desktop\UPM_Prog\UPM_Server`로 이동 후 아래 명령어를 입력합니다. 
    ```bash
    python main.py
    ```
    * `Running on http://0.0.0.0:8000` 문구가 뜨는지 확인하세요. 

### **3. 외부 터널링 실행 (ngrok)**
* 별도의 CMD 창을 열고 아래 명령어를 입력합니다. 
    ```bash
    ngrok http 8000
    ```
    * 실행 후 **Forwarding** 항목에 뜨는 `https://...ngrok-free.dev` 주소를 복사합니다. 

### **4. 앱 코드 수정 (주소 업데이트)**
* `lib/dashboard.dart`를 열고 주소를 최신화합니다. 
    ```dart
    // 기존 주소를 지우고 복사한 ngrok 주소를 넣습니다. 40번줄 근처
    final url = Uri.parse('https://[복사한-주소]/status'); 
    ```
    * ⚠️ **중요**: 수정 후 반드시 **Ctrl + S**를 눌러 저장하세요. 

### **5. 모바일 앱 실행**
* 스마트폰을 USB로 연결(USB 디버깅 허용)한 뒤 터미널에 입력합니다. 
    ```bash
    cd UPM_Mobile
    flutter run
    

