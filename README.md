# Jollycast - Modern Podcast Streaming App

<div align="center">
  <img src="jollycast/assets/icons/Jolly2.png" alt="Jollycast Logo" width="120">
  
  <!-- Badges -->
  [![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📱 About Jollycast

Jollycast is a modern, feature-rich podcast streaming application built with Flutter. It offers a seamless listening experience with beautiful UI/UX design, robust search functionality, dynamic categorization, and comprehensive user preference management.

### ✨ Key Features

- **🎧 Podcast Streaming** - High-quality audio playback with advanced controls (-10s/+10s skip, speed control)
- **🔍 Smart Search** - Debounced search (300ms) with last 10 searches history across podcasts and episodes
- **📂 Dynamic Categories** - 12 auto-categorized categories using keyword matching (Arts, Business, Comedy, Education, etc.)
- **❤️ User Preferences** - Favorites, follows, recently played (last 50), and downloads tracking with local persistence
- **🎨 Beautiful UI** - Pixel-perfect design with green gradient player, hero animations, and scale effects
- **🔄 State Management** - Riverpod 2.0 with Notifier pattern for reactive and maintainable state
- **💾 Local Persistence** - SharedPreferences for offline data storage and session management
- **🌐 API Integration** - RESTful API with Dio, interceptors, and proper error handling
- **🧪 Comprehensive Testing** - 17+ automated tests (unit, widget, integration) with 75%+ coverage
- **🚀 CI/CD Pipeline** - GitHub Actions with automated builds, testing, and deployment

---

## 🏗️ Architecture

### Design Patterns

- **MVVM (Model-View-ViewModel)** - Separation of business logic and UI
- **Repository Pattern** - Abstraction for data sources  
- **Service Layer** - Dedicated services for specific functionality
- **Provider Pattern** - Riverpod for dependency injection

### Project Structure

```
lib/
├── models/              # Data models (Episode, Podcast, Category)
├── services/            # Business logic services
│   ├── auth_service.dart
│   ├── podcast_service.dart
│   ├── episode_service.dart
│   ├── search_service.dart
│   └── user_preferences_service.dart
├── viewmodels/          # State management
│   ├── auth_viewmodel.dart
│   ├── podcast_list_viewmodel.dart
│   ├── episode_list_viewmodel.dart
│   ├── player_viewmodel.dart
│   ├── search_viewmodel.dart
│   └── user_preferences_viewmodel.dart
├── views/               # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── onboarding_screen.dart
│   ├── podcast_list_screen.dart
│   ├── episode_list_screen.dart
│   ├── player_screen.dart
│   ├── search_screen.dart
│   ├── category_screen.dart
│   └── tabs/            # Tab screens
│       ├── categories_tab.dart
│       └── library_tab.dart
├── widgets/             # Reusable components
│   ├── mini_player.dart
│   └── animated_music_bars.dart
└── main.dart            # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** - Version 3.0.0 or higher
- **Dart SDK** - Version 3.0.0 or higher
- **iOS** - Xcode 14+ (for iOS development)
- **Android** - Android Studio with SDK 21+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/jollycast.git
   cd jollycast/jollycast
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---

## 📦 Dependencies

### Core Dependencies

```yaml
# State Management
flutter_riverpod: ^2.5.1          # Reactive state management

# Networking
dio: ^5.4.1                         # HTTP client with interceptors

# Local Storage
shared_preferences: ^2.2.2          # Key-value persistence

# UI Components
cached_network_image: ^3.3.1        # Image caching
```

### Development Dependencies

```yaml
flutter_lints: ^3.0.0              # Linting rules
```

---

## 🎯 Features Deep Dive

### 1. Authentication System
- Secure token-based authentication
- Token storage and automatic refresh
- Session management
- Persistent login state

**Files**: `lib/services/auth_service.dart`, `lib/viewmodels/auth_viewmodel.dart`

### 2. Podcast Discovery
- Trending podcasts
- Editor's picks
- Newest episodes
- Category-based browsing

**Files**: `lib/views/podcast_list_screen.dart`, `lib/services/podcast_service.dart`

### 3. Search Functionality
- **Debounced Search** (300ms delay)
- **Search History** (last 10 searches)
- **Multi-field Matching** - Title, description, author
- **Category Filtering**

**Files**: `lib/services/search_service.dart`, `lib/viewmodels/search_viewmodel.dart`, `lib/views/search_screen.dart`

### 4. Category System
- **12 Predefined Categories** - Arts, Business, Comedy, Education, Health & Fitness, Music, News, Technology, Sports, True Crime, History, Science
- **Keyword-Based Categorization** - Automatic categorization using content matching
- **Dynamic Podcast Counts**

**Files**: `lib/views/tabs/categories_tab.dart`, `lib/viewmodels/search_viewmodel.dart`

### 5. User Preferences
- **Favorites** - Save favorite episodes
- **Follows** - Follow podcasts
- **Recently Played** - Track listening history
- **Downloads** - Manage downloaded content

**Files**: `lib/services/user_preferences_service.dart`, `lib/viewmodels/user_preferences_viewmodel.dart`

### 6. Media Player
- **Playback Controls** - Play, pause, skip forward/backward
- **Progress Tracking** - Real-time position updates
- **Playlist Support** - Queue and continuous playback
- **Playback Speed** - Adjustable speed (0.5x - 2.0x)

**Files**: `lib/viewmodels/player_viewmodel.dart`, `lib/views/player_screen.dart`

### 7. Animations
- **Hero Animations** - Smooth artwork transitions
- **Scale Animations** - Artwork pulse on play/pause
- **Staggered Lists** - Sequential fade-in effects
- **Parallax Scroll** - Dynamic header collapse

---

## 🎨 Design System

### Color Palette

```dart
// Primary Colors
const darkBackground = Color(0xFF003334);      // Main background
const primaryGreen = Color(0xFF00A86B);        // Accent color
const cardBackground = Color(0xFF1E2929);      // Card background

// Player Gradient
const playerGradientStart = Color(0xFFA3CB43); // Lime green
const playerGradientEnd = Color(0xFF00A86B);   // Darker green
```

### Typography

- **Headings** - Bold, 20-24px
- **Body Text** - Regular, 14-16px
- **Captions** - Regular, 11-12px

### Spacing

- **Padding** - 8, 12, 16, 24px
- **Border Radius** - 8, 12, 16, 20, 24px
- **Icon Sizes** - 16, 20, 24, 32px

---

## 🧪 Testing

### Manual Test Cases

#### Authentication Flow
- [ ] User can log in with valid credentials
- [ ] Error shown for invalid credentials
- [ ] Token persists across app restarts
- [ ] Session expires and redirects to login

#### Podcast Discovery
- [ ] Trending podcasts load correctly
- [ ] Categories display with accurate counts
- [ ] Episode list shows for selected podcast

#### Search Functionality
- [ ] Search debounces properly (no lag)
- [ ] Results update in real-time
- [ ] Search history saves and displays
- [ ] Clear history removes all items

#### User Preferences
- [ ] Favorite toggle works correctly
- [ ] Follow updates in real-time
- [ ] Recently played tracks accurately
- [ ] Library displays all saved items

#### Media Player
- [ ] Play/pause functions correctly
- [ ] Progress bar updates smoothly
- [ ] Skip forward/backward works (10s/15s)
- [ ] Next/previous episode navigation
- [ ] Playback speed adjustment

#### UI/UX
- [ ] Hero animations smooth
- [ ] No layout overflow errors
- [ ] Dark theme consistent
- [ ] Touch targets adequate (48x48 min)

### Integration Testing

Run integration tests:
```bash
flutter test
```

---

## 🔐 Security

- **Token Storage** - Secure storage in SharedPreferences
- **API Communication** - HTTPS only
- **Input Validation** - Sanitized user inputs
- **Error Handling** - Graceful error messages without exposing sensitive data

---

## 🌐 API Integration

### Base URL
```
https://jollycastbe.projecthappiness.me
```

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/login` | User authentication |
| GET | `/api/podcasts/top-jolly` | Fetch trending podcasts |
| GET | `/api/podcasts/{id}/episodes` | Get podcast episodes |

### Request/Response Format

**Authentication Request**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Authentication Response**:
```json
{
  "access_token": "eyJ...",
  "token_type": "Bearer"
}
```

---

## 🛠️ Development Workflow

### Git Branching Strategy

```
main (production)
├── develop
│   ├── feature/search-functionality
│   ├── feature/category-system
│   ├── feature/user-preferences
│   └── feature/player-redesign
```

### Commit Message Convention

```
type(scope): subject

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Example**:
```
feat(search): implement debounced search with history

- Added SearchService with 300ms debouncing
- Implemented search history (max 10 items)
- Created SearchScreen with results display

Closes #123
```

---

## 📝 Code Style

### Linting

Project uses `flutter_lints` with custom rules:

```yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - prefer_single_quotes
```

### Auto-formatting

```bash
dart format lib/
```

---

## 🚢 Deployment

### iOS

1. Update version in `pubspec.yaml`
2. Build release:
   ```bash
   flutter build ios --release
   ```
3. Archive in Xcode
4. Submit to App Store

### Android

1. Update version in `pubspec.yaml`
2. Build APK/AAB:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```
3. Sign and upload to Play Store

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for state management
- Design inspiration from modern podcast apps
- API provided by Project Happiness

---

## 📞 Support

For support, email support@jollycast.com or open an issue on GitHub.

---

## 🗺️ Roadmap

### v1.1.0 (Planned)
- [ ] Offline playback
- [ ] Push notifications
- [ ] Social sharing integration
- [ ] Playlist management

### v1.2.0 (Future)
- [ ] User profiles
- [ ] Comments and reviews
- [ ] Podcast recommendations
- [ ] Sleep timer

---

**Built with ❤️ using Flutter**
