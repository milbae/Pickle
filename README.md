# 🍽️ FoodMatch - 식당 큐레이션 앱

> 스포티파이의 큐레이션 + 옐프의 맛집정보 + 틴더의 UX + 왓챠피디아의 평가를 결합한, **쌍 비교 기반 식당 평가 앱**

## ✨ 핵심 특징

기존 별점 시스템의 **상향평준화 문제**를 해결하기 위해 **Elo 레이팅 기반 쌍 비교 시스템**을 도입했습니다.

- 🎯 **3단계 평가**: 추천/모르겠음/비추 → 쌍 비교 → 개인 Elo 랭킹
- 🤖 **상황별 다차원 Elo**: 전반/데이트/혼밥/가성비/분위기 5개 축
- 🎮 **틴더식 스와이프 UX**: 빠른 호불호 학습
- 📊 **스포티파이 Wrapped 감성**: 개인 미식 리포트

## 📁 프로젝트 구조

```
foodmatch/
├── lib/
│   ├── main.dart                          # 앱 진입점
│   ├── models/
│   │   └── restaurant.dart                # 식당 데이터 모델
│   ├── data/
│   │   └── sample_restaurants.dart        # 샘플 식당 12개
│   ├── services/
│   │   ├── elo_service.dart               # 🔥 Elo 알고리즘 핵심
│   │   └── storage_service.dart           # SharedPreferences 저장
│   ├── screens/
│   │   ├── onboarding_screen.dart         # 1️⃣ Tinder식 취향 학습
│   │   ├── main_navigation.dart           # 하단 탭 네비게이션
│   │   ├── home_screen.dart               # 2️⃣ Spotify식 큐레이션
│   │   ├── compare_screen.dart            # 3️⃣ 쌍 비교 (핵심!)
│   │   ├── detail_screen.dart             # 4️⃣ 다차원 Elo 상세
│   │   └── my_page_screen.dart            # 5️⃣ 개인 랭킹 + Wrapped
│   └── widgets/
├── android/                                # Android 빌드 설정
├── pubspec.yaml                            # Flutter 의존성
└── README.md
```

## 🚀 빌드 & 실행 방법

### 방법 1: Android Studio (가장 쉬움)
1. [Flutter SDK 설치](https://docs.flutter.dev/get-started/install) (3.0 이상)
2. [Android Studio 설치](https://developer.android.com/studio)
3. 이 프로젝트 폴더를 Android Studio에서 열기
4. 우측 상단 ▶️ 실행 버튼 클릭

### 방법 2: 커맨드라인
```bash
# 의존성 설치
flutter pub get

# 디버그 모드 실행 (USB 연결된 안드로이드 폰)
flutter run

# 릴리즈 APK 빌드 (배포용)
flutter build apk --release

# 생성된 APK 위치
# build/app/outputs/flutter-apk/app-release.apk
```

### 방법 3: 클라우드 빌드 (Flutter 설치 없이)
- **Codemagic** (codemagic.io): 무료 500분/월, GitHub 연동
- **GitHub Actions**: `.github/workflows/build.yml`에 워크플로우 추가
- **AppCircle** (appcircle.io): 무료 플랜 있음

## 🧮 Elo 알고리즘 핵심 코드

`lib/services/elo_service.dart`에서:

```dart
// 예상 승률 계산
double _expectedScore(double ratingA, double ratingB) {
  return 1.0 / (1.0 + pow(10, (ratingB - ratingA) / 400));
}

// 결과 반영
newEloA = oldEloA + K * (actualA - expectedA);
// K값: 초기 64 (빠른 학습) → 30회 후 16 (안정화)
```

**왜 천재적인가?**
- 강한 식당이 약한 식당을 이기면: +2점 (당연한 결과)
- 약한 식당이 강한 식당을 이기면: +30점 (큰 변동)
- → **자연스럽게 분산된 점수대로 정착, 상향평준화 불가능!**

## 🎨 5개 화면 요약

| 화면 | 역할 | 핵심 UX |
|------|------|---------|
| **Onboarding** | 초기 취향 학습 | 좌/우 스와이프로 12개 식당 평가 |
| **Home** | 추천 큐레이션 | TOP 5 + 기분별 플레이리스트 |
| **Compare** ⭐ | 쌍 비교 | A vs B + 차원 선택(데이트/혼밥/...) |
| **Detail** | 식당 상세 | 5각형 레이더 차트 + 승패 기록 |
| **My** | 개인 랭킹 | TOP 10 리더보드 + 레벨 시스템 |

## 🛠️ 사용 기술

- **Framework**: Flutter 3.x (Dart)
- **상태 저장**: SharedPreferences (로컬)
- **UI**: Material 3, Google Fonts (Noto Sans KR)
- **차트**: fl_chart (레이더 차트)
- **스와이프**: flutter_card_swiper

## 🔮 다음 개발 단계

- [ ] 백엔드 API 연동 (Firebase / Supabase)
- [ ] 실제 식당 사진 (카카오맵 API)
- [ ] 사용자 인증 + 친구 추천
- [ ] GNN 기반 추천 엔진
- [ ] 푸시 알림 (방문 직후 평가 유도)
- [ ] 다국어 지원

## 📝 라이선스

MIT License - 자유롭게 사용 가능
