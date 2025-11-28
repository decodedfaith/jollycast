import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/podcast_model.dart';
import '../models/episode_model.dart';
import '../viewmodels/episode_list_viewmodel.dart';
import '../viewmodels/user_preferences_viewmodel.dart';
import 'player_screen.dart';

class EpisodeListScreen extends ConsumerStatefulWidget {
  final Podcast podcast;

  const EpisodeListScreen({super.key, required this.podcast});

  @override
  ConsumerState<EpisodeListScreen> createState() => _EpisodeListScreenState();
}

class _EpisodeListScreenState extends ConsumerState<EpisodeListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showFullDescription = false;
  int _visibleEpisodes = 5;

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // void _onScroll() {
  //   setState(() {
  //     // Track scroll for future use
  //   });
  // }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    return '$minutes min';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final episodesState = ref.watch(
      episodeListViewModelProvider(widget.podcast.id),
    );
    final userPrefs = ref.watch(userPreferencesViewModelProvider);
    final isFollowing = userPrefs.followedPodcastIds.contains(
      widget.podcast.id,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF003334),
      body: episodesState.when(
        data: (episodes) {
          if (episodes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.podcasts_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No episodes found',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          final firstEpisode = episodes.first;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Header with Artwork
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: const Color(0xFF003334),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(76),
                    shape: BoxShape.circle,
                  ),
                  child: BackButton(
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Podcast artwork background
                      Hero(
                        tag: 'podcast_${widget.podcast.id}',
                        child: CachedNetworkImage(
                          imageUrl: widget.podcast.thumbnail,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Container(color: const Color(0xFF1E2929)),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(178),
                              const Color(0xFF003334),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Podcast title overlay
                      Positioned(
                        bottom: 80,
                        left: 16,
                        right: 16,
                        child: Text(
                          widget.podcast.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 10),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Play button
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlayerScreen(
                                    episode: firstEpisode,
                                    podcast: widget.podcast,
                                    allEpisodes: episodes,
                                    currentIndex: 0,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow, size: 24),
                            label: const Text('Play'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A86B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save button
                          _buildActionIconButton(
                            icon: isFollowing ? Icons.check : Icons.add,
                            label: isFollowing ? 'Following' : 'Follow',
                            onTap: () async {
                              await ref
                                  .read(
                                    userPreferencesViewModelProvider.notifier,
                                  )
                                  .toggleFollow(widget.podcast.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionIconButton(
                              icon: Icons.playlist_add,
                              label: 'Add to queue',
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            _buildActionIconButton(
                              icon: Icons.share,
                              label: 'Share episode',
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            _buildActionIconButton(
                              icon: Icons.playlist_play,
                              label: 'Add to playlist',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // About Podcast Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ABOUT PODCAST',
                        style: TextStyle(
                          color: Color(0xFF00A86B),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${episodes.length} Episodes',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '5 Subscribers',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.podcast.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        maxLines: _showFullDescription ? 100 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.podcast.description.length > 150)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showFullDescription = !_showFullDescription;
                            });
                          },
                          child: Text(
                            _showFullDescription ? 'Show less' : 'Show more',
                            style: const TextStyle(
                              color: Color(0xFF00A86B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Sort/Filter Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip('Sort by: Newest'),
                      const SizedBox(width: 12),
                      _buildFilterChip('Filter: All episodes'),
                    ],
                  ),
                ),
              ),

              // Episodes List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _visibleEpisodes) return null;
                    final episode = episodes[index];
                    return _buildEpisodeItem(episode, episodes, index);
                  },
                  childCount: episodes.length > _visibleEpisodes
                      ? _visibleEpisodes
                      : episodes.length,
                ),
              ),

              // Show More Button
              if (episodes.length > _visibleEpisodes)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _visibleEpisodes += 5;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Show more'),
                      ),
                    ),
                  ),
                ),

              // See Related Podcasts
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See related podcasts >',
                      style: TextStyle(color: Color(0xFF00A86B), fontSize: 14),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00A86B)),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error loading episodes',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
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
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(
    Episode episode,
    List<Episode> allEpisodes,
    int index,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              episode: episode,
              podcast: widget.podcast,
              allEpisodes: allEpisodes,
              currentIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: episode.thumbnail,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[800]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.podcasts, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Episode details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode.description,
                    style: TextStyle(
                      color: Colors.white.withAlpha(178),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatDate(episode.publishedAt),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(episode.duration),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // More options
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
