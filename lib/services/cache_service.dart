import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/podcast_model.dart';
import '../models/episode_model.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

class CacheService {
  static const String _podcastsKey = 'cached_podcasts';
  static const String _episodesKeyPrefix = 'cached_episodes_';

  Future<void> savePodcasts(List<Podcast> podcasts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = podcasts.map((p) => p.toJson()).toList();
      await prefs.setString(_podcastsKey, jsonEncode(jsonList));
    } catch (e) {
      print('CacheService: Error saving podcasts: $e');
    }
  }

  Future<List<Podcast>> getPodcasts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_podcastsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => Podcast.fromJson(json)).toList();
      }
    } catch (e) {
      print('CacheService: Error getting podcasts from cache: $e');
    }
    return [];
  }

  Future<void> saveEpisodes(String podcastId, List<Episode> episodes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = episodes.map((e) => e.toJson()).toList();
      await prefs.setString(
        '$_episodesKeyPrefix$podcastId',
        jsonEncode(jsonList),
      );
    } catch (e) {
      print('CacheService: Error saving episodes: $e');
    }
  }

  Future<List<Episode>> getEpisodes(String podcastId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_episodesKeyPrefix$podcastId');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => Episode.fromJson(json)).toList();
      }
    } catch (e) {
      print('CacheService: Error getting episodes from cache: $e');
    }
    return [];
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key == _podcastsKey || key.startsWith(_episodesKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
