# 🎧 Jollycast - Podcast Streaming App

[![Build Android APK](https://github.com/decodedfaith/jollycast/actions/workflows/build-android.yml/badge.svg)](https://github.com/decodedfaith/jollycast/actions/workflows/build-android.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?logo=flutter)](https://flutter.dev)

A modern, feature-rich podcast streaming application built with Flutter. Jollycast provides a seamless experience for discovering, streaming, and enjoying your favorite podcasts.

![Demo of Jollycast App](docs/assets/demo.gif)

## ✨ Features

- 🎵 **Stream Podcasts** - High-quality audio streaming with playback controls
- 📚 **Browse & Discover** - Explore curated podcast collections  
- 🔍 **Search** - Find podcasts with debounced search functionality
- ⭐ **Favorites & History** - Track your listening preferences
- 🔐 **Secure Authentication** - User login and session management
- 🎨 **Beautiful UI** - Modern design with custom splash animations
- ⚡ **Fast Performance** - Optimized for smooth user experience
- 📱 **Responsive Design** - Works seamlessly across different screen sizes

## 📥 Download & Try

### Option 1: Direct APK Download
[![Download APK](https://img.shields.io/badge/Download-APK-brightgreen?style=for-the-badge&logo=android)](https://github.com/decodedfaith/jollycast/releases/latest)

**How to download:**
1. Visit the [Releases](https://github.com/decodedfaith/jollycast/releases/latest) page
2. Scroll to the **Assets** section 
3. Download the `jollycast-v*.apk` file (ignore the "Source code" zip files)
4. Install on your Android device

> **Note**: If no APK is available, download from [GitHub Actions artifacts](https://github.com/decodedfaith/jollycast/actions) or use Option 2 (Appetize.io) to try the app.

### Option 2: Try in Browser (Appetize.io)
[![Try on Appetize](https://img.shields.io/badge/Try%20Now-Appetize.io-orange?style=for-the-badge)](https://appetize.io/app/b_ph6y5cef7vb7m72ygcd24wq3ty?device=pixel7&osVersion=13.0&toolbar=true)

**No installation needed!** Try Jollycast directly in your browser. See [Appetize Setup Guide](APPETIZE_SETUP.md) for details.

### Option 3: Beta Testing (Firebase App Distribution)
Join our beta testing program for early access to new features. Contact the maintainer for an invitation.

## 🎮 Demo Credentials

For demo/testing purposes, use these credentials:

- **Phone Number**: `08114227399`
- **Password**: `Development@101`

## 📸 Screenshots

<div align="center">
  <img src="screenshots/splash.png" width="200" alt="Splash Screen"/>
  <img src="screenshots/login.png" width="200" alt="Login"/>
  <img src="screenshots/home.png" width="200" alt="Home"/>
  <img src="screenshots/player.png" width="200" alt="Player"/>
</div>

> 📝 **Note**: Screenshots coming soon!

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) 3.24.0
- **Language**: Dart 3.5.0+
- **State Management**: [Riverpod](https://riverpod.dev) 2.6.1
  - Chosen for compile-time safety, testability, and separation of concerns
  - Uses `NotifierProvider` and `AsyncNotifierProvider` for robust state handling
- **HTTP Client**: [Dio](https://pub.dev/packages/dio) 5.7.0 (with auth interceptors)
- **Audio Playback**: [Just Audio](https://pub.dev/packages/just_audio) 0.9.42
- **Secure Storage**: [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) 9.2.2
- **Local Storage**: [SharedPreferences](https://pub.dev/packages/shared_preferences) 2.3.3
- **Local Database**: [Hive](https://pub.dev/packages/hive) 2.2.3
- **Routing**: [Go Router](https://pub.dev/packages/go_router) 14.6.2

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.5.0 or higher
- Android Studio / Xcode (for Android/iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/decodedfaith/jollycast.git
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

4. **Build APK**
   ```bash
   flutter build apk --release
   ```

5. **Build App Bundle** (for Play Store)
   ```bash
   flutter build appbundle --release
   ```

## 🏗️ Project Structure

The project follows **MVVM (Model-View-ViewModel)** architecture:

```
lib/
├── core/                  # Core utilities, constants, and themes
│   ├── constants/         # App-wide constants (colors, strings, etc.)
│   ├── theme/             # Theme configuration
│   └── utils/             # Utility functions
├── models/                # Data models (Episode, Podcast, User)
├── providers/             # Riverpod providers
├── screens/               # UI screens
├── services/              # API and business logic services
├── viewmodels/            # State management (Riverpod notifiers)
├── widgets/               # Reusable UI components
└── main.dart              # App entry point
```

## 🧪 Testing

Run tests with:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

The project includes automated tests for:
- Authentication flow
- Podcast fetching and display
- Audio playback functionality
- State management logic

## 🔮 Architecture & Design Decisions

### State Management: Riverpod
Chosen for:
- **Type Safety**: Compile-time error detection
- **Testability**: Easy to mock and test
- **Separation of Concerns**: Clear separation between UI and business logic
- **Performance**: Optimized rebuilds and caching

### API Integration
- Dio with custom interceptors for authentication
- Automatic token refresh handling
- Comprehensive error handling with user-friendly messages

### Assumptions Made
1. **Backend Availability**: Assumed the provided API is stable with client-side caching
2. **Search Logic**: Implemented client-side filtering of podcast list
3. **Categories**: Auto-categorize podcasts into 12 predefined genres based on metadata
4. **Authentication**: Token persists across app restarts for seamless user experience

## 💡 Future Improvements

With more time, I would implement:

1. **Offline Mode**: Full offline support using Drift/Hive for caching
2. **Background Audio**: System notification controls using `audio_service`
3. **Push Notifications**: Firebase Cloud Messaging for new episode alerts
4. **Advanced Testing**: Golden tests for UI regression
5. **Accessibility**: Enhanced screen reader support
6. **iOS Version**: Full iOS implementation with platform-specific features

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Faith Adetunji**
- GitHub: [@decodedfaith](https://github.com/decodedfaith)  
- LinkedIn: [Faith Adetunji](https://www.linkedin.com/in/faithadetunji/)

## 🙏 Acknowledgments

- Jolly Podcast API for providing the backend services
- Flutter community for amazing packages and support
- Bloocode Technology for the coding assessment opportunity
- All contributors who help improve this project

## 📞 Support

For support, email komolafefaith@gmail.com or open an issue in this repository.

## 📚 Additional Documentation

- [Firebase App Distribution Setup](FIREBASE_SETUP.md)
- [Appetize.io Setup Guide](APPETIZE_SETUP.md)
- [Contributing Guidelines](CONTRIBUTING.md)

---

<div align="center">
  
**Built with ❤️ by [Faith (decodedfaith)](https://github.com/decodedfaith) using Flutter**

</div>
