import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/player_viewmodel.dart';
import 'media_cache_service.dart';

final predictiveServiceProvider = Provider<PredictiveService>((ref) {
  return PredictiveService(ref);
});

class PredictiveService {
  final Ref _ref;

  PredictiveService(this._ref) {
    _init();
  }

  void _init() {
    // Watch Player State for Next Episode Prediction
    _ref.listen<PlayerState>(playerViewModelProvider, (previous, next) {
      if (next.currentEpisode != null && next.queue.isNotEmpty) {
        _prefetchNextEpisode(next);
      }
    });
  }

  Future<void> _prefetchNextEpisode(PlayerState state) async {
    final currentIndex = state.currentIndex;
    final queue = state.queue;

    // Check if there is a next episode
    if (currentIndex + 1 < queue.length) {
      final nextEpisode = queue[currentIndex + 1];
      final url = nextEpisode.audioUrl;

      if (url.isNotEmpty) {
        // Trigger background download
        await _ref.read(mediaCacheServiceProvider).prefetch(url);
      }
    }
  }

  // Future expansion: Prefetch top podcast episodes
  Future<void> prefetchTopPodcasts() async {
    // Logic to fetch top podcasts and then their first episode audio
  }
}
