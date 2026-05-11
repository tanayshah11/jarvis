import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../integrations/integration_manager.dart';
import 'spotify_models.dart';

/// Exception when Spotify is not authenticated
class SpotifyNotAuthenticatedException implements Exception {
  @override
  String toString() => 'Spotify is not authenticated. Please connect first.';
}

/// Exception for Spotify API errors
class SpotifyApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  SpotifyApiException(this.statusCode, this.message, [this.data]);

  @override
  String toString() => 'Spotify API error [$statusCode]: $message';
}

/// Service for interacting with Spotify API
///
/// Handles playback control, search, playlists, and user data.
/// Automatically manages OAuth token refresh through IntegrationManager.
class SpotifyService {
  static const _baseUrl = 'https://api.spotify.com/v1';
  final Dio _dio;
  final IntegrationManager _integrationManager;

  SpotifyService({required IntegrationManager integrationManager})
      : _integrationManager = integrationManager,
        _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          validateStatus: (status) {
            // Don't throw on 204 (No Content) or 404 (common for player state)
            return status != null && status < 500;
          },
        )) {
    // Add error interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid
          throw SpotifyNotAuthenticatedException();
        }
        return handler.next(error);
      },
    ));
  }

  /// Get authorization header with valid token
  Future<Map<String, String>> _getHeaders() async {
    final tokens = await _integrationManager.getTokens('spotify');
    if (tokens == null) throw SpotifyNotAuthenticatedException();
    return {'Authorization': 'Bearer ${tokens.accessToken}'};
  }

  /// Handle API response
  T _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (response.statusCode == 204) {
      throw SpotifyApiException(204, 'No content available');
    }

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message = response.data?['error']?['message'] ?? 'Unknown error';
      throw SpotifyApiException(response.statusCode!, message, response.data);
    }

    return parser(response.data as Map<String, dynamic>);
  }

  // === Playback Control ===

  /// Get current playback state
  ///
  /// Returns null if no active device or nothing is playing.
  Future<SpotifyPlaybackState?> getPlaybackState() async {
    try {
      final response = await _dio.get(
        '/me/player',
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 204 || response.data == null) {
        return null; // No active device
      }

      return SpotifyPlaybackState.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 204) return null;
      rethrow;
    }
  }

  /// Get currently playing track
  Future<SpotifyTrack?> getCurrentTrack() async {
    final state = await getPlaybackState();
    return state?.track;
  }

  /// Play a track, album, or playlist
  ///
  /// [uri] - Single track URI (spotify:track:xxx)
  /// [contextUri] - Album or playlist URI (spotify:album:xxx or spotify:playlist:xxx)
  /// [positionMs] - Start position in milliseconds
  Future<void> play({
    String? uri,
    String? contextUri,
    int? positionMs,
  }) async {
    final body = <String, dynamic>{};
    if (uri != null) body['uris'] = [uri];
    if (contextUri != null) body['context_uri'] = contextUri;
    if (positionMs != null) body['position_ms'] = positionMs;

    final response = await _dio.put(
      '/me/player/play',
      data: body.isNotEmpty ? body : null,
      options: Options(headers: await _getHeaders()),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message = response.data?['error']?['message'] ??
          'Failed to start playback';
      throw SpotifyApiException(response.statusCode!, message);
    }
  }

  /// Pause playback
  Future<void> pause() async {
    final response = await _dio.put(
      '/me/player/pause',
      options: Options(headers: await _getHeaders()),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message =
          response.data?['error']?['message'] ?? 'Failed to pause playback';
      throw SpotifyApiException(response.statusCode!, message);
    }
  }

  /// Skip to next track
  Future<void> next() async {
    final response = await _dio.post(
      '/me/player/next',
      options: Options(headers: await _getHeaders()),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message =
          response.data?['error']?['message'] ?? 'Failed to skip to next';
      throw SpotifyApiException(response.statusCode!, message);
    }
  }

  /// Skip to previous track
  Future<void> previous() async {
    final response = await _dio.post(
      '/me/player/previous',
      options: Options(headers: await _getHeaders()),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message = response.data?['error']?['message'] ??
          'Failed to skip to previous';
      throw SpotifyApiException(response.statusCode!, message);
    }
  }

  /// Add track to queue
  ///
  /// [trackUri] - URI of the track to add (spotify:track:xxx)
  Future<void> addToQueue(String trackUri) async {
    final response = await _dio.post(
      '/me/player/queue',
      queryParameters: {'uri': trackUri},
      options: Options(headers: await _getHeaders()),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message =
          response.data?['error']?['message'] ?? 'Failed to add to queue';
      throw SpotifyApiException(response.statusCode!, message);
    }
  }

  /// Set volume (0-100)
  Future<void> setVolume(int volumePercent) async {
    if (volumePercent < 0 || volumePercent > 100) {
      throw ArgumentError('Volume must be between 0 and 100');
    }

    final response = await _dio.put(
      '/me/player/volume',
      queryParameters: {'volume_percent': volumePercent},
      options: Options(headers: await _getHeaders()),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message =
          response.data?['error']?['message'] ?? 'Failed to set volume';
      throw SpotifyApiException(response.statusCode!, message);
    }
  }

  /// Set shuffle state
  Future<void> setShuffle(bool state) async {
    final response = await _dio.put(
      '/me/player/shuffle',
      queryParameters: {'state': state},
      options: Options(headers: await _getHeaders()),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message =
          response.data?['error']?['message'] ?? 'Failed to set shuffle';
      throw SpotifyApiException(response.statusCode!, message);
    }
  }

  /// Set repeat mode
  ///
  /// [state] - "off", "track", or "context"
  Future<void> setRepeat(String state) async {
    if (!['off', 'track', 'context'].contains(state)) {
      throw ArgumentError('Repeat state must be "off", "track", or "context"');
    }

    final response = await _dio.put(
      '/me/player/repeat',
      queryParameters: {'state': state},
      options: Options(headers: await _getHeaders()),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      final message =
          response.data?['error']?['message'] ?? 'Failed to set repeat';
      throw SpotifyApiException(response.statusCode!, message);
    }
  }

  // === Search ===

  /// Search Spotify
  ///
  /// [query] - Search query string
  /// [types] - Types to search: track, artist, album, playlist
  /// [limit] - Number of results per type (max 50)
  Future<SpotifySearchResults> search(
    String query, {
    List<String> types = const ['track', 'artist', 'album', 'playlist'],
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 50) {
      throw ArgumentError('Limit must be between 1 and 50');
    }

    final response = await _dio.get(
      '/search',
      queryParameters: {
        'q': query,
        'type': types.join(','),
        'limit': limit,
      },
      options: Options(headers: await _getHeaders()),
    );

    return _handleResponse(
      response,
      (data) => SpotifySearchResults.fromJson(data),
    );
  }

  /// Search for tracks only
  Future<List<SpotifyTrack>> searchTracks(String query, {int limit = 20}) async {
    final results = await search(query, types: ['track'], limit: limit);
    return results.tracks;
  }

  // === Playlists ===

  /// Get user's playlists
  Future<List<SpotifyPlaylist>> getMyPlaylists({int limit = 50}) async {
    if (limit < 1 || limit > 50) {
      throw ArgumentError('Limit must be between 1 and 50');
    }

    final response = await _dio.get(
      '/me/playlists',
      queryParameters: {'limit': limit},
      options: Options(headers: await _getHeaders()),
    );

    final data = response.data as Map<String, dynamic>;
    return (data['items'] as List<dynamic>)
        .map((p) => SpotifyPlaylist.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get playlist tracks
  Future<List<SpotifyTrack>> getPlaylistTracks(
    String playlistId, {
    int limit = 100,
  }) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError('Limit must be between 1 and 100');
    }

    final response = await _dio.get(
      '/playlists/$playlistId/tracks',
      queryParameters: {'limit': limit},
      options: Options(headers: await _getHeaders()),
    );

    final data = response.data as Map<String, dynamic>;
    return (data['items'] as List<dynamic>)
        .where((item) => item['track'] != null) // Filter out null tracks
        .map((item) =>
            SpotifyTrack.fromJson(item['track'] as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific playlist
  Future<SpotifyPlaylist> getPlaylist(String playlistId) async {
    final response = await _dio.get(
      '/playlists/$playlistId',
      options: Options(headers: await _getHeaders()),
    );

    return _handleResponse(
      response,
      (data) => SpotifyPlaylist.fromJson(data),
    );
  }

  // === User ===

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(
      '/me',
      options: Options(headers: await _getHeaders()),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get user's saved tracks (liked songs)
  Future<List<SpotifyTrack>> getSavedTracks({int limit = 50}) async {
    if (limit < 1 || limit > 50) {
      throw ArgumentError('Limit must be between 1 and 50');
    }

    final response = await _dio.get(
      '/me/tracks',
      queryParameters: {'limit': limit},
      options: Options(headers: await _getHeaders()),
    );

    final data = response.data as Map<String, dynamic>;
    return (data['items'] as List<dynamic>)
        .map((item) =>
            SpotifyTrack.fromJson(item['track'] as Map<String, dynamic>))
        .toList();
  }

  /// Get user's top tracks
  Future<List<SpotifyTrack>> getTopTracks({
    int limit = 20,
    String timeRange = 'medium_term', // short_term, medium_term, long_term
  }) async {
    if (limit < 1 || limit > 50) {
      throw ArgumentError('Limit must be between 1 and 50');
    }

    final response = await _dio.get(
      '/me/top/tracks',
      queryParameters: {
        'limit': limit,
        'time_range': timeRange,
      },
      options: Options(headers: await _getHeaders()),
    );

    final data = response.data as Map<String, dynamic>;
    return (data['items'] as List<dynamic>)
        .map((t) => SpotifyTrack.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get user's top artists
  Future<List<SpotifyArtist>> getTopArtists({
    int limit = 20,
    String timeRange = 'medium_term',
  }) async {
    if (limit < 1 || limit > 50) {
      throw ArgumentError('Limit must be between 1 and 50');
    }

    final response = await _dio.get(
      '/me/top/artists',
      queryParameters: {
        'limit': limit,
        'time_range': timeRange,
      },
      options: Options(headers: await _getHeaders()),
    );

    final data = response.data as Map<String, dynamic>;
    return (data['items'] as List<dynamic>)
        .map((a) => SpotifyArtist.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  // === Devices ===

  /// Get available devices
  Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await _dio.get(
      '/me/player/devices',
      options: Options(headers: await _getHeaders()),
    );

    final data = response.data as Map<String, dynamic>;
    return (data['devices'] as List<dynamic>)
        .map((d) => d as Map<String, dynamic>)
        .toList();
  }
}

/// Riverpod provider for Spotify service
final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  final integrationManager = ref.watch(integrationManagerProvider);
  return SpotifyService(integrationManager: integrationManager);
});
