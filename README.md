# APEX SPEECH — Flutter Frontend

> AI-Powered Executive Public Speaking Coach

---

## Architecture: Clean Architecture + BLoC Pattern

```
lib/
├── core/
│   ├── constants/          # AppColors, AppConstants
│   ├── theme/              # AppTheme (Material 3)
│   └── navigation/         # GoRouter setup
│
├── domain/                 # Business logic layer (pure Dart)
│   ├── entities/           # UserEntity, ScriptEntity, SessionEntity
│   ├── repositories/       # Abstract repository interfaces
│   └── usecases/           # Use case classes (GetScripts, StartSession…)
│
├── data/                   # Data layer
│   ├── models/             # JSON models + fromJson/toJson
│   ├── datasources/        # Remote (Dio/Flask API) + Local (Hive)
│   └── repositories/       # Concrete repository implementations
│
└── presentation/           # UI layer
    ├── screens/            # One folder per screen
    ├── widgets/            # Reusable components
    ├── bloc/               # BLoC state management
    └── providers/          # GetIt DI providers
```

## Design Patterns Used

| Pattern | Where | Purpose |
|---------|-------|---------|
| **Clean Architecture** | All layers | Separation of concerns |
| **BLoC** | State management | Predictable UI state |
| **Repository Pattern** | Data layer | Abstract data sources |
| **Dependency Injection** | GetIt | Loose coupling |
| **GoRouter** | Navigation | Declarative routing |
| **Factory Pattern** | Models | `fromJson` constructors |
| **Observer Pattern** | BLoC streams | Reactive UI updates |

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| SplashScreen | `/` | Animated logo, auto-navigate |
| OnboardingScreen | `/onboarding` | 3-slide feature intro |
| LoginScreen | `/login` | JWT authentication |
| RegisterScreen | `/register` | New account |
| DashboardScreen | `/dashboard` | Home, Scripts, Analytics, Profile tabs |
| ScriptEditorScreen | `/script-editor` | GPT-4o Apexify + Q&A generation |
| LivePracticeScreen | `/live-practice` | Camera + VibeMeter + Teleprompter |
| PostGameScreen | `/post-game` | Session report + AI coaching tips |
| ProfileScreen | `/profile` | User stats + settings |

## Key UI Components

- **VibeMeter** — CustomPainter circular energy ring, color-shifts based on Hume AI scores
- **ModulationGraph** — fl_chart real-time pitch wave
- **PostureSkeletonPainter** — CustomPainter 33-point body overlay on camera
- **GlassCard** — BackdropFilter glassmorphism container
- **GoldButton** — Animated gradient CTA button with scale feedback
- **ScoreRing** — Circular progress ring for AI scores

## Design System

- **Background**: #080810 (Obsidian)
- **Gold**: #D4AF37 (Royal Gold) — primary actions, achievements
- **Success**: #00FF41 (Matrix Green) — good posture, high confidence
- **Warning**: #FFBF00 (Amber) — filler words, slouching
- **Font Display**: Cinzel (executive authority headers)
- **Font Body**: Outfit (clean, modern readability)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on device
flutter run

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Environment Setup

Create `.env` in root:
```
FLASK_API_URL=http://your-server.com/api
```

## Dependencies Overview

See `pubspec.yaml` for the complete list. Key packages:

- `flutter_bloc` — State management
- `go_router` — Navigation
- `get_it` — Dependency injection
- `dio` — HTTP client for Flask API
- `camera` — Live camera feed
- `google_mlkit_pose_detection` — MediaPipe posture
- `record` — Audio capture
- `fl_chart` — Modulation graph
- `flutter_animate` — Animations
- `glassmorphism` — Glass effect cards
- `google_fonts` — Cinzel + Outfit fonts
