import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/cupertino_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/storage/local_storage.dart';
import 'features/auth/auth_controller.dart';
import 'features/settings/providers/settings_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Play Jarvis bootup sound immediately on app start
  _playBootupSound();

  // Initialize local storage (flutter_secure_storage)
  final localStorage = LocalStorage();
  await localStorage.init();

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const JarvisApp(),
    ),
  );
}

/// Play the Jarvis bootup sound during app initialization
void _playBootupSound() async {
  try {
    final player = AudioPlayer();
    await player.setVolume(0.7);
    await player.play(AssetSource('sounds/jarvis-147563.mp3'));
  } catch (e) {
    debugPrint('Error playing bootup sound: $e');
  }
}

class JarvisApp extends ConsumerStatefulWidget {
  const JarvisApp({super.key});

  @override
  ConsumerState<JarvisApp> createState() => _JarvisAppState();
}

class _JarvisAppState extends ConsumerState<JarvisApp> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Use MaterialApp.router with both themes for proper theme switching
    // The Cupertino styling comes from our custom widgets and the CupertinoTheme
    return MaterialApp.router(
      title: 'Jarvis',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router
      routerConfig: router,

      // Wrap with CupertinoTheme for Cupertino widgets
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        return CupertinoTheme(
          data: JarvisCupertinoTheme.fromBrightness(brightness),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
