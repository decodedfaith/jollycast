import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/player_viewmodel.dart';
import '../viewmodels/user_preferences_viewmodel.dart';
import '../models/podcast_model.dart';
import '../models/episode_model.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Episode episode;
  final Podcast podcast;
  final List<Episode> allEpisodes;
  final int currentIndex;

  const PlayerScreen({
    super.key,
    required this.episode,
    required this.podcast,
    required this.allEpisodes,
    required this.currentIndex,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(playerViewModelProvider.notifier)
          .playPlaylist(widget.allEpisodes, widget.currentIndex);
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _playNext() {
    ref.read(playerViewModelProvider.notifier).playNext();
  }

  void _playPrevious() {
    ref.read(playerViewModelProvider.notifier).playPrevious();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    final userPrefs = ref.watch(userPreferencesViewModelProvider);

    final currentEpisode = playerState.currentEpisode ?? widget.episode;
    final currentIndex = playerState.currentIndex;
    final isFavorite = userPrefs.favoriteEpisodeIds.contains(currentEpisode.id);

    final totalDuration = playerState.duration.inSeconds > 0
        ? playerState.duration
        : currentEpisode.duration;

    // Trigger scale animation based on play state
    if (playerState.isPlaying && !_scaleController.isAnimating) {
      _scaleController.forward().then((_) => _scaleController.reverse());
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA3CB43), // Lime green
              Color(0xFF00A86B), // Darker green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with close button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          // Show options menu
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Artwork with animation
              Expanded(
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Hero(
                      tag: 'podcast_${widget.podcast.id}',
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(102),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: currentEpisode.thumbnail.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: currentEpisode.thumbnail,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.white.withAlpha(51),
                                    child: const Icon(
                                      Icons.podcasts,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.white.withAlpha(51),
                                        child: const Icon(
                                          Icons.podcasts,
                                          size: 100,
                                          color: Colors.white,
                                        ),
                                      ),
                                )
                              : Container(
                                  color: Colors.white.withAlpha(51),
                                  child: const Icon(
                                    Icons.podcasts,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Episode info and controls
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Episode title
                    Text(
                      currentEpisode.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Episode description
                    Text(
                      currentEpisode.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(230),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),

                    // Progress bar
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withAlpha(76),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withAlpha(51),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: playerState.position.inSeconds
                                .toDouble()
                                .clamp(0.0, totalDuration.inSeconds.toDouble()),
                            max: totalDuration.inSeconds > 0
                                ? totalDuration.inSeconds.toDouble()
                                : 1.0,
                            onChanged: (value) {
                              ref
                                  .read(playerViewModelProvider.notifier)
                                  .seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(playerState.position),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDuration(totalDuration),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Previous
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                          ),
                          onPressed: currentIndex > 0 ? _playPrevious : null,
                        ),

                        // -15s
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            ref
                                .read(playerViewModelProvider.notifier)
                                .skipBackward(seconds: 15);
                          },
                        ),

                        // Play/Pause
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: playerState.isBuffering
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00A86B),
                                    strokeWidth: 3,
                                  ),
                                )
                              : IconButton(
                                  iconSize: 32,
                                  icon: Icon(
                                    playerState.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: const Color(0xFF00A86B),
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(playerViewModelProvider.notifier)
                                        .togglePlayPause();
                                  },
                                ),
                        ),

                        // +15s
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            ref
                                .read(playerViewModelProvider.notifier)
                                .skipForward(seconds: 15);
                          },
                        ),

                        // Next
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                          ),
                          onPressed:
                              currentIndex < widget.allEpisodes.length - 1
                              ? _playNext
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.playlist_add,
                          label: 'Add to queue',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to queue'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: 'Save',
                          onTap: () async {
                            await ref
                                .read(userPreferencesViewModelProvider.notifier)
                                .toggleFavorite(currentEpisode.id);
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.share,
                          label: 'Share episode',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Share: ${currentEpisode.title}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bottom buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOutlinedButton(
                          icon: Icons.playlist_play,
                          label: 'Add to playlist',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _buildOutlinedButton(
                          icon: Icons.arrow_forward,
                          label: 'Go to episode page',
                          onTap: () {
                            Navigator.of(context).pop();
                          },
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
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(76)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
