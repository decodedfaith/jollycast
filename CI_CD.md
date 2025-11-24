# CI/CD Pipeline Documentation

## Overview

This project uses GitHub Actions for continuous integration and continuous deployment (CI/CD). The pipeline automates testing, code quality checks, building, and deployment.

## Workflow Triggers

The CI/CD pipeline runs on:
- **Push** to `main` or `develop` branches
- **Pull Requests** targeting `main` or `develop` branches

## Pipeline Jobs

### 1. Code Analysis (`analyze`)
**Purpose**: Ensures code quality and formatting standards

**Steps**:
- Checkout code
- Setup Flutter environment
- Install dependencies
- Verify code formatting (`dart format`)
- Run static code analysis (`flutter analyze`)

**Runs on**: Ubuntu Latest

---

### 2. Unit & Widget Tests (`test`)
**Purpose**: Executes all unit and widget tests

**Steps**:
- Checkout code
- Setup Flutter environment
- Install dependencies
- Run tests with coverage (`flutter test --coverage`)
- Upload coverage to Codecov

**Tests Executed**:
- SearchService unit tests (9 tests)
- UserPreferencesService unit tests (9 tests)
- MiniPlayer widget tests (3 tests)
- **Total**: 21+ automated tests

**Runs on**: Ubuntu Latest

---

### 3. Build Android (`build-android`)
**Purpose**: Builds release APK for Android

**Steps**:
- Checkout code
- Setup Flutter environment
- Install dependencies
- Build APK (`flutter build apk --release`)
- Upload APK as artifact (7-day retention)

**Output**: `app-release.apk`

**Runs on**: Ubuntu Latest
**Depends on**: `analyze`, `test`

---

### 4. Build iOS (`build-ios`)
**Purpose**: Builds iOS app (unsigned)

**Steps**:
- Checkout code
- Setup Flutter environment (on macOS)
- Install dependencies
- Build iOS (`flutter build ios --release --no-codesign`)
- Upload build as artifact (7-day retention)

**Output**: iOS build directory

**Runs on**: macOS Latest
**Depends on**: `analyze`, `test`

---

### 5. Integration Tests (`integration-test`)
**Purpose**: Runs full app integration tests

**Steps**:
- Checkout code
- Setup Flutter environment (on macOS for simulators)
- Install dependencies
- Run integration tests (`flutter test integration_test/app_test.dart`)

**Tests Executed**:
- Login flow test
- Search flow test  
- Categories navigation test
- Library tab test
- Podcast to player navigation test
- Favorite toggle test
- Tab navigation test

**Runs on**: macOS Latest
**Depends on**: `analyze`, `test`

---

### 6. Deploy (`deploy`)
**Purpose**: Deploys to production

**Trigger**: Only on push to `main` branch with tags

**Steps**:
- Checkout code
- Download Android artifact
- Create GitHub Release with APK
- (Optional) Deploy to app stores

**Runs on**: Ubuntu Latest
**Depends on**: `build-android`, `build-ios`

---

## Local Testing

### Run Unit Tests
```bash
flutter test
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Integration Tests
```bash
flutter test integration_test/app_test.dart
```

### Run Specific Test File
```bash
flutter test test/services/search_service_test.dart
```

---

## Code Quality Standards

### Formatting
All code must pass `dart format` checks:
```bash
dart format .
```

### Analysis
All code must pass static analysis:
```bash
flutter analyze
```

### Test Coverage
- Minimum 70% code coverage required
- All core services must have unit tests
- All major UI components must have widget tests

---

## Branch Protection Rules

### Main Branch
- ✅ Require pull request reviews (1 approver)
- ✅ Require status checks to pass
  - Code Analysis
  - Unit & Widget Tests
  - Build Android
  - Build iOS
- ✅ Require branches to be up to date
- ✅ No direct pushes allowed

### Develop Branch
- ✅ Require status checks to pass
  - Code Analysis
  - Unit & Widget Tests
- ✅ Allow direct pushes from maintainers

---

## Artifacts

### Android APK
- **Location**: `build/app/outputs/flutter-apk/app-release.apk`
- **Retention**: 7 days
- **Download**: Available in GitHub Actions run

### iOS Build
- **Location**: `build/ios/iphoneos/`
- **Retention**: 7 days
- **Download**: Available in GitHub Actions run

### Test Coverage
- **Location**: `coverage/lcov.info`
- **Uploaded to**: Codecov
- **View**: Check Codecov dashboard

---

## Environment Variables

### Required Secrets

None currently required for basic CI/CD.

### Optional Secrets (for deployment)

- `ANDROID_KEYSTORE`: Android signing keystore (Base64 encoded)
- `ANDROID_KEYSTORE_PASSWORD`: Keystore password
- `ANDROID_KEY_ALIAS`: Key alias
- `ANDROID_KEY_PASSWORD`: Key password
- `FIREBASE_TOKEN`: Firebase CLI token for App Distribution
- `APPLE_CERTIFICATES`: iOS signing certificates
- `APPLE_PROVISIONING_PROFILE`: iOS provisioning profile

---

## Deployment

### Manual Deployment

#### Android
```bash
flutter build apk --release
# Upload to Google Play Console
```

#### iOS
```bash
flutter build ios --release
# Archive in Xcode and upload to App Store Connect
```

### Automated Deployment

Configured to deploy on:
- Push to `main` with version tag (e.g., `v1.0.0`)
- Creates GitHub Release with APK

**To Deploy**:
```bash
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1
```

---

## Troubleshooting

### Pipeline Fails on Code Analysis
- Run `dart format .` locally
- Run `flutter analyze` and fix issues
- Commit and push fixes

### Tests Fail Locally But Pass in CI
- Clear Flutter cache: `flutter clean && flutter pub get`
- Check Flutter version matches CI
- Verify mock data is properly set up

### Build Fails
- Check `pubspec.yaml` dependencies
- Verify assets are properly configured
- Check for platform-specific issues

### Integration Tests Timeout
- Increase timeout in test
- Check for infinite loops or blocking calls
- Verify async operations complete

---

## Best Practices

1. **Always run tests locally** before pushing
2. **Use feature branches** for new development
3. **Write tests** for new features
4. **Keep builds green** - fix failing builds immediately
5. **Review code coverage** - aim for >70%
6. **Update documentation** when changing workflows

---

## Monitoring

### Check Pipeline Status
- View on GitHub Actions tab
- Status badges in README (can be added)

### Review Test Results
- Click on failed jobs to see logs
- Download artifacts for investigation

### Track Coverage
- View Codecov dashboard
- Monitor coverage trends over time

---

## Future Enhancements

- [ ] Add performance testing
- [ ] Add security scanning (SAST)
- [ ] Add dependency vulnerability scanning
- [ ] Implement automatic versioning
- [ ] Add Slack/Discord notifications
- [ ] Deploy to Firebase App Distribution
- [ ] Deploy to TestFlight automatically
