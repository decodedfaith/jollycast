import 'package:flutter_test/flutter_test.dart';
import 'package:jollycast/services/user_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UserPreferencesService Unit Tests', () {
    late UserPreferencesService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = UserPreferencesService(prefs);
    });

    test('toggleFavorite adds episode ID to favorites', () async {
      await service.toggleFavorite('123');
      final favorites = await service.getFavoriteEpisodes();

      expect(favorites.contains('123'), true);
    });

    test('toggleFavorite removes episode ID if already favorited', () async {
      await service.toggleFavorite('123');
      await service.toggleFavorite('123');
      final favorites = await service.getFavoriteEpisodes();

      expect(favorites.contains('123'), false);
    });

    test('toggleFollow adds podcast ID to follows', () async {
      await service.toggleFollow('456');
      final follows = await service.getFollowedPodcasts();

      expect(follows.contains('456'), true);
    });

    test('addToRecentlyPlayed stores episode and podcast IDs', () async {
      await service.addToRecentlyPlayed('789', '101');
      final recent = await service.getRecentlyPlayed();

      expect(recent.isNotEmpty, true);
      expect(recent.first['episodeId'], '789');
      expect(recent.first['podcastId'], '101');
    });

    test('getRecentlyPlayed returns chronological order', () async {
      await service.addToRecentlyPlayed('1', '10');
      await Future.delayed(const Duration(milliseconds: 100));
      await service.addToRecentlyPlayed('2', '20');
      await Future.delayed(const Duration(milliseconds: 100));
      await service.addToRecentlyPlayed('3', '30');

      final recent = await service.getRecentlyPlayed();

      expect(recent.first['episodeId'], '3');
      expect(recent.last['episodeId'], '1');
    });

    test('clearAll removes all preferences', () async {
      await service.toggleFavorite('1');
      await service.toggleFollow('2');
      await service.clearAll();

      final favorites = await service.getFavoriteEpisodes();
      final follows = await service.getFollowedPodcasts();

      expect(favorites.length, 0);
      expect(follows.length, 0);
    });

    test('isFavorite returns correct status', () async {
      await service.toggleFavorite('123');

      expect(await service.isFavorite('123'), true);
      expect(await service.isFavorite('456'), false);
    });

    test('isFollowing returns correct status', () async {
      await service.toggleFollow('789');

      expect(await service.isFollowing('789'), true);
      expect(await service.isFollowing('101'), false);
    });

    test('markForDownload adds episode to downloads', () async {
      await service.markForDownload('999');
      final downloads = await service.getDownloadedEpisodes();

      expect(downloads.contains('999'), true);
    });
  });
}
