import 'package:shared_preferences/shared_preferences.dart';
import '../models/podcast_model.dart';
import '../models/episode_model.dart';

class SearchService {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  final SharedPreferences _prefs;

  SearchService(this._prefs);

  // Search podcasts by query
  List<Podcast> searchPodcasts(List<Podcast> podcasts, String query) {
    if (query.isEmpty) return podcasts;

    final lowerQuery = query.toLowerCase();
    return podcasts.where((podcast) {
      return podcast.title.toLowerCase().contains(lowerQuery) ||
          podcast.description.toLowerCase().contains(lowerQuery) ||
          podcast.author.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Search episodes by query
  List<Episode> searchEpisodes(List<Episode> episodes, String query) {
    if (query.isEmpty) return episodes;

    final lowerQuery = query.toLowerCase();
    return episodes.where((episode) {
      return episode.title.toLowerCase().contains(lowerQuery) ||
          episode.description.toLowerCase().contains(lowerQuery) ||
          (episode.author?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Filter podcasts by category
  List<Podcast> filterByCategory(List<Podcast> podcasts, String category) {
    if (category.isEmpty) return podcasts;

    final lowerCategory = category.toLowerCase();
    return podcasts.where((podcast) {
      // Match category keywords in title or description
      final content = '${podcast.title} ${podcast.description}'.toLowerCase();
      return content.contains(lowerCategory);
    }).toList();
  }

  // Search history management
  Future<bool> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return false;

    final history = await getSearchHistory();

    // Remove if already exists
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Keep only last N items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    return await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<List<String>> getSearchHistory() async {
    return _prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<bool> clearSearchHistory() async {
    return await _prefs.remove(_searchHistoryKey);
  }

  Future<bool> removeFromSearchHistory(String query) async {
    final history = await getSearchHistory();
    history.remove(query);
    return await _prefs.setStringList(_searchHistoryKey, history);
  }

  // Get search suggestions based on history and current query
  Future<List<String>> getSearchSuggestions(String query) async {
    final history = await getSearchHistory();

    if (query.isEmpty) return history;

    final lowerQuery = query.toLowerCase();
    return history
        .where((item) => item.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Predefined categories
  List<Map<String, dynamic>> getPredefinedCategories() {
    return [
      {
        'name': 'Arts',
        'keywords': ['art', 'arts', 'design', 'fashion'],
      },
      {
        'name': 'Business',
        'keywords': [
          'business',
          'entrepreneur',
          'startup',
          'finance',
          'investing',
        ],
      },
      {
        'name': 'Comedy',
        'keywords': ['comedy', 'humor', 'funny', 'jokes'],
      },
      {
        'name': 'Education',
        'keywords': ['education', 'learning', 'teach', 'school', 'university'],
      },
      {
        'name': 'Health & Fitness',
        'keywords': ['health', 'fitness', 'wellness', 'nutrition', 'workout'],
      },
      {
        'name': 'Music',
        'keywords': ['music', 'song', 'album', 'artist', 'playlist'],
      },
      {
        'name': 'News',
        'keywords': ['news', 'current', 'politics', 'world'],
      },
      {
        'name': 'Technology',
        'keywords': ['tech', 'technology', 'coding', 'software', 'programming'],
      },
      {
        'name': 'Sports',
        'keywords': ['sport', 'sports', 'football', 'basketball', 'soccer'],
      },
      {
        'name': 'True Crime',
        'keywords': ['crime', 'murder', 'detective', 'investigation'],
      },
      {
        'name': 'History',
        'keywords': ['history', 'historical', 'ancient', 'war'],
      },
      {
        'name': 'Science',
        'keywords': ['science', 'research', 'biology', 'physics', 'chemistry'],
      },
    ];
  }

  // Get category for a podcast based on keywords
  String? inferCategory(Podcast podcast) {
    final content = '${podcast.title} ${podcast.description}'.toLowerCase();
    final categories = getPredefinedCategories();

    for (final category in categories) {
      final keywords = category['keywords'] as List<String>;
      for (final keyword in keywords) {
        if (content.contains(keyword.toLowerCase())) {
          return category['name'] as String;
        }
      }
    }

    return null;
  }

  // Group podcasts by category
  Map<String, List<Podcast>> groupByCategory(List<Podcast> podcasts) {
    final Map<String, List<Podcast>> grouped = {};
    final categories = getPredefinedCategories();

    // Initialize categories
    for (final category in categories) {
      grouped[category['name'] as String] = [];
    }
    grouped['Other'] = [];

    // Categorize podcasts
    for (final podcast in podcasts) {
      final category = inferCategory(podcast);
      if (category != null && grouped.containsKey(category)) {
        grouped[category]!.add(podcast);
      } else {
        grouped['Other']!.add(podcast);
      }
    }

    // Remove empty categories
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }
}
