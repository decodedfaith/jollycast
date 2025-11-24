import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/episode_model.dart';
import '../services/episode_service.dart';

import '../services/cache_service.dart';

final episodeRepositoryProvider = Provider<EpisodeRepository>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return EpisodeRepository(ref, cacheService);
});

class EpisodeRepository {
  final Ref _ref;
  final CacheService _cacheService;

  EpisodeRepository(this._ref, this._cacheService);

  Future<List<Episode>> getEpisodes(String podcastId) async {
    final episodeService = _ref.read(episodeServiceProvider);
    try {
      // Try to fetch fresh data
      final episodes = await episodeService.fetchEpisodes(podcastId);
      // Save to cache
      if (episodes.isNotEmpty) {
        await _cacheService.saveEpisodes(podcastId, episodes);
      }
      return episodes;
    } catch (e) {
      print('EpisodeRepository: Error fetching episodes: $e');
      // Fallback to cache
      final cachedEpisodes = await _cacheService.getEpisodes(podcastId);
      if (cachedEpisodes.isNotEmpty) {
        print('EpisodeRepository: Returning cached episodes');
        return cachedEpisodes;
      }
      rethrow;
    }
  }
}
