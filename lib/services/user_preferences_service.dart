import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class UserPreferencesService {
  static const String _favoritesKey = 'favorite_episodes';
  static const String _followsKey = 'followed_podcasts';
  static const String _recentlyPlayedKey = 'recently_played';
  static const String _downloadsKey = 'downloaded_episodes';

  final SharedPreferences _prefs;

  UserPreferencesService(this._prefs);

  // Favorites
  Future<bool> toggleFavorite(String episodeId) async {
    final favorites = await getFavoriteEpisodes();
    if (favorites.contains(episodeId)) {
      favorites.remove(episodeId);
    } else {
      favorites.add(episodeId);
    }
    return await _prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String episodeId) async {
    final favorites = await getFavoriteEpisodes();
    return favorites.contains(episodeId);
  }

  Future<List<String>> getFavoriteEpisodes() async {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  // Follows
  Future<bool> toggleFollow(String podcastId) async {
    final follows = await getFollowedPodcasts();
    if (follows.contains(podcastId)) {
      follows.remove(podcastId);
    } else {
      follows.add(podcastId);
    }
    return await _prefs.setStringList(_followsKey, follows);
  }

  Future<bool> isFollowing(String podcastId) async {
    final follows = await getFollowedPodcasts();
    return follows.contains(podcastId);
  }

  Future<List<String>> getFollowedPodcasts() async {
    return _prefs.getStringList(_followsKey) ?? [];
  }

  // Recently Played
  Future<bool> addToRecentlyPlayed(String episodeId, String podcastId) async {
    final recentlyPlayed = _prefs.getStringList(_recentlyPlayedKey) ?? [];

    // Create entry with both episodeId and podcastId
    final entry = {
      'episodeId': episodeId,
      'podcastId': podcastId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    final entryJson = jsonEncode(entry);

    // Remove if already exists (to move to top)
    recentlyPlayed.removeWhere((item) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return decoded['episodeId'] == episodeId;
      } catch (e) {
        return false;
      }
    });

    // Add to beginning
    recentlyPlayed.insert(0, entryJson);

    // Keep only last 50 items
    if (recentlyPlayed.length > 50) {
      recentlyPlayed.removeRange(50, recentlyPlayed.length);
    }

    return await _prefs.setStringList(_recentlyPlayedKey, recentlyPlayed);
  }

  Future<List<Map<String, String>>> getRecentlyPlayed() async {
    final stringList = _prefs.getStringList(_recentlyPlayedKey) ?? [];
    return stringList
        .map((item) {
          try {
            final decoded = jsonDecode(item) as Map<String, dynamic>;
            return {
              'episodeId': decoded['episodeId'] as String,
              'podcastId': decoded['podcastId'] as String,
              'timestamp': decoded['timestamp'] as String,
            };
          } catch (e) {
            return <String, String>{};
          }
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  // Downloads
  Future<String?> downloadEpisode(
    String episodeId,
    String url,
    String filename,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      // Use Dio to download
      final dio = Dio();
      await dio.download(url, filePath);

      final downloads = await getDownloadedEpisodes();
      if (!downloads.contains(episodeId)) {
        downloads.add(episodeId);
      }

      // Save the file path mapping
      await _prefs.setString('download_path_$episodeId', filePath);
      await _prefs.setStringList(_downloadsKey, downloads);

      return filePath;
    } catch (e) {
      print('Error downloading episode: $e');
      return null;
    }
  }

  Future<bool> removeDownload(String episodeId) async {
    try {
      final filePath = _prefs.getString('download_path_$episodeId');
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final downloads = await getDownloadedEpisodes();
      downloads.remove(episodeId);

      await _prefs.remove('download_path_$episodeId');
      return await _prefs.setStringList(_downloadsKey, downloads);
    } catch (e) {
      print('Error removing download: $e');
      return false;
    }
  }

  Future<String?> getDownloadedEpisodePath(String episodeId) async {
    final filePath = _prefs.getString('download_path_$episodeId');
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
    }
    return null;
  }

  Future<bool> isDownloaded(String episodeId) async {
    final downloads = await getDownloadedEpisodes();
    if (!downloads.contains(episodeId)) return false;

    // Verify file actually exists
    final path = await getDownloadedEpisodePath(episodeId);
    if (path == null) {
      // Clean up if file is missing
      await removeDownload(episodeId);
      return false;
    }
    return true;
  }

  Future<List<String>> getDownloadedEpisodes() async {
    return _prefs.getStringList(_downloadsKey) ?? [];
  }

  // Clear all data
  Future<bool> clearAll() async {
    // Clear downloads first
    final downloads = await getDownloadedEpisodes();
    for (final id in downloads) {
      await removeDownload(id);
    }

    await _prefs.remove(_favoritesKey);
    await _prefs.remove(_followsKey);
    await _prefs.remove(_recentlyPlayedKey);
    await _prefs.remove(_downloadsKey);
    return true;
  }
}
