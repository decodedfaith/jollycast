# Performance Testing Guide

This guide explains how to run performance tests and profile the Jollycast app to ensure 60 FPS performance.

## 1. Quick Start (VS Code)

I've created a launch configuration for you.

1.  Go to the **Run and Debug** tab in VS Code.
2.  Select **"Run Performance Test"** from the dropdown.
3.  Click the green play button.

This will run the automated performance test in **Profile Mode** on your connected device.

## 2. Manual Profiling

To manually check performance:

1.  Select **"jollycast (Profile Mode)"** in the Run and Debug tab.
2.  Run the app.
3.  Open **Flutter DevTools** (click the blue dart icon in the debug toolbar or run `dart devtools`).
4.  Go to the **Performance** tab.
5.  Enable **"Track Widget Builds"**.
6.  Use the app and look for:
    *   **Jank**: Red bars in the frames chart (taking > 16ms).
    *   **Shader Compilation**: First-run jank (normal on first launch).
    *   **GC**: Garbage collection spikes.

## 3. Automated Performance Test

The test file is located at `integration_test/performance_test.dart`.

It measures:
*   **Startup Time**: Time to reach the home screen.
*   **Scrolling Performance**: Flings the podcast list up and down.
*   **Navigation Performance**: Switches tabs.

### Running via Terminal

```bash
flutter run --profile -t integration_test/performance_test.dart
```

## 4. Common Performance Issues & Fixes

| Issue | Solution |
|-------|----------|
| **Uncached Images** | Use `CachedNetworkImage` instead of `Image.network`. |
| **List Jank** | Use `ListView.builder` and `const` widgets. |
| **Build Method Cost** | Avoid complex logic in `build()`. Use `Riverpod` selectors. |
| **Over-rebuilding** | Use `Consumer` widgets for granular updates. |

## 5. Interpreting Results

*   **Average Frame Build Time**: Should be < 8ms.
*   **Average Frame Rasterizer Time**: Should be < 8ms.
*   **Missed Frames (Jank)**: Should be 0 or very close to 0.
