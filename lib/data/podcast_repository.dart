import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/podcast_model.dart';
import '../services/podcast_service.dart';

import '../services/cache_service.dart';

final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  final podcastService = ref.watch(podcastServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return PodcastRepository(podcastService, cacheService);
});

class PodcastRepository {
  final PodcastService _podcastService;
  final CacheService _cacheService;

  PodcastRepository(this._podcastService, this._cacheService);

  Future<List<Podcast>> getPodcasts() async {
    try {
      // Try to fetch fresh data
      final podcasts = await _podcastService.fetchPodcasts();
      // Save to cache
      if (podcasts.isNotEmpty) {
        await _cacheService.savePodcasts(podcasts);
      }
      return podcasts;
    } catch (e) {
      print('PodcastRepository: Error fetching podcasts: $e');
      // Fallback to cache
      final cachedPodcasts = await _cacheService.getPodcasts();
      if (cachedPodcasts.isNotEmpty) {
        print('PodcastRepository: Returning cached podcasts');
        return cachedPodcasts;
      }
      rethrow;
    }
  }
}
