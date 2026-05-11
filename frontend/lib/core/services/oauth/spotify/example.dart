/// Example usage of Spotify integration service.
///
/// This file demonstrates how to use the Spotify service in your Flutter app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'spotify.dart';

/// Example 1: Display currently playing track
class NowPlayingWidget extends ConsumerWidget {
  const NowPlayingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotifyService = ref.watch(spotifyServiceProvider);

    return FutureBuilder<SpotifyPlaybackState?>(
      future: spotifyService.getPlaybackState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final state = snapshot.data;
        if (state == null || state.track == null) {
          return const Text('Nothing playing');
        }

        final track = state.track!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(track.artistNames),
            Text(track.album.name),
            if (state.deviceName != null) Text('On: ${state.deviceName}'),
          ],
        );
      },
    );
  }
}

/// Example 2: Playback controls
class PlaybackControls extends ConsumerWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotifyService = ref.read(spotifyServiceProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: () => spotifyService.previous(),
        ),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => spotifyService.pause(),
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => spotifyService.play(),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () => spotifyService.next(),
        ),
      ],
    );
  }
}

/// Example 3: Search and play
class SpotifySearchExample extends ConsumerStatefulWidget {
  const SpotifySearchExample({super.key});

  @override
  ConsumerState<SpotifySearchExample> createState() =>
      _SpotifySearchExampleState();
}

class _SpotifySearchExampleState extends ConsumerState<SpotifySearchExample> {
  List<SpotifyTrack> searchResults = [];
  bool isLoading = false;

  Future<void> searchTracks(String query) async {
    setState(() => isLoading = true);

    try {
      final spotifyService = ref.read(spotifyServiceProvider);
      final results = await spotifyService.searchTracks(query, limit: 10);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  Future<void> playTrack(SpotifyTrack track) async {
    try {
      final spotifyService = ref.read(spotifyServiceProvider);
      await spotifyService.play(uri: track.uri);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Now playing: ${track.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search tracks',
            suffixIcon: Icon(Icons.search),
          ),
          onSubmitted: searchTracks,
        ),
        if (isLoading) const CircularProgressIndicator(),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final track = searchResults[index];
              return ListTile(
                leading: track.album.imageUrl != null
                    ? Image.network(track.album.imageUrl!, width: 50, height: 50)
                    : const Icon(Icons.music_note),
                title: Text(track.name),
                subtitle: Text(track.artistNames),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => playTrack(track),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Example 4: User's playlists
class PlaylistsList extends ConsumerWidget {
  const PlaylistsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotifyService = ref.watch(spotifyServiceProvider);

    return FutureBuilder<List<SpotifyPlaylist>>(
      future: spotifyService.getMyPlaylists(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final playlists = snapshot.data ?? [];
        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return ListTile(
              leading: playlist.imageUrl != null
                  ? Image.network(playlist.imageUrl!, width: 50, height: 50)
                  : const Icon(Icons.playlist_play),
              title: Text(playlist.name),
              subtitle: Text('${playlist.trackCount} tracks • ${playlist.ownerName}'),
              onTap: () async {
                // Play the playlist
                try {
                  await spotifyService.play(contextUri: playlist.uri);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Playing: ${playlist.name}')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}

/// Example 5: Volume control
class VolumeControl extends ConsumerStatefulWidget {
  const VolumeControl({super.key});

  @override
  ConsumerState<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends ConsumerState<VolumeControl> {
  double volume = 50;

  @override
  Widget build(BuildContext context) {
    final spotifyService = ref.read(spotifyServiceProvider);

    return Column(
      children: [
        Text('Volume: ${volume.toInt()}'),
        Slider(
          value: volume,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            setState(() => volume = value);
          },
          onChangeEnd: (value) async {
            try {
              await spotifyService.setVolume(value.toInt());
            } catch (e) {
              debugPrint('Error setting volume: $e');
            }
          },
        ),
      ],
    );
  }
}

/// Example 6: Register tools for AI usage
void registerSpotifyToolsExample(WidgetRef ref) {
  // Import required
  // import 'package:jarvis/core/integrations/tool_registry.dart';
  // import 'package:jarvis/core/integrations/tools/spotify_tools.dart';

  // This would be called at app startup
  /*
  final registry = ref.read(toolRegistryProvider);
  final spotifyService = ref.read(spotifyServiceProvider);

  registerSpotifyTools(registry, spotifyService);

  debugPrint('Registered Spotify tools: ${registry.getToolsForService('spotify').length}');
  */
}

/// Example 7: Error handling
class ErrorHandlingExample extends ConsumerWidget {
  const ErrorHandlingExample({super.key});

  Future<void> playWithErrorHandling(WidgetRef ref) async {
    final spotifyService = ref.read(spotifyServiceProvider);

    try {
      await spotifyService.play(uri: 'spotify:track:3n3Ppam7vgaVa1iaRUc9Lp');
    } on SpotifyNotAuthenticatedException {
      // Handle auth error
      debugPrint('Please connect Spotify first');
    } on SpotifyApiException catch (e) {
      if (e.statusCode == 204 || e.statusCode == 404) {
        debugPrint('No active device found. Please open Spotify.');
      } else {
        debugPrint('Spotify error: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => playWithErrorHandling(ref),
      child: const Text('Play Track'),
    );
  }
}

/// Example 8: Full-featured Spotify screen
class SpotifyScreen extends ConsumerWidget {
  const SpotifyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            NowPlayingWidget(),
            SizedBox(height: 16),
            PlaybackControls(),
            SizedBox(height: 16),
            VolumeControl(),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PlaylistsList(),
            ),
          ],
        ),
      ),
    );
  }
}
