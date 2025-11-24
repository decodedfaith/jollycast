# Jollycast - Podcast App

A simplified podcast streaming application built with Flutter for the Bloocode Technology coding assessment.

## 📱 About

Jollycast is a modern, feature-rich podcast streaming application that allows users to discover, listen to, and manage their favorite podcasts. It is built with a focus on clean architecture, state management, and pixel-perfect UI implementation.
![Demo of Jollycast App](assets/mp4/demo.gif)

## 🛠️ Tech Stack & State Management

- **Framework:** Flutter (v3.0+)
- **Language:** Dart (v3.0+)
- **State Management:** **Riverpod** (v2.0+)
  - Chosen for its compile-time safety, testability, and separation of concerns.
  - Uses `NotifierProvider` and `AsyncNotifierProvider` for robust state handling.
- **Networking:** Dio (with interceptors for auth)
- **Local Storage:** SharedPreferences (for token and user preferences)
- **Audio:** just_audio

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK

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

## 🏗️ Project Structure

The project follows a **MVVM (Model-View-ViewModel)** architecture to ensure modularity and maintainability.

```
lib/
├── models/              # Data models (Episode, Podcast, Category)
├── services/            # API and local storage services
├── viewmodels/          # Riverpod notifiers (State Management)
├── views/               # UI Screens and Widgets
├── widgets/             # Reusable UI components
└── main.dart            # Entry point
```

## 📝 Assumptions Made

1. **Backend Availability:** Assumed the provided API is stable. Implemented client-side caching and error handling for resilience.
2. **Search Logic:** Since the API endpoint for search wasn't explicitly detailed in the brief, I implemented a client-side search that filters the fetched podcast list.
3. **Categories:** The API returns a flat list of podcasts. I assumed categories should be derived dynamically from the podcast content/metadata, so I implemented a logic to auto-categorize them into 12 predefined genres.
4. **Authentication:** Assumed the token returned from login is valid for the session duration. Implemented persistence to keep the user logged in across restarts.

## 🔮 What I would improve with more time

1. **Offline Mode:** Implement full offline support using a local database (like Drift or Hive) to cache podcasts and episodes for listening without internet.
2. **Background Audio Service:** Enhance the audio player to fully support background playback with system notification controls (using `audio_service`).
3. **Push Notifications:** Integrate Firebase Cloud Messaging for new episode alerts.
4. **Advanced Testing:** Expand the test suite to include Golden tests for UI regression and more comprehensive integration scenarios.
5. **Accessibility:** Audit and improve accessibility labels and navigation for screen readers.

## 🧪 Testing

The project includes a suite of automated tests.

Run unit and widget tests:
```bash
flutter test
```

## 📦 Key Features Implemented

- **Login Flow:** Secure authentication with error handling.
- **Podcast List:** Fetching and displaying podcasts with thumbnails.
- **Player:** Functional audio playback with play/pause, skip, and speed controls.
- **Search:** Debounced search functionality.
- **Favorites & History:** Local persistence for user preferences.
