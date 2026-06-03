# 📱 APK 만들기 - 3가지 방법

## 🥇 방법 1: Android Studio (초보자 추천, 30분)

### 준비물
- Windows / Mac / Linux 컴퓨터 (램 8GB 이상)
- 인터넷 연결

### 단계별 가이드

#### Step 1: Flutter SDK 설치
- 다운로드: https://docs.flutter.dev/get-started/install
- 운영체제 선택 → 압축 풀기 → PATH 설정
- 터미널에서 확인: `flutter doctor`

#### Step 2: Android Studio 설치
- 다운로드: https://developer.android.com/studio
- 설치 시 "Android SDK" 같이 설치 체크
- Flutter 플러그인 설치: Settings → Plugins → "Flutter" 검색 → Install

#### Step 3: 프로젝트 열기
1. Android Studio 실행
2. "Open" 클릭 → `foodmatch` 폴더 선택
3. 우측 하단 "Get dependencies" 클릭 (또는 터미널에서 `flutter pub get`)

#### Step 4: APK 빌드
방법 A) GUI:
- 상단 메뉴: Build → Build Bundle(s) / APK(s) → Build APK(s)

방법 B) 터미널:
```bash
flutter build apk --release
```

#### Step 5: APK 위치
```
foodmatch/build/app/outputs/flutter-apk/app-release.apk
```
→ 이 파일을 안드로이드 폰에 복사 → 설치!

---

## 🥈 방법 2: Codemagic 클라우드 빌드 (Flutter 설치 불필요, 15분)

### 장점
- 본인 컴퓨터에 아무것도 설치 안 해도 됨
- 무료 500분/월
- GitHub만 있으면 됨

### 단계
1. https://codemagic.io 가입 (GitHub 계정 연동)
2. 이 프로젝트를 GitHub 저장소에 업로드
3. Codemagic 대시보드에서 "Add application" → 저장소 선택
4. "Flutter App (default)" 워크플로우 선택
5. "Start new build" 클릭 → 약 10분 후 APK 다운로드 가능

---

## 🥉 방법 3: GitHub Actions (자동화)

`.github/workflows/build.yml` 파일을 추가:

```yaml
name: Build Android APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

GitHub 푸시할 때마다 자동으로 APK 빌드 → Actions 탭에서 다운로드.

---

## ⚠️ 주의사항

### APK 설치 시 "출처를 알 수 없는 앱" 경고
- 안드로이드 설정 → 보안 → "알 수 없는 출처 허용"
- 또는 설치 시 "그래도 설치" 선택

### 디버그 빌드 vs 릴리즈 빌드
- 디버그: `flutter build apk` (느림, 크기 큼, 개발용)
- 릴리즈: `flutter build apk --release` (빠름, 작음, 배포용)

### 첫 빌드는 오래 걸려요
- 처음 빌드: 5~15분 (Gradle, 의존성 다운로드)
- 두 번째부터: 1~3분

---

## 🆘 문제 해결

### "flutter: command not found"
→ Flutter SDK PATH 설정이 안 됨. https://docs.flutter.dev/get-started/install 다시 확인

### "Android licenses not accepted"
```bash
flutter doctor --android-licenses
```
→ 모두 "y" 입력

### Gradle 빌드 실패
```bash
cd android && ./gradlew clean
cd .. && flutter clean && flutter pub get
flutter build apk --release
```

### 한글 폰트 안 보임
→ 이미 `google_fonts: ^6.1.0` 패키지로 Noto Sans KR 사용 중. 첫 실행 시 폰트 다운로드 필요(인터넷 필수).
