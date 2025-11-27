# 🍊 Appetize.io Setup Guide

This guide shows you how to upload your Jollycast APK to Appetize.io for browser-based testing and demos.

## 🎯 What is Appetize.io?

Appetize.io allows you to run your Android or iOS app directly in a web browser - **no installation required**! It's perfect for:

- 🌐 **Portfolio Demos** - Embed live app demos in your portfolio website
- 📧 **Sharing with Recruiters** - Send a simple link instead of APK files
- 🎓 **Presentations** - Demo your app without device setup
- 🧪 **Quick Testing** - Test on different devices without owning them
- 📱 **README Badges** - Add "Try it now" buttons to your GitHub README

## 💰 Pricing

- **Free Tier**: 100 minutes/month of streaming time
- **Paid Plans**: Starting at $40/month for unlimited usage
- **Perfect for demos**: Free tier is usually sufficient for portfolio projects

## 🚀 Step-by-Step Setup

### 1. Create an Appetize.io Account

1. Go to [appetize.io](https://appetize.io)
2. Click **"Sign Up"** (top right)
3. Create an account with email or Google/GitHub
4. Verify your email

### 2. Build Your APK

First, ensure you have a release APK:

```bash
cd /path/to/Jollycast/jollycast
flutter build apk --release
```

Your APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Upload Your APK

#### Option A: Web Dashboard (Easiest)

1. Log into [appetize.io/dashboard](https://appetize.io/dashboard)
2. Click **"Upload App"**
3. Drag and drop `app-release.apk` or click to browse
4. Fill in the form:
   - **Platform**: Android
   - **App Name**: Jollycast
   - **Version**: 1.0.0 (or current version)
   - **Notes** (optional): Demo of Jollycast podcast streaming app
5. Click **"Upload"**
6. Wait for processing (usually 1-2 minutes)

#### Option B: API Upload (For Automation)

```bash
# Get your API token from: https://appetize.io/account
API_TOKEN="your_api_token_here"

# Upload the APK
curl -X POST https://api.appetize.io/v1/apps \
  -F "file=@build/app/outputs/flutter-apk/app-release.apk" \
  -F "platform=android" \
  -u "$API_TOKEN:"
```

### 4. Configure Your App

After upload, configure the app settings:

1. In the dashboard, click on your uploaded app
2. **Settings** you can configure:
   - **Device**: Choose Android device model (e.g., Pixel 7)
   - **OS Version**: Android version (e.g., Android 13)
   - **Orientation**: Portrait/Landscape
   - **Launch URL**: Deep link to open on start
   - **Debug Logs**: Enable for troubleshooting

**Recommended Settings for Jollycast:**
- Device: `pixel7`
- OS: `13.0`
- Orientation: `portrait`
- Scale: `75` (fits better in browser)

### 5. Get Your App Link

After upload, you'll receive:

1. **Public Key**: A unique identifier (e.g., `abc123def456`)
2. **Embed URL**: Direct link to your app
   ```
   https://appetize.io/app/YOUR_PUBLIC_KEY
   ```

### 6. Customize the Experience

Add parameters to your URL for better UX:

```
https://appetize.io/app/YOUR_PUBLIC_KEY?
  device=pixel7&
  osVersion=13.0&
  orientation=portrait&
  scale=75&
  autoplay=true&
  screenOnly=false&
  deviceColor=black
```

**Useful Parameters:**
- `autoplay=true` - Starts immediately (no play button)
- `screenOnly=false` - Shows device frame
- `scale=75` - Size of the device (50-100)
- `orientation=portrait` - Device orientation
- `deviceColor=black` - Device frame color
- `launchUrl=jollycast://` - Deep link to open on start

### 7. Update Your README

Replace the placeholder in your `README.md`:

```markdown
### Option 2: Try in Browser (Appetize.io)
[![Try on Appetize](https://img.shields.io/badge/Try%20Now-Appetize.io-orange?style=for-the-badge)](https://appetize.io/app/YOUR_PUBLIC_KEY?device=pixel7&osVersion=13.0&orientation=portrait&scale=75)
```

Replace `YOUR_PUBLIC_KEY` with your actual public key.

### 8. Embed in Your Portfolio Website

You can embed Appetize directly in your website:

```html
<iframe
  src="https://appetize.io/embed/YOUR_PUBLIC_KEY?device=pixel7&osVersion=13.0&orientation=portrait&scale=75&autoplay=true"
  width="378px"
  height="800px"
  frameborder="0"
  scrolling="no"
  style="border-radius: 20px;"
></iframe>
```

## 🎨 Advanced Features

### Auto-Login (Optional)

To automatically log users in for demos, you can use deep links:

1. Implement deep linking in your Flutter app
2. Create a launch URL: `jollycast://login?demo=true`
3. Handle this URL in your app to auto-fill credentials
4. Add to Appetize URL: `&launchUrl=jollycast://login?demo=true`

### Multiple Versions

Upload different versions for:
- **Production**: Latest stable release
- **Beta**: Testing new features
- **Demo**: Pre-configured with demo data

Each gets a unique public key for separate links.

### Usage Monitoring

In the Appetize dashboard, you can:
- View session statistics
- Track remaining free minutes
- See which devices are most used
- Download usage reports

## 📊 Best Practices

### For Demos
✅ Set `autoplay=true` - No play button needed
✅ Use `screenOnly=false` - Shows device frame for realism
✅ Choose `scale=75` - Good balance of size and visibility
✅ Enable `deviceColor=black` - Professional look

### For Testing
✅ Keep `screenOnly=true` - Focuses on app content
✅ Enable debug logs - Helps with troubleshooting
✅ Test on multiple device types - Ensure compatibility

### For Portfolio
✅ Embed directly in your website - Shows technical skills
✅ Add "Try Now" buttons - Encourages interaction
✅ Keep sessions short - Conserve free minutes
✅ Update regularly - Keep demo current with latest features

## 🔄 Updating Your App

When you release a new version:

### Option 1: New Upload
1. Upload new APK as a separate version
2. Get a new public key
3. Keep old version for comparison

### Option 2: Replace Existing
1. In dashboard, select your app
2. Click **"Upload New Build"**
3. Upload the new APK
4. **Same public key** - all links still work!

**Recommended**: Option 2 keeps your links working.

## 🐛 Troubleshooting

### Issue: App won't start
**Check:**
- APK is a release build (not debug)
- Minimum SDK version is compatible
- No missing native dependencies

### Issue: Slow loading
**Solutions:**
- Reduce APK size by:
  - Removing unused resources
  - Enabling ProGuard/R8
  - Using split APKs by ABI

### Issue: Out of free minutes
**Options:**
- Wait for monthly reset
- Upgrade to paid plan
- Use for important demos only
- Reduce session timeout settings

### Issue: Can't interact with app
**Check:**
- JavaScript is enabled in browser
- No browser extensions blocking iframes
- Try different browser (Chrome recommended)

## 📈 Monitoring Usage

Track your usage to stay within free tier:

1. **Dashboard**: `appetize.io/dashboard`
2. **Usage Tab**: View minutes consumed
3. **Set Alerts**: Get notified at 80% usage
4. **Session Timeout**: Configure auto-stop after inactivity

**Pro Tip**: Set session timeout to 2-3 minutes to conserve minutes.

## 🎯 Example Links

Here are example configurations for different use cases:

**Full Demo (with device frame)**
```
https://appetize.io/app/YOUR_KEY?device=pixel7&osVersion=13.0&scale=75&autoplay=true&screenOnly=false
```

**Quick Test (screen only)**
```
https://appetize.io/app/YOUR_KEY?device=pixel7&osVersion=13.0&scale=100&screenOnly=true
```

**Portfolio Embed (auto-start)**
```
https://appetize.io/embed/YOUR_KEY?device=pixel7&scale=75&autoplay=true&params=%7B%22EmbedId%22%3A%22jollycast-demo%22%7D
```

## 🎉 You're Done!

Your Jollycast app is now accessible in any browser! Share the link with:

- 📧 Recruiters and hiring managers
- 👥 Friends and beta testers  
- 🌐 In your portfolio website
- 📱 On GitHub README

## 📚 Additional Resources

- [Appetize.io Documentation](https://docs.appetize.io/)
- [API Reference](https://docs.appetize.io/api/overview)
- [Embed Guide](https://docs.appetize.io/embedding/embed-guide)
- [Pricing Plans](https://appetize.io/pricing)

---

**Pro Tip**: Add demo credentials in your Appetize session notes:
> Phone: `08114227399` • Password: `Development@101`

Need help? Open an issue in the repository or contact the maintainer.
