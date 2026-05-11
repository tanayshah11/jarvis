# Spotify Integration Service

Complete Spotify API integration for Jarvis, providing playback control, search, playlists, and user library access.

## Features

### Playback Control
- Get current playback state and track
- Play/pause/skip tracks
- Control volume
- Add tracks to queue
- Shuffle and repeat modes

### Search
- Search tracks, artists, albums, and playlists
- Filtered search by type
- Configurable result limits

### Playlists
- Get user's playlists
- Get playlist tracks
- Access playlist metadata

### User Library
- Access saved (liked) tracks
- Get top tracks and artists
- View user profile
- Get available playback devices

## Installation

The service is already integrated into the Jarvis app. No additional setup required.

## OAuth Scopes Required

The following Spotify scopes are needed (configured in OAuth service):

```
user-read-playback-state      - Read playback state
user-modify-playback-state    - Control playback
user-read-currently-playing   - Get current track
playlist-read-private         - Access private playlists
playlist-read-collaborative   - Access collaborative playlists
user-library-read            - Access saved tracks
user-top-read                - Access top tracks/artists
```

## Usage

### Basic Service Usage

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/services/oauth/spotify/spotify.dart';

class SpotifyExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotifyService = ref.watch(spotifyServiceProvider);

    return FutureBuilder(
      future: spotifyService.getCurrentTrack(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final track = snapshot.data!;
          return Text('Now playing: ${track.name} by ${track.artistNames}');
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### Playback Control

```dart
final spotifyService = ref.read(spotifyServiceProvider);

// Get current playback state
final state = await spotifyService.getPlaybackState();
if (state != null) {
  print('Playing: ${state.track?.name}');
  print('Progress: ${state.progressMs}ms');
  print('Device: ${state.deviceName}');
}

// Control playback
await spotifyService.play(uri: 'spotify:track:3n3Ppam7vgaVa1iaRUc9Lp');
await spotifyService.pause();
await spotifyService.next();
await spotifyService.previous();

// Adjust volume
await spotifyService.setVolume(50); // 0-100

// Queue management
await spotifyService.addToQueue('spotify:track:xxx');

// Playback modes
await spotifyService.setShuffle(true);
await spotifyService.setRepeat('track'); // off, track, context
```

### Search

```dart
// Search everything
final results = await spotifyService.search('Radiohead');
print('Tracks: ${results.tracks.length}');
print('Artists: ${results.artists.length}');
print('Albums: ${results.albums.length}');
print('Playlists: ${results.playlists.length}');

// Search specific types
final trackResults = await spotifyService.search(
  'Bohemian Rhapsody',
  types: ['track'],
  limit: 10,
);

// Quick track search
final tracks = await spotifyService.searchTracks('Imagine');
```

### Playlists

```dart
// Get user's playlists
final playlists = await spotifyService.getMyPlaylists(limit: 50);
for (final playlist in playlists) {
  print('${playlist.name} by ${playlist.ownerName}');
  print('Tracks: ${playlist.trackCount}');
}

// Get specific playlist
final playlist = await spotifyService.getPlaylist('37i9dQZF1DXcBWIGoYBM5M');

// Get playlist tracks
final tracks = await spotifyService.getPlaylistTracks(
  '37i9dQZF1DXcBWIGoYBM5M',
  limit: 100,
);
```

### User Library

```dart
// Get saved (liked) tracks
final savedTracks = await spotifyService.getSavedTracks(limit: 50);

// Get top tracks
final topTracks = await spotifyService.getTopTracks(
  limit: 20,
  timeRange: 'short_term', // or medium_term, long_term
);

// Get top artists
final topArtists = await spotifyService.getTopArtists(
  timeRange: 'medium_term',
);

// Get user profile
final profile = await spotifyService.getProfile();
print('User: ${profile['display_name']}');
print('Followers: ${profile['followers']['total']}');
```

### Devices

```dart
// Get available devices
final devices = await spotifyService.getDevices();
for (final device in devices) {
  print('${device['name']} (${device['type']})');
  print('Active: ${device['is_active']}');
}
```

## AI Tool Integration

The Spotify service is automatically registered with the AI tool registry. The following tools are available:

### Playback Tools

- `spotify.now_playing` - Get currently playing track
- `spotify.play` - Play a track/playlist
- `spotify.pause` - Pause playback
- `spotify.next` - Skip to next track
- `spotify.previous` - Skip to previous track
- `spotify.add_to_queue` - Add track to queue
- `spotify.set_volume` - Set volume (0-100)
- `spotify.shuffle` - Enable/disable shuffle
- `spotify.repeat` - Set repeat mode

### Search Tools

- `spotify.search` - Search tracks/artists/albums/playlists

### Playlist Tools

- `spotify.get_playlists` - Get user's playlists
- `spotify.get_playlist_tracks` - Get tracks from a playlist

### Library Tools

- `spotify.get_saved_tracks` - Get liked songs
- `spotify.get_top_tracks` - Get user's top tracks

### Example AI Usage

```
User: "What song am I listening to?"
AI: [calls spotify.now_playing]
AI: "You're listening to 'Bohemian Rhapsody' by Queen from the album 'A Night at the Opera'"

User: "Play some Radiohead"
AI: [calls spotify.search with query "Radiohead"]
AI: [calls spotify.play with first track URI]
AI: "Now playing 'Creep' by Radiohead"

User: "Skip this song"
AI: [calls spotify.next]
AI: "Skipped to the next track"
```

## Error Handling

The service provides specific exceptions for different error scenarios:

```dart
try {
  final track = await spotifyService.getCurrentTrack();
} on SpotifyNotAuthenticatedException {
  // User hasn't connected Spotify
  print('Please connect your Spotify account');
} on SpotifyApiException catch (e) {
  // API error (no active device, track not found, etc.)
  print('Spotify error: ${e.message}');
  if (e.statusCode == 204) {
    print('No active device found');
  }
} catch (e) {
  // Generic error
  print('Unexpected error: $e');
}
```

## Models

### SpotifyTrack
```dart
class SpotifyTrack {
  final String id;
  final String name;
  final String uri;
  final List<SpotifyArtist> artists;
  final SpotifyAlbum album;
  final int durationMs;
  final String? previewUrl;
  final bool isPlayable;

  String get artistNames; // Comma-separated artist names
}
```

### SpotifyArtist
```dart
class SpotifyArtist {
  final String id;
  final String name;
  final String uri;
  final List<String>? genres;
  final String? imageUrl;
}
```

### SpotifyAlbum
```dart
class SpotifyAlbum {
  final String id;
  final String name;
  final String uri;
  final String? imageUrl;
  final String releaseDate;
  final int totalTracks;
}
```

### SpotifyPlaylist
```dart
class SpotifyPlaylist {
  final String id;
  final String name;
  final String uri;
  final String? description;
  final String? imageUrl;
  final String ownerName;
  final int trackCount;
  final bool isPublic;
}
```

### SpotifyPlaybackState
```dart
class SpotifyPlaybackState {
  final SpotifyTrack? track;
  final bool isPlaying;
  final int progressMs;
  final String? deviceId;
  final String? deviceName;
  final int volumePercent;
  final String repeatState;      // "off", "track", "context"
  final bool shuffleState;
}
```

### SpotifySearchResults
```dart
class SpotifySearchResults {
  final List<SpotifyTrack> tracks;
  final List<SpotifyArtist> artists;
  final List<SpotifyAlbum> albums;
  final List<SpotifyPlaylist> playlists;

  bool get isEmpty;
  int get totalCount;
}
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  AI Assistant                        │
│  "Play Bohemian Rhapsody"                          │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│              Tool Registry                           │
│  - Routes to spotify.search                         │
│  - Then routes to spotify.play                      │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│          SpotifyService                              │
│  - Gets OAuth token from IntegrationManager         │
│  - Calls Spotify Web API                           │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│         Spotify Web API                              │
│  api.spotify.com/v1                                 │
│  - Returns track data                               │
│  - Controls playback                                │
└─────────────────────────────────────────────────────┘
```

## Token Management

Tokens are automatically managed by the `IntegrationManager`:

- Tokens are stored securely using `flutter_secure_storage`
- Access tokens are automatically refreshed when needed
- 401 errors trigger re-authentication flow
- Token expiration is checked before each request

## Testing

```dart
void main() {
  test('Search tracks', () async {
    final mockIntegrationManager = MockIntegrationManager();
    final spotifyService = SpotifyService(
      integrationManager: mockIntegrationManager,
    );

    final results = await spotifyService.searchTracks('test');
    expect(results, isNotEmpty);
  });
}
```

## Privacy & Security

- **OAuth Flow**: Secure OAuth 2.0 authentication
- **Token Storage**: Tokens encrypted in secure storage
- **No Data Persistence**: No music data cached locally
- **Privacy Level**: `PrivacyLevel.lowRisk` - only playback control
- **User Control**: Users can disconnect anytime

## Limitations

- Requires active Spotify Premium for playback control
- Must have an active device (app/web/hardware)
- Some endpoints require Spotify Premium subscription
- Rate limits apply (standard Spotify API limits)

## Related Files

- Service: `lib/core/services/oauth/spotify/spotify_service.dart`
- Models: `lib/core/services/oauth/spotify/spotify_models.dart`
- Tools: `lib/core/integrations/tools/spotify_tools.dart`
- Integration Manager: `lib/core/integrations/integration_manager.dart`

## Support

For Spotify API documentation: https://developer.spotify.com/documentation/web-api

For issues with the integration, check:
1. OAuth tokens are valid
2. User has Spotify Premium (for playback)
3. Active device is available
4. Required scopes are granted
