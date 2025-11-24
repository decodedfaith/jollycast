import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/podcast_model.dart';
import 'episode_list_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<Podcast> podcasts;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.podcasts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003334),
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: const Color(0xFF003334),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: podcasts.length,
        itemBuilder: (context, index) {
          final podcast = podcasts[index];
          return Card(
            color: Colors.white.withAlpha(13),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EpisodeListScreen(podcast: podcast),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: podcast.thumbnail,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.image, color: Colors.white54),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            podcast.author,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
