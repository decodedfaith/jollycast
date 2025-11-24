import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/podcast_model.dart';
import 'dio_provider.dart';

final podcastServiceProvider = Provider<PodcastService>((ref) {
  final dio = ref.watch(dioProvider);
  return PodcastService(dio);
});

class PodcastService {
  final Dio _dio;

  PodcastService(this._dio);

  Future<List<Podcast>> fetchPodcasts() async {
    print('PodcastService: Fetching podcasts');

    try {
      final response = await _dio.get('/api/podcasts/top-jolly');

      print('PodcastService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic rootData = response.data;

        if (rootData is Map && rootData.containsKey('data')) {
          final dynamic level1 = rootData['data'];
          if (level1 is Map && level1.containsKey('data')) {
            final dynamic level2 = level1['data'];
            if (level2 is Map && level2.containsKey('data')) {
              final dynamic list = level2['data'];
              if (list is List) {
                return list.map((json) => Podcast.fromJson(json)).toList();
              }
            }
          }
        }

        print(
          'PodcastService: Could not find podcast list in response: $rootData',
        );
        return [];
      } else if (response.statusCode == 401) {
        print('PodcastService: Unauthorized (401). Token might be invalid.');
        throw Exception('401 User not authenticated');
      } else {
        print(
          'PodcastService: Failed with status ${response.statusCode}: ${response.statusMessage}',
        );
        throw Exception('Failed to fetch podcasts: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('PodcastService: DioException: ${e.message}');
      print('PodcastService: DioException response: ${e.response}');
      print('PodcastService: DioException request: ${e.requestOptions.uri}');
      throw Exception('Failed to fetch podcasts: ${e.message}');
    } catch (e) {
      print('PodcastService: Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
