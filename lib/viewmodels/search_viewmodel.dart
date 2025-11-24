import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/search_service.dart';
import '../models/podcast_model.dart';
import '../models/episode_model.dart';
import 'podcast_list_viewmodel.dart';
import 'user_preferences_viewmodel.dart';

// Provider for SearchService
final searchServiceProvider = Provider<SearchService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return SearchService(prefs);
});

// Search state
class SearchState {
  final String query;
  final List<Podcast> podcastResults;
  final List<Episode> episodeResults;
  final List<String> searchHistory;
  final bool isLoading;
  final String? error;

  SearchState({
    this.query = '',
    this.podcastResults = const [],
    this.episodeResults = const [],
    this.searchHistory = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Podcast>? podcastResults,
    List<Episode>? episodeResults,
    List<String>? searchHistory,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      podcastResults: podcastResults ?? this.podcastResults,
      episodeResults: episodeResults ?? this.episodeResults,
      searchHistory: searchHistory ?? this.searchHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Search ViewModel
class SearchViewModel extends Notifier<SearchState> {
  late final SearchService _searchService;
  Timer? _debounce;

  @override
  SearchState build() {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    if (prefs == null) {
      return SearchState();
    }
    _searchService = SearchService(prefs);
    _loadSearchHistory();
    return SearchState();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchService.getSearchHistory();
    state = state.copyWith(searchHistory: history);
  }

  void search(
    String query,
    List<Podcast> allPodcasts, [
    List<Episode>? allEpisodes,
  ]) {
    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Update query immediately
    state = state.copyWith(query: query, isLoading: true);

    // Debounce the actual search
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query, allPodcasts, allEpisodes);
    });
  }

  void _performSearch(
    String query,
    List<Podcast> allPodcasts, [
    List<Episode>? allEpisodes,
  ]) {
    try {
      final podcastResults = _searchService.searchPodcasts(allPodcasts, query);
      final episodeResults = allEpisodes != null
          ? _searchService.searchEpisodes(allEpisodes, query)
          : <Episode>[];

      state = state.copyWith(
        podcastResults: podcastResults,
        episodeResults: episodeResults,
        isLoading: false,
        error: null,
      );

      // Add to search history if query is not empty
      if (query.trim().isNotEmpty) {
        _searchService.addToSearchHistory(query);
        _loadSearchHistory();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clearHistory() async {
    await _searchService.clearSearchHistory();
    await _loadSearchHistory();
  }

  Future<void> removeFromHistory(String query) async {
    await _searchService.removeFromSearchHistory(query);
    await _loadSearchHistory();
  }

  void clearSearch() {
    state = SearchState();
    _loadSearchHistory();
  }
}

// Provider for SearchViewModel
final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(
  () {
    return SearchViewModel();
  },
);

// Category state and provider
class CategoryState {
  final String? selectedCategory;
  final Map<String, List<Podcast>> categorizedPodcasts;
  final List<String> availableCategories;

  CategoryState({
    this.selectedCategory,
    this.categorizedPodcasts = const {},
    this.availableCategories = const [],
  });

  CategoryState copyWith({
    String? selectedCategory,
    Map<String, List<Podcast>>? categorizedPodcasts,
    List<String>? availableCategories,
  }) {
    return CategoryState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categorizedPodcasts: categorizedPodcasts ?? this.categorizedPodcasts,
      availableCategories: availableCategories ?? this.availableCategories,
    );
  }
}

class CategoryViewModel extends Notifier<CategoryState> {
  late final SearchService _searchService;

  @override
  CategoryState build() {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    if (prefs == null) {
      return CategoryState();
    }
    _searchService = SearchService(prefs);

    // Listen to podcasts and categorize them
    ref.listen(podcastListViewModelProvider, (previous, next) {
      next.whenData((podcasts) {
        _categorizePodcasts(podcasts);
      });
    });

    return CategoryState();
  }

  void _categorizePodcasts(List<Podcast> podcasts) {
    final grouped = _searchService.groupByCategory(podcasts);
    final categories = grouped.keys.toList()..sort();

    state = state.copyWith(
      categorizedPodcasts: grouped,
      availableCategories: categories,
    );
  }

  void selectCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  List<Podcast> getFilteredPodcasts([String? searchQuery]) {
    List<Podcast> podcasts = [];

    if (state.selectedCategory != null) {
      podcasts = state.categorizedPodcasts[state.selectedCategory] ?? [];
    } else {
      // All podcasts
      state.categorizedPodcasts.values.forEach((list) {
        podcasts.addAll(list);
      });
    }

    // Apply search filter if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      podcasts = _searchService.searchPodcasts(podcasts, searchQuery);
    }

    return podcasts;
  }

  int getCategoryCount(String category) {
    return state.categorizedPodcasts[category]?.length ?? 0;
  }
}

final categoryViewModelProvider =
    NotifierProvider<CategoryViewModel, CategoryState>(() {
      return CategoryViewModel();
    });
