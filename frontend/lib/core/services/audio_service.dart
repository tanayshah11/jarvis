import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Audio service for Jarvis sound effects
///
/// Manages bootup sounds, UI feedback sounds, and voice cues
/// for an immersive Iron Man Jarvis experience.
class AudioService {
  final AudioPlayer _bootupPlayer = AudioPlayer();
  final AudioPlayer _uiPlayer = AudioPlayer();

  bool _initialized = false;
  bool _soundEnabled = true;

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Set audio context for proper iOS/Android playback
      await _bootupPlayer.setReleaseMode(ReleaseMode.stop);
      await _uiPlayer.setReleaseMode(ReleaseMode.stop);

      _initialized = true;
    } catch (e) {
      debugPrint('AudioService initialization error: $e');
    }
  }

  /// Enable or disable all sounds
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play the main bootup sequence sound
  /// This is the iconic Jarvis activation sound
  Future<void> playBootupSound() async {
    if (!_soundEnabled) return;

    try {
      await _bootupPlayer.setVolume(0.7);
      await _bootupPlayer.play(AssetSource('sounds/jarvis-147563.mp3'));
    } catch (e) {
      debugPrint('Error playing bootup sound: $e');
    }
  }

  /// Stop all currently playing sounds
  Future<void> stopAll() async {
    await _bootupPlayer.stop();
    await _uiPlayer.stop();
  }

  /// Dispose of audio players
  Future<void> dispose() async {
    await _bootupPlayer.dispose();
    await _uiPlayer.dispose();
  }
}

/// Provider for the audio service singleton
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
