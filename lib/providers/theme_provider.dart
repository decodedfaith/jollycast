import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple [Notifier] that holds the current theme mode.
/// `true` means dark mode, `false` means light mode.
final themeProvider = NotifierProvider<ThemeNotifier, bool>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // start with light mode
  }

  void toggle() {
    state = !state;
  }
}
