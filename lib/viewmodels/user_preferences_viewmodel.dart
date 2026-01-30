import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_preferences_service.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// Provider for UserPreferencesService
final userPreferencesServiceProvider = Provider<UserPreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return UserPreferencesService(prefs);
});

// State class for user preferences
class UserPreferencesState {
  final Set<String> favoriteEpisodeIds;
  final Set<String> followedPodcastIds;
  final List<Map<String, String>> recentlyPlayed;
  final Set<String> downloadedEpisodeIds;

  UserPreferencesState({
    this.favoriteEpisodeIds = const {},
    this.followedPodcastIds = const {},
    this.recentlyPlayed = const [],
    this.downloadedEpisodeIds = const {},
  });

  UserPreferencesState copyWith({
    Set<String>? favoriteEpisodeIds,
    Set<String>? followedPodcastIds,
    List<Map<String, String>>? recentlyPlayed,
    Set<String>? downloadedEpisodeIds,
  }) {
    return UserPreferencesState(
      favoriteEpisodeIds: favoriteEpisodeIds ?? this.favoriteEpisodeIds,
      followedPodcastIds: followedPodcastIds ?? this.followedPodcastIds,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      downloadedEpisodeIds: downloadedEpisodeIds ?? this.downloadedEpisodeIds,
    );
  }
}

// ViewModel for user preferences
class UserPreferencesViewModel extends Notifier<UserPreferencesState> {
  late final UserPreferencesService _service;

  @override
  UserPreferencesState build() {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    if (prefs == null) {
      return UserPreferencesState();
    }
    _service = UserPreferencesService(prefs);
    _loadPreferences();
    return UserPreferencesState();
  }

  Future<void> _loadPreferences() async {
    final favorites = await _service.getFavoriteEpisodes();
    final follows = await _service.getFollowedPodcasts();
    final recents = await _service.getRecentlyPlayed();
    final downloads = await _service.getDownloadedEpisodes();

    state = state.copyWith(
      favoriteEpisodeIds: favorites.toSet(),
      followedPodcastIds: follows.toSet(),
      recentlyPlayed: recents,
      downloadedEpisodeIds: downloads.toSet(),
    );
  }

  Future<void> toggleFavorite(String episodeId) async {
    await _service.toggleFavorite(episodeId);
    await _loadPreferences();
  }

  bool isFavorite(String episodeId) {
    return state.favoriteEpisodeIds.contains(episodeId);
  }

  Future<void> toggleFollow(String podcastId) async {
    await _service.toggleFollow(podcastId);
    await _loadPreferences();
  }

  bool isFollowing(String podcastId) {
    return state.followedPodcastIds.contains(podcastId);
  }

  Future<void> addToRecentlyPlayed(String episodeId, String podcastId) async {
    await _service.addToRecentlyPlayed(episodeId, podcastId);
    await _loadPreferences();
  }

  Future<void> downloadEpisode(
    String episodeId,
    String url,
    String filename,
  ) async {
    await _service.downloadEpisode(episodeId, url, filename);
    await _loadPreferences();
  }

  Future<void> removeDownload(String episodeId) async {
    await _service.removeDownload(episodeId);
    await _loadPreferences();
  }

  bool isDownloaded(String episodeId) {
    return state.downloadedEpisodeIds.contains(episodeId);
  }
}

// Provider for UserPreferencesViewModel
final userPreferencesViewModelProvider =
    NotifierProvider<UserPreferencesViewModel, UserPreferencesState>(() {
      return UserPreferencesViewModel();
    });
