import 'package:flutter_test/flutter_test.dart';
import 'package:jollycast/services/search_service.dart';
import 'package:jollycast/models/podcast_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SearchService Unit Tests', () {
    late SearchService searchService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      searchService = SearchService(prefs);
    });

    test('searchPodcasts returns correct results for title match', () {
      final podcasts = [
        Podcast(
          id: '1',
          title: 'Tech Talk',
          description: 'A tech podcast',
          thumbnail: 'https://example.com/1.jpg',
          audioUrl: 'https://example.com/1.mp3',
          author: 'John Doe',
        ),
        Podcast(
          id: '2',
          title: 'Business News',
          description: 'Business updates',
          thumbnail: 'https://example.com/2.jpg',
          audioUrl: 'https://example.com/2.mp3',
          author: 'Jane Smith',
        ),
      ];

      final results = searchService.searchPodcasts(podcasts, 'tech');

      expect(results.length, 1);
      expect(results.first.title, 'Tech Talk');
    });

    test('searchPodcasts returns empty list for no match', () {
      final podcasts = [
        Podcast(
          id: '1',
          title: 'Tech Talk',
          description: 'A tech podcast',
          thumbnail: 'https://example.com/1.jpg',
          audioUrl: 'https://example.com/1.mp3',
          author: 'John Doe',
        ),
      ];

      final results = searchService.searchPodcasts(podcasts, 'sports');

      expect(results.length, 0);
    });

    test('searchPodcasts is case insensitive', () {
      final podcasts = [
        Podcast(
          id: '1',
          title: 'Tech Talk',
          description: 'A tech podcast',
          thumbnail: 'https://example.com/1.jpg',
          audioUrl: 'https://example.com/1.mp3',
          author: 'John Doe',
        ),
      ];

      final results = searchService.searchPodcasts(podcasts, 'TECH');

      expect(results.length, 1);
    });

    test('addToSearchHistory stores search query', () async {
      await searchService.addToSearchHistory('flutter');
      final history = await searchService.getSearchHistory();

      expect(history.contains('flutter'), true);
    });

    test('addToSearchHistory limits to 10 items', () async {
      for (int i = 0; i < 15; i++) {
        await searchService.addToSearchHistory('query$i');
      }

      final history = await searchService.getSearchHistory();

      expect(history.length, 10);
    });

    test('clearSearchHistory removes all items', () async {
      await searchService.addToSearchHistory('query1');
      await searchService.addToSearchHistory('query2');
      await searchService.clearSearchHistory();

      final history = await searchService.getSearchHistory();

      expect(history.length, 0);
    });

    test('inferCategory returns correct category for tech podcast', () {
      final podcast = Podcast(
        id: '1',
        title: 'Flutter Development',
        description: 'Learn coding and programming',
        thumbnail: 'https://example.com/1.jpg',
        audioUrl: 'https://example.com/1.mp3',
        author: 'Developer',
      );

      final category = searchService.inferCategory(podcast);

      expect(category, 'Technology');
    });

    test('groupByCategory groups podcasts correctly', () {
      final podcasts = [
        Podcast(
          id: '1',
          title: 'Tech Talk',
          description: 'Learn programming',
          thumbnail: 'https://example.com/1.jpg',
          audioUrl: 'https://example.com/1.mp3',
          author: 'Dev',
        ),
        Podcast(
          id: '2',
          title: 'Business Hour',
          description: 'Entrepreneur stories',
          thumbnail: 'https://example.com/2.jpg',
          audioUrl: 'https://example.com/2.mp3',
          author: 'CEO',
        ),
        Podcast(
          id: '3',
          title: 'Coding Best Practices',
          description: 'Software development tips',
          thumbnail: 'https://example.com/3.jpg',
          audioUrl: 'https://example.com/3.mp3',
          author: 'Engineer',
        ),
      ];

      final grouped = searchService.groupByCategory(podcasts);

      expect(grouped['Technology']?.length, 2);
      expect(grouped['Business']?.length, 1);
    });
  });
}
