# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cocafe is a Flutter mobile application for recommending cafes suitable for coding work. The app features location-based cafe discovery, user-generated posts with photos and reviews, and a social feed system with likes and comments.

## Development Commands

### Flutter Operations
```bash
flutter run                    # Run the app in debug mode
flutter build apk             # Build Android APK
flutter build ios             # Build iOS app
flutter clean                 # Clean build cache
flutter pub get               # Install dependencies
```

### Code Quality
```bash
flutter analyze               # Static analysis (uses analysis_options.yaml)
flutter test                  # Run unit tests
flutter test test/widget_test.dart  # Run specific test file
```

### Firebase & Environment Setup
- Copy `.env.example` to `.env` and configure API keys for:
  - `appKey`: Kakao app key
  - `nativeAppKey`: Kakao native app key  
  - `naverMapClientId`: Naver Maps client ID
- Ensure `google-services.json` is in `android/app/` for Firebase

## Architecture Overview

### State Management: GetX Pattern
- **Controllers**: Business logic and state management (`lib/controllers/`)
- **Providers**: Data layer for API/Firestore operations (`lib/providers/`)
- **Services**: Utility services for likes, location, etc. (`lib/services/`)

### Key Controllers
- `AuthController`: Firebase Auth integration, user session management
- `FeedController`: Post loading filtered by selected town/region
- `PostController`: Create/edit posts with image handling
- `TownController`: Location selection and region management
- `LikeController`: Post liking functionality

### Data Models
- `PostModel`: Core post entity with location, photos, and metadata
- `Place`: Location data from maps integration
- `LikedMarkerData`: Saved location markers

### Navigation Structure
- **Home**: Bottom navigation with Feed, Map, and Profile tabs
- **Feed**: Location-filtered posts with infinite scroll
- **Map**: Naver Maps integration showing cafe locations
- **Profile**: User posts, liked posts, account management

### Firebase Integration
- **Firestore Collections**:
  - `posts`: Main post data with regional filtering by `bcode`
  - `drafts`: Auto-saved draft posts per user
  - `likes`: User like relationships
  - `liked_markers`: Saved map locations
- **Storage**: Image uploads for post photos
- **Auth**: User authentication with Kakao login integration

### External Service Integration
- **Kakao SDK**: Login authentication and map services
- **Naver Maps**: Primary map display and location services
- **Firebase**: Backend services (Auth, Firestore, Storage)

### Image Handling
- `image_picker` for photo selection
- `flutter_image_compress` for optimization before upload
- Firebase Storage for cloud image hosting
- Reorderable grid for photo management in posts

### Location Services
- `geolocator` for device location
- `geocoding` for address resolution
- Regional filtering using administrative boundary codes (`bcode`)
- Town/city selection persisted in SharedPreferences

## Key Development Patterns

### Error Handling
- GetX reactive programming with `.obs` observables
- Try-catch blocks in controllers with user feedback
- Firebase error handling in providers

### Performance Considerations
- Image compression before Firebase upload
- Regional post filtering to limit data loads
- Lazy loading of services with `Get.lazyPut()`
- IndexedStack for tab navigation without rebuilds

### Code Organization
- Feature-based folder structure under `lib/`
- Separation of concerns: UI widgets, business logic controllers, data providers
- Shared widgets in `lib/widgets/` for reusability