# 🍵 Cocafe - 코딩하기 좋은 카페 추천 앱

Flutter로 개발된 위치 기반 카페 추천 모바일 애플리케이션입니다. 코딩 작업에 적합한 카페들을 찾고 공유할 수 있습니다.

## ✨ 주요 기능

- 📍 **위치 기반 카페 검색**: GPS를 이용한 현재 위치 기반 카페 추천
- 🗺️ **지도 기반 탐색**: Naver Maps를 활용한 시각적 카페 위치 확인
- 📝 **사용자 리뷰**: 카페 후기 작성 및 사진 업로드
- ❤️ **좋아요 시스템**: 마음에 드는 카페 저장 및 관리
- 🔍 **REST API 연동**: 실시간 카페 정보 및 추천 데이터
- 🏷️ **태그 시스템**: 카페의 특징을 태그로 분류

## 🏗️ 기술 스택

- **Frontend**: Flutter (Dart)
- **State Management**: GetX
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Maps**: Naver Maps, Kakao Maps
- **Authentication**: Kakao Login
- **Architecture**: MVC 패턴

## 🚀 시작하기

### 필수 요구사항

- Flutter SDK (3.0+)
- Android Studio / Xcode
- Firebase 프로젝트 설정
- Kakao Developers 앱 등록
- Naver Cloud Platform Maps API

### 설치 및 실행

1. **저장소 클론**
```bash
git clone https://github.com/jjihong/cocafe.git
cd cocafe
```

2. **환경변수 설정**
```bash
cp .env.example .env
# .env 파일을 열어서 실제 API 키들로 수정하세요
```

3. **의존성 설치**
```bash
flutter pub get
```

4. **Firebase 설정**
- `android/app/google-services.json` 파일 추가
- `ios/Runner/GoogleService-Info.plist` 파일 추가

5. **앱 실행**
```bash
flutter run
```

## 📱 스크린샷

*스크린샷은 추후 추가 예정*

## 🏗️ 프로젝트 구조

```
lib/
├── controllers/     # GetX 컨트롤러 (비즈니스 로직)
├── models/         # 데이터 모델
├── providers/      # 데이터 제공자 (API, Firebase)
├── screens/        # 화면 위젯
├── services/       # 유틸리티 서비스
└── widgets/        # 재사용 가능한 위젯
```

## 🔧 개발 명령어

```bash
# 코드 분석
flutter analyze

# 테스트 실행
flutter test

# APK 빌드
flutter build apk

# iOS 빌드
flutter build ios
```

## 🛡️ 보안

- 모든 API 키는 환경변수로 관리
- 민감한 정보는 `.gitignore`로 보호
- 프로덕션 빌드에서 디버그 로그 자동 제거

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 연락처

프로젝트 링크: [https://github.com/jjihong/cocafe](https://github.com/jjihong/cocafe)
