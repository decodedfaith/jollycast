import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/episode_model.dart';
import '../models/podcast_model.dart';
import '../viewmodels/player_viewmodel.dart';
import '../views/player_screen.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  final Episode episode;
  final Podcast podcast;
  final List<Episode> allEpisodes;
  final int currentIndex;
  final VoidCallback onClose;

  const MiniPlayer({
    super.key,
    required this.episode,
    required this.podcast,
    required this.allEpisodes,
    required this.currentIndex,
    required this.onClose,
  });

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Offset _position = const Offset(20, 500);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            const bottomNavHeight = 80.0; // Bottom nav + padding
            const miniPlayerHeight = 100.0;
            const miniPlayerWidth = 320.0;

            _position = Offset(
              (_position.dx + details.delta.dx).clamp(
                0,
                screenWidth - miniPlayerWidth,
              ),
              (_position.dy + details.delta.dy).clamp(
                0,
                screenHeight - bottomNavHeight - miniPlayerHeight,
              ),
            );
          });
        },
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlayerScreen(
                episode: widget.episode,
                podcast: widget.podcast,
                allEpisodes: widget.allEpisodes,
                currentIndex: widget.currentIndex,
              ),
            ),
          );
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 320,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00A86B), Color(0xFF003334)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Close button
                Positioned(
                  right: 4,
                  top: 4,
                  child: GestureDetector(
                    onTap: () {
                      widget.onClose();
                      ref
                          .read(playerViewModelProvider.notifier)
                          .togglePlayPause();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.episode.thumbnail,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[800]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Episode info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.episode.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.podcast.title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Controls
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(playerViewModelProvider.notifier)
                                  .playPrevious();
                            },
                            child: const Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTapDown: (_) => _animationController.forward(),
                            onTapUp: (_) => _animationController.reverse(),
                            onTapCancel: () => _animationController.reverse(),
                            onTap: () {
                              ref
                                  .read(playerViewModelProvider.notifier)
                                  .togglePlayPause();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                playerState.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: const Color(0xFF00A86B),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(playerViewModelProvider.notifier)
                                  .playNext();
                            },
                            child: const Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
