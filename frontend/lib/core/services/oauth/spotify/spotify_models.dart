/// Immutable models for Spotify API responses.
library;

/// Spotify artist
class SpotifyArtist {
  final String id;
  final String name;
  final String uri;
  final List<String>? genres;
  final String? imageUrl;

  const SpotifyArtist({
    required this.id,
    required this.name,
    required this.uri,
    this.genres,
    this.imageUrl,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['url'] as String?;
    }

    return SpotifyArtist(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      genres: (json['genres'] as List<dynamic>?)
          ?.map((g) => g as String)
          .toList(),
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uri': uri,
      if (genres != null) 'genres': genres,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

/// Spotify album
class SpotifyAlbum {
  final String id;
  final String name;
  final String uri;
  final String? imageUrl;
  final String releaseDate;
  final int totalTracks;

  const SpotifyAlbum({
    required this.id,
    required this.name,
    required this.uri,
    this.imageUrl,
    required this.releaseDate,
    required this.totalTracks,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['url'] as String?;
    }

    return SpotifyAlbum(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      imageUrl: imageUrl,
      releaseDate: json['release_date'] as String,
      totalTracks: json['total_tracks'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uri': uri,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'releaseDate': releaseDate,
      'totalTracks': totalTracks,
    };
  }
}

/// Spotify track
class SpotifyTrack {
  final String id;
  final String name;
  final String uri;
  final List<SpotifyArtist> artists;
  final SpotifyAlbum album;
  final int durationMs;
  final String? previewUrl;
  final bool isPlayable;

  const SpotifyTrack({
    required this.id,
    required this.name,
    required this.uri,
    required this.artists,
    required this.album,
    required this.durationMs,
    this.previewUrl,
    required this.isPlayable,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      artists: (json['artists'] as List<dynamic>)
          .map((a) => SpotifyArtist.fromJson(a as Map<String, dynamic>))
          .toList(),
      album: SpotifyAlbum.fromJson(json['album'] as Map<String, dynamic>),
      durationMs: json['duration_ms'] as int,
      previewUrl: json['preview_url'] as String?,
      isPlayable: json['is_playable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uri': uri,
      'artists': artists.map((a) => a.toJson()).toList(),
      'album': album.toJson(),
      'durationMs': durationMs,
      if (previewUrl != null) 'previewUrl': previewUrl,
      'isPlayable': isPlayable,
    };
  }

  /// Get artist names as comma-separated string
  String get artistNames => artists.map((a) => a.name).join(', ');
}

/// Spotify playlist
class SpotifyPlaylist {
  final String id;
  final String name;
  final String uri;
  final String? description;
  final String? imageUrl;
  final String ownerName;
  final int trackCount;
  final bool isPublic;

  const SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.uri,
    this.description,
    this.imageUrl,
    required this.ownerName,
    required this.trackCount,
    required this.isPublic,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['url'] as String?;
    }

    return SpotifyPlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      description: json['description'] as String?,
      imageUrl: imageUrl,
      ownerName: json['owner']['display_name'] as String? ??
          json['owner']['id'] as String,
      trackCount: json['tracks']['total'] as int,
      isPublic: json['public'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uri': uri,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'ownerName': ownerName,
      'trackCount': trackCount,
      'isPublic': isPublic,
    };
  }
}

/// Current playback state
class SpotifyPlaybackState {
  final SpotifyTrack? track;
  final bool isPlaying;
  final int progressMs;
  final String? deviceId;
  final String? deviceName;
  final int volumePercent;
  final String repeatState;
  final bool shuffleState;

  const SpotifyPlaybackState({
    this.track,
    required this.isPlaying,
    required this.progressMs,
    this.deviceId,
    this.deviceName,
    required this.volumePercent,
    required this.repeatState,
    required this.shuffleState,
  });

  factory SpotifyPlaybackState.fromJson(Map<String, dynamic> json) {
    SpotifyTrack? track;
    if (json['item'] != null) {
      track = SpotifyTrack.fromJson(json['item'] as Map<String, dynamic>);
    }

    String? deviceId;
    String? deviceName;
    if (json['device'] != null) {
      deviceId = json['device']['id'] as String?;
      deviceName = json['device']['name'] as String?;
    }

    return SpotifyPlaybackState(
      track: track,
      isPlaying: json['is_playing'] as bool? ?? false,
      progressMs: json['progress_ms'] as int? ?? 0,
      deviceId: deviceId,
      deviceName: deviceName,
      volumePercent: json['device']?['volume_percent'] as int? ?? 50,
      repeatState: json['repeat_state'] as String? ?? 'off',
      shuffleState: json['shuffle_state'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (track != null) 'track': track!.toJson(),
      'isPlaying': isPlaying,
      'progressMs': progressMs,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
      'volumePercent': volumePercent,
      'repeatState': repeatState,
      'shuffleState': shuffleState,
    };
  }
}

/// Search results
class SpotifySearchResults {
  final List<SpotifyTrack> tracks;
  final List<SpotifyArtist> artists;
  final List<SpotifyAlbum> albums;
  final List<SpotifyPlaylist> playlists;

  const SpotifySearchResults({
    this.tracks = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
  });

  factory SpotifySearchResults.fromJson(Map<String, dynamic> json) {
    return SpotifySearchResults(
      tracks: json['tracks']?['items'] != null
          ? (json['tracks']['items'] as List<dynamic>)
              .map((t) => SpotifyTrack.fromJson(t as Map<String, dynamic>))
              .toList()
          : [],
      artists: json['artists']?['items'] != null
          ? (json['artists']['items'] as List<dynamic>)
              .map((a) => SpotifyArtist.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
      albums: json['albums']?['items'] != null
          ? (json['albums']['items'] as List<dynamic>)
              .map((a) => SpotifyAlbum.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
      playlists: json['playlists']?['items'] != null
          ? (json['playlists']['items'] as List<dynamic>)
              .map((p) => SpotifyPlaylist.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'artists': artists.map((a) => a.toJson()).toList(),
      'albums': albums.map((a) => a.toJson()).toList(),
      'playlists': playlists.map((p) => p.toJson()).toList(),
    };
  }

  /// Check if results are empty
  bool get isEmpty =>
      tracks.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty;

  /// Get total number of results
  int get totalCount =>
      tracks.length + artists.length + albums.length + playlists.length;
}
