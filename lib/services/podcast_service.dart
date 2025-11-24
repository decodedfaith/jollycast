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
    try {
      final response = await _dio.get('/api/podcasts/top-jolly');

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

        return [];
      } else if (response.statusCode == 401) {
        throw Exception('401 User not authenticated');
      } else {
        throw Exception('Failed to fetch podcasts: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch podcasts: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
