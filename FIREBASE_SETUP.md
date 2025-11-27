# 🔥 Firebase App Distribution Setup Guide

This guide walks you through setting up Firebase App Distribution for beta testing your Jollycast APK.

## 📋 Prerequisites

- Firebase account (free tier works)
- Firebase CLI installed
- GitHub repository with admin access

## 🚀 Step-by-Step Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `Jollycast` (or your preferred name)
4. Follow the setup wizard (Google Analytics is optional)
5. Click **"Create project"**

### 2. Add Android App to Firebase

1. In your Firebase project, click the **Android icon** to add an Android app
2. Enter the Android package name: `com.example.jollycast` (or your actual package name from `android/app/build.gradle`)
3. (Optional) Enter app nickname: "Jollycast Android"
4. (Optional) Add SHA-1 certificate fingerprint
5. Click **"Register app"**
6. Download `google-services.json`
7. **Do NOT commit this file** - it's already in `.gitignore`

### 3. Enable App Distribution

1. In Firebase Console, navigate to **Release & Monitor** > **App Distribution**
2. Click **"Get started"**
3. Firebase App Distribution is now enabled for your project

### 4. Install Firebase CLI

```bash
# Using npm
npm install -g firebase-tools

# Or using curl (Mac/Linux)
curl -sL https://firebase.tools | bash
```

Verify installation:
```bash
firebase --version
```

### 5. Login to Firebase CLI

```bash
firebase login
```

This will open a browser window for authentication.

### 6. Generate Service Account for GitHub Actions

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to **IAM & Admin** > **Service Accounts**
4. Click **"Create Service Account"**
   - Name: `github-actions-firebase`
   - Description: "Service account for GitHub Actions CI/CD"
5. Click **"Create and Continue"**
6. Grant these roles:
   - **Firebase App Distribution Admin**
   - **Firebase Admin SDK Administrator Service Agent**
7. Click **"Continue"** and then **"Done"**
8. Click on the newly created service account
9. Go to **"Keys"** tab > **"Add Key"** > **"Create new key"**
10. Select **JSON** format
11. Click **"Create"** - a JSON file will download
12. **Keep this file secure** - you'll need it for GitHub secrets

### 7. Get Your Firebase App ID

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **"Your apps"** section
3. Find your Android app
4. Copy the **App ID** (format: `1:123456789:android:abc123def456`)

### 8. Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **"New repository secret"** and add:

**FIREBASE_APP_ID**
- Name: `FIREBASE_APP_ID`
- Value: Your Firebase App ID (from step 7)

**FIREBASE_CREDENTIALS**
- Name: `FIREBASE_CREDENTIALS`
- Value: Entire contents of the JSON file downloaded in step 6
- Paste the complete JSON content

### 9. Create Tester Groups

1. In Firebase Console > **App Distribution**
2. Go to **"Testers & Groups"** tab
3. Click **"Add Group"**
4. Group name: `testers`
5. Add tester emails
6. Click **"Save"**

## 🎯 Using Firebase App Distribution

### Manual Upload via Firebase CLI

```bash
# Navigate to your project
cd /path/to/Jollycast/jollycast

# Build the APK
flutter build apk --release

# Upload to Firebase App Distribution
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups testers \
  --release-notes "New build for testing"
```

### Automated Upload via GitHub Actions

The workflow is already set up in `.github/workflows/firebase-distribution.yml`.

To trigger:

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **"Firebase App Distribution"** workflow
4. Click **"Run workflow"**
5. (Optional) Enter custom release notes
6. Click **"Run workflow"**

The workflow will:
- ✅ Build the APK
- ✅ Upload to Firebase App Distribution
- ✅ Notify testers via email

### Inviting Testers

Testers will receive an email invitation to download the app:

1. They click the link in the email
2. Sign in with their Google account (if needed)
3. Download and install the APK on their Android device
4. Provide feedback through Firebase App Distribution portal

## 🔐 Security Best Practices

- ✅ Never commit `google-services.json` to version control
- ✅ Never commit Firebase service account JSON keys
- ✅ Store all credentials in GitHub Secrets
- ✅ Rotate service account keys periodically
- ✅ Limit tester group access to trusted users

## 📊 Monitoring Distribution

In Firebase Console > App Distribution, you can:

- View distribution history
- See download statistics
- Manage tester groups
- View tester feedback
- Track app versions

## 🐛 Troubleshooting

### Issue: "App ID not found"
**Solution**: Verify your Firebase App ID in Project Settings and ensure it's correctly set in GitHub secrets.

### Issue: "Permission denied"
**Solution**: Ensure your service account has the correct roles (Firebase App Distribution Admin).

### Issue: "Workflow fails with authentication error"
**Solution**: Verify that `FIREBASE_CREDENTIALS` secret contains the complete JSON content.

### Issue: "Testers not receiving emails"
**Solution**: Check spam folders and verify tester email addresses in Firebase Console.

## 🎉 You're Done!

Your Firebase App Distribution is now set up! Testers in your group will receive notifications whenever you distribute a new build.

## 📚 Additional Resources

- [Firebase App Distribution Documentation](https://firebase.google.com/docs/app-distribution)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [GitHub Actions for Firebase](https://github.com/marketplace/actions/firebase-app-distribution)

---

Need help? Open an issue in the repository or contact the maintainer.
