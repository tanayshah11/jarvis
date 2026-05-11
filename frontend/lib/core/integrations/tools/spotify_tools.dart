import '../models/tool_definition.dart';
import '../tool_registry.dart';
import '../../services/oauth/spotify/spotify_service.dart';
import '../models/integration.dart';

/// Register Spotify tools with the tool registry
///
/// Provides AI-callable functions for Spotify playback control,
/// search, and playlist management.
void registerSpotifyTools(
  ToolRegistry registry,
  SpotifyService spotifyService,
) {
  // === Playback Control ===

  // spotify.now_playing - Get currently playing track
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.now_playing',
      description:
          'Get the currently playing track on Spotify including track name, '
          'artist, album, playback position, and device information',
      service: 'spotify',
      parameters: {},
      returnType: 'SpotifyPlaybackState',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'What song is playing on Spotify?',
        'What am I listening to?',
        'Show my current track',
      ],
    ),
    (params) async {
      final state = await spotifyService.getPlaybackState();
      if (state == null) {
        return {'error': 'No active playback or device found'};
      }
      return state.toJson();
    },
  );

  // spotify.play - Play a track/playlist
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.play',
      description:
          'Play a specific track, album, or playlist on Spotify. '
          'Requires a Spotify URI (e.g., spotify:track:xxx). '
          'Use spotify.search first to find URIs.',
      service: 'spotify',
      parameters: {
        'uri': ParamDef(
          type: 'string',
          description:
              'Spotify URI to play (spotify:track:xxx, spotify:album:xxx, or spotify:playlist:xxx)',
          required: false,
        ),
        'context_uri': ParamDef(
          type: 'string',
          description:
              'Context URI for album or playlist playback (alternative to uri)',
          required: false,
        ),
      },
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Play Bohemian Rhapsody',
        'Play my Chill playlist',
        'Resume playback',
      ],
    ),
    (params) async {
      await spotifyService.play(
        uri: params['uri'] as String?,
        contextUri: params['context_uri'] as String?,
      );
      return {'success': true, 'message': 'Playback started'};
    },
  );

  // spotify.pause - Pause playback
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.pause',
      description: 'Pause the current Spotify playback',
      service: 'spotify',
      parameters: {},
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Pause Spotify',
        'Stop the music',
        'Pause playback',
      ],
    ),
    (params) async {
      await spotifyService.pause();
      return {'success': true, 'message': 'Playback paused'};
    },
  );

  // spotify.next - Skip to next track
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.next',
      description: 'Skip to the next track on Spotify',
      service: 'spotify',
      parameters: {},
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Skip this song',
        'Next track',
        'Play next song',
      ],
    ),
    (params) async {
      await spotifyService.next();
      return {'success': true, 'message': 'Skipped to next track'};
    },
  );

  // spotify.previous - Skip to previous track
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.previous',
      description: 'Go back to the previous track on Spotify',
      service: 'spotify',
      parameters: {},
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Previous track',
        'Go back',
        'Play previous song',
      ],
    ),
    (params) async {
      await spotifyService.previous();
      return {'success': true, 'message': 'Skipped to previous track'};
    },
  );

  // spotify.add_to_queue - Add track to queue
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.add_to_queue',
      description:
          'Add a track to the playback queue. Requires a track URI. '
          'Use spotify.search first to find the track URI.',
      service: 'spotify',
      parameters: {
        'track_uri': ParamDef(
          type: 'string',
          description: 'Spotify track URI (spotify:track:xxx)',
          required: true,
        ),
      },
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Add this song to queue',
        'Queue up Imagine by John Lennon',
      ],
    ),
    (params) async {
      final trackUri = params['track_uri'] as String;
      await spotifyService.addToQueue(trackUri);
      return {'success': true, 'message': 'Track added to queue'};
    },
  );

  // spotify.set_volume - Set playback volume
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.set_volume',
      description: 'Set the playback volume (0-100)',
      service: 'spotify',
      parameters: {
        'volume': ParamDef(
          type: 'number',
          description: 'Volume level from 0 (mute) to 100 (max)',
          required: true,
        ),
      },
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Set volume to 50',
        'Turn volume down to 20',
        'Max volume',
      ],
    ),
    (params) async {
      final volume = params['volume'] as int;
      await spotifyService.setVolume(volume);
      return {'success': true, 'message': 'Volume set to $volume'};
    },
  );

  // === Search ===

  // spotify.search - Search tracks/artists/albums
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.search',
      description:
          'Search for tracks, artists, albums, or playlists on Spotify. '
          'Returns results with URIs that can be used with spotify.play.',
      service: 'spotify',
      parameters: {
        'query': ParamDef(
          type: 'string',
          description: 'Search query (e.g., track name, artist, album)',
          required: true,
        ),
        'types': ParamDef(
          type: 'array',
          description: 'Types to search for',
          itemType: 'string',
          defaultValue: ['track'],
        ),
        'limit': ParamDef(
          type: 'number',
          description: 'Number of results per type (1-50)',
          defaultValue: 10,
        ),
      },
      returnType: 'SpotifySearchResults',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Search for Radiohead on Spotify',
        'Find the song Bohemian Rhapsody',
        'Search for jazz playlists',
      ],
    ),
    (params) async {
      final query = params['query'] as String;
      final types = params['types'] != null
          ? (params['types'] as List<dynamic>).map((t) => t as String).toList()
          : ['track'];
      final limit = params['limit'] as int? ?? 10;

      final results = await spotifyService.search(
        query,
        types: types,
        limit: limit,
      );
      return results.toJson();
    },
  );

  // === Playlists ===

  // spotify.get_playlists - Get user's playlists
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.get_playlists',
      description: 'Get the current user\'s Spotify playlists',
      service: 'spotify',
      parameters: {
        'limit': ParamDef(
          type: 'number',
          description: 'Number of playlists to return (1-50)',
          defaultValue: 20,
        ),
      },
      returnType: 'List<SpotifyPlaylist>',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Show my Spotify playlists',
        'List my playlists',
        'What playlists do I have?',
      ],
    ),
    (params) async {
      final limit = params['limit'] as int? ?? 20;
      final playlists = await spotifyService.getMyPlaylists(limit: limit);
      return playlists.map((p) => p.toJson()).toList();
    },
  );

  // spotify.get_playlist_tracks - Get tracks from a playlist
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.get_playlist_tracks',
      description: 'Get tracks from a specific playlist',
      service: 'spotify',
      parameters: {
        'playlist_id': ParamDef(
          type: 'string',
          description: 'Spotify playlist ID',
          required: true,
        ),
        'limit': ParamDef(
          type: 'number',
          description: 'Number of tracks to return (1-100)',
          defaultValue: 50,
        ),
      },
      returnType: 'List<SpotifyTrack>',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
    ),
    (params) async {
      final playlistId = params['playlist_id'] as String;
      final limit = params['limit'] as int? ?? 50;
      final tracks = await spotifyService.getPlaylistTracks(
        playlistId,
        limit: limit,
      );
      return tracks.map((t) => t.toJson()).toList();
    },
  );

  // === User Library ===

  // spotify.get_saved_tracks - Get user's liked songs
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.get_saved_tracks',
      description: 'Get the user\'s saved (liked) tracks',
      service: 'spotify',
      parameters: {
        'limit': ParamDef(
          type: 'number',
          description: 'Number of tracks to return (1-50)',
          defaultValue: 20,
        ),
      },
      returnType: 'List<SpotifyTrack>',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Show my liked songs',
        'What are my favorite tracks?',
      ],
    ),
    (params) async {
      final limit = params['limit'] as int? ?? 20;
      final tracks = await spotifyService.getSavedTracks(limit: limit);
      return tracks.map((t) => t.toJson()).toList();
    },
  );

  // spotify.get_top_tracks - Get user's top tracks
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.get_top_tracks',
      description: 'Get the user\'s top tracks over different time periods',
      service: 'spotify',
      parameters: {
        'limit': ParamDef(
          type: 'number',
          description: 'Number of tracks to return (1-50)',
          defaultValue: 20,
        ),
        'time_range': ParamDef(
          type: 'string',
          description: 'Time range for top tracks',
          enumValues: ['short_term', 'medium_term', 'long_term'],
          defaultValue: 'medium_term',
        ),
      },
      returnType: 'List<SpotifyTrack>',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'What are my top songs this month?',
        'Show my most played tracks',
      ],
    ),
    (params) async {
      final limit = params['limit'] as int? ?? 20;
      final timeRange = params['time_range'] as String? ?? 'medium_term';
      final tracks = await spotifyService.getTopTracks(
        limit: limit,
        timeRange: timeRange,
      );
      return tracks.map((t) => t.toJson()).toList();
    },
  );

  // spotify.shuffle - Set shuffle mode
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.shuffle',
      description: 'Enable or disable shuffle mode',
      service: 'spotify',
      parameters: {
        'state': ParamDef(
          type: 'boolean',
          description: 'true to enable shuffle, false to disable',
          required: true,
        ),
      },
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Turn on shuffle',
        'Disable shuffle',
        'Shuffle my playlist',
      ],
    ),
    (params) async {
      final state = params['state'] as bool;
      await spotifyService.setShuffle(state);
      return {
        'success': true,
        'message': 'Shuffle ${state ? 'enabled' : 'disabled'}'
      };
    },
  );

  // spotify.repeat - Set repeat mode
  registry.registerTool(
    const ToolDefinition(
      name: 'spotify.repeat',
      description: 'Set repeat mode (off, track, or context)',
      service: 'spotify',
      parameters: {
        'state': ParamDef(
          type: 'string',
          description: 'Repeat mode',
          enumValues: ['off', 'track', 'context'],
          required: true,
        ),
      },
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Turn on repeat',
        'Repeat this track',
        'Turn off repeat',
      ],
    ),
    (params) async {
      final state = params['state'] as String;
      await spotifyService.setRepeat(state);
      return {'success': true, 'message': 'Repeat mode set to $state'};
    },
  );
}
