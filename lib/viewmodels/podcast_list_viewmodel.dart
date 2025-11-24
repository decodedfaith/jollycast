import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/podcast_repository.dart';
import '../models/podcast_model.dart';

final podcastListViewModelProvider =
    AsyncNotifierProvider<PodcastListViewModel, List<Podcast>>(() {
      return PodcastListViewModel();
    });

class PodcastListViewModel extends AsyncNotifier<List<Podcast>> {
  late PodcastRepository _podcastRepository;

  @override
  FutureOr<List<Podcast>> build() async {
    _podcastRepository = ref.read(podcastRepositoryProvider);
    return _fetchPodcasts();
  }

  Future<List<Podcast>> _fetchPodcasts() async {
    return await _podcastRepository.getPodcasts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _fetchPodcasts();
    });
  }
}
