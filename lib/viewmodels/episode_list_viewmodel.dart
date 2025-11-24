import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/episode_repository.dart';
import '../models/episode_model.dart';

final episodeListViewModelProvider = AsyncNotifierProvider.family(
  (String arg) => EpisodeListViewModel(arg),
);

class EpisodeListViewModel extends AsyncNotifier<List<Episode>> {
  final String podcastId;

  EpisodeListViewModel(this.podcastId);

  @override
  FutureOr<List<Episode>> build() async {
    final repository = ref.read(episodeRepositoryProvider);
    return repository.getEpisodes(podcastId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(episodeRepositoryProvider);
      return repository.getEpisodes(podcastId);
    });
  }
}
