import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/podcast_model.dart';
import '../core/utils/error_handler.dart';
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
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to load podcasts. Please try again.');
      }
    } on DioException catch (e) {
      final error = ErrorHandler.handleError(e);
      throw Exception(error.message);
    } catch (e) {
      final error = ErrorHandler.handleError(e);
      throw Exception(error.message);
    }
  }
}
