# 🚀 Quick Reference: APK Distribution

A quick guide to distribute your Jollycast APK using different methods.

## 📦 Distribution Methods Overview

| Method | Best For | Setup Time | Cost |
|--------|----------|------------|------|
| **GitHub Releases** | Developers, Portfolio | 5 min | Free |
| **Appetize.io** | Browser Demos, Portfolio | 10 min | Free (100 min/month) |
| **Firebase App Distribution** | Beta Testing | 15 min | Free |

---

## 🎯 Method 1: GitHub Releases (Automated)

**Use when**: Sharing with developers, adding to portfolio

### First-Time Setup (One-time)

1. Push your code to GitHub
2. That's it! The workflow is already configured.

### Creating a Release

```bash
# Tag your release
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will automatically:
# ✅ Build the APK
# ✅ Create a release
# ✅ Attach the APK file
```

### Sharing

Share this link:
```
https://github.com/YOUR_USERNAME/Jollycast/releases/latest
```

Or direct APK download:
```
https://github.com/YOUR_USERNAME/Jollycast/releases/latest/download/app-release.apk
```

---

## 🍊 Method 2: Appetize.io (Browser Demo)

**Use when**: Portfolio website, recruiters, no-install demos

### Quick Upload

```bash
# 1. Build APK
flutter build apk --release

# 2. Go to appetize.io/dashboard
# 3. Upload: build/app/outputs/flutter-apk/app-release.apk
# 4. Get your link and update README
```

### Your Demo Link Format
```
https://appetize.io/app/b_stft7q4fdfzrrci7ynwwxoim7u?device=pixel7&osVersion=13.0&scale=75
```

**📚 Full Guide**: See [APPETIZE_SETUP.md](APPETIZE_SETUP.md)

---

## 🔥 Method 3: Firebase App Distribution (Beta Testing)

**Use when**: Getting feedback from testers, controlled distribution

### Quick Setup

1. **Create Firebase Project**: [console.firebase.google.com](https://console.firebase.google.com)
2. **Get App ID**: Project Settings → Your apps → App ID
3. **Add GitHub Secrets**:
   - `FIREBASE_APP_ID`
   - `FIREBASE_CREDENTIALS`
4. **Run Workflow**: GitHub → Actions → "Firebase App Distribution" → Run workflow

### Inviting Testers

1. Firebase Console → App Distribution → Testers & Groups
2. Create group: `testers`
3. Add tester emails
4. They'll receive download link via email

**📚 Full Guide**: See [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

---

## 🔧 Manual Distribution Commands

### Build APK Locally

```bash
# Debug build
flutter build apk

# Release build (optimized)
flutter build apk --release

# Split APKs (smaller size)
flutter build apk --split-per-abi

# App bundle (for Play Store)
flutter build appbundle --release
```

### Firebase CLI Upload

```bash
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups testers \
  --release-notes "Bug fixes and improvements"
```

---

## 📱 Installing the APK

### Direct Install (Android)

1. Download APK file
2. Enable **Settings → Security → Unknown Sources**
3. Open APK file
4. Tap "Install"

### Via ADB

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎮 Demo Credentials

**Phone**: `08114227399`  
**Password**: `Development@101`

---

## 📂 File Locations

```
Jollycast/jollycast/
├── .github/workflows/
│   ├── build-android.yml          # Auto-build on tags
│   └── firebase-distribution.yml   # Firebase upload
├── build/app/outputs/flutter-apk/
│   └── app-release.apk            # Built APK (after build)
├── FIREBASE_SETUP.md              # Firebase guide
├── APPETIZE_SETUP.md              # Appetize guide
└── README.md                      # Updated with badges
```

---

## 🐛 Quick Troubleshooting

### Build fails with "No space left"
```bash
flutter clean
# Free up disk space
flutter build apk --release
```

### GitHub Actions not triggering
```bash
# Ensure tag is pushed
git tag v1.0.0
git push origin v1.0.0  # Don't forget this!
```

### APK won't install on device
- Check if "Unknown Sources" is enabled
- Ensure APK is a release build
- Try uninstalling old version first

### Appetize shows black screen
- Wait for app to fully load (can take 10-20 seconds)
- Try refreshing the page
- Check if APK is a valid release build

---

## 📊 Comparison Matrix

| Feature | GitHub | Appetize | Firebase |
|---------|--------|----------|----------|
| **Automated builds** | ✅ | ❌ | ✅ |
| **No install needed** | ❌ | ✅ | ❌ |
| **Version control** | ✅ | ✅ | ✅ |
| **Access control** | 🔓 Public | 🔓 Public | 🔒 Private |
| **Analytics** | Basic | Advanced | Advanced |
| **Feedback tools** | Issues | ❌ | ✅ |
| **Beta testing** | ⚠️ Manual | ❌ | ✅ |

---

## 🎯 Recommended Workflow

**For Portfolio/Demos**:
1. ✅ GitHub Releases (for download)
2. ✅ Appetize.io (for browser demo)

**For Development**:
1. ✅ GitHub Releases (version control)
2. ✅ Firebase (beta testing)

**All Three** = Maximum visibility! 🚀

---

## 📞 Need Help?

- **GitHub Actions**: Check logs in Actions tab
- **Appetize**: [docs.appetize.io](https://docs.appetize.io)
- **Firebase**: [firebase.google.com/docs/app-distribution](https://firebase.google.com/docs/app-distribution)

---

<div align="center">

**Quick Links**

[Firebase Guide](FIREBASE_SETUP.md) • [Appetize Guide](APPETIZE_SETUP.md) • [README](README.md)

</div>
