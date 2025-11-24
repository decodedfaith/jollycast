import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/episode_model.dart';
import 'dio_provider.dart';

final episodeServiceProvider = Provider<EpisodeService>((ref) {
  final dio = ref.watch(dioProvider);
  return EpisodeService(dio);
});

class EpisodeService {
  final Dio _dio;

  EpisodeService(this._dio);

  Future<List<Episode>> fetchEpisodes(String podcastId) async {
    // Try multiple possible endpoint patterns
    final endpoints = [
      '/api/podcasts/$podcastId/episodes',
      '/api/episodes?podcast_id=$podcastId',
      '/api/podcasts/$podcastId', // Might return podcast with episodes
    ];

    print('EpisodeService: Fetching episodes for podcast $podcastId');

    for (var url in endpoints) {
      try {
        print('EpisodeService: Trying endpoint: $url');

        final response = await _dio.get(url);

        print('EpisodeService: Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          return _parseEpisodesFromResponse(response.data, podcastId);
        }
      } on DioException catch (e) {
        print('EpisodeService: Endpoint $url failed: ${e.message}');
        if (e.response?.statusCode == 404) {
          continue; // Try next endpoint
        }
        // For other errors, continue trying
        continue;
      } catch (e) {
        print('EpisodeService: Unexpected error with $url: $e');
        continue;
      }
    }

    print('EpisodeService: All endpoints failed, returning empty list');
    return [];
  }

  List<Episode> _parseEpisodesFromResponse(dynamic data, String podcastId) {
    try {
      // Handle different response structures
      dynamic episodesList;

      if (data is Map) {
        // Try to find episodes in nested structure
        // Structure seen in logs: { data: { data: { data: [ ... ] } } }

        // Level 1
        if (data.containsKey('data')) {
          final level1 = data['data'];
          if (level1 is List) {
            episodesList = level1;
          } else if (level1 is Map) {
            // Level 2
            if (level1.containsKey('data')) {
              final level2 = level1['data'];
              if (level2 is List) {
                episodesList = level2;
              } else if (level2 is Map) {
                // Level 3
                if (level2.containsKey('data')) {
                  final level3 = level2['data'];
                  if (level3 is List) {
                    episodesList = level3;
                  }
                }
              }
            } else if (level1.containsKey('episodes')) {
              episodesList = level1['episodes'];
            }
          }
        } else if (data.containsKey('episodes')) {
          episodesList = data['episodes'];
        } else if (data.containsKey('items')) {
          episodesList = data['items'];
        }
      } else if (data is List) {
        episodesList = data;
      }

      if (episodesList is List) {
        print('EpisodeService: Found ${episodesList.length} episodes');
        return episodesList
            .map((json) {
              if (json is Map<String, dynamic>) {
                // Ensure podcast_id is set
                if (!json.containsKey('podcast_id') &&
                    !json.containsKey('show_id')) {
                  json['podcast_id'] = podcastId;
                }
                return Episode.fromJson(json);
              }
              return null;
            })
            .whereType<Episode>()
            .toList();
      }

      print('EpisodeService: Could not parse episodes from response');
      return [];
    } catch (e) {
      print('EpisodeService: Error parsing episodes: $e');
      return [];
    }
  }
}
