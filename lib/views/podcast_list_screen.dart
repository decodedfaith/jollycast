import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/podcast_model.dart';
import '../models/episode_model.dart';
import '../viewmodels/episode_list_viewmodel.dart';
import '../viewmodels/user_preferences_viewmodel.dart';
import 'category_screen.dart';
import '../viewmodels/podcast_list_viewmodel.dart';
import 'episode_list_screen.dart';
import 'player_screen.dart';
import 'search_screen.dart';
import 'tabs/categories_tab.dart';
import 'tabs/library_tab.dart';
import '../widgets/mini_player.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_assets.dart';
import 'login_screen.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../providers/theme_provider.dart';

class PodcastListScreen extends ConsumerStatefulWidget {
  const PodcastListScreen({super.key});

  @override
  ConsumerState<PodcastListScreen> createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends ConsumerState<PodcastListScreen> {
  int _currentIndex = 0;
  Episode? _currentEpisode;
  Podcast? _currentPodcast;
  List<Episode>? _allEpisodes;
  bool _miniPlayerVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                _buildDiscoverTab(),
                const CategoriesTab(),
                const LibraryTab(),
              ],
            ),
            // Mini player overlay
            if (_miniPlayerVisible &&
                _currentEpisode != null &&
                _currentPodcast != null)
              MiniPlayer(
                episode: _currentEpisode!,
                podcast: _currentPodcast!,
                allEpisodes: _allEpisodes ?? [],
                currentIndex: 0,
                onClose: () {
                  setState(() {
                    _miniPlayerVisible = false;
                  });
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.bottomNavBackground,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.podcasts),
            label: AppStrings.discover,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: AppStrings.categories,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.library,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    final podcastListState = ref.watch(podcastListViewModelProvider);

    return podcastListState.when(
      data: (podcasts) {
        if (podcasts.isEmpty) {
          return const Center(
            child: Text(
              AppStrings.noPodcastsFound,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          );
        }

        // Split podcasts for demo purposes
        final trending = podcasts.take(5).toList();
        final editorsPick = podcasts.length > 5 ? podcasts[5] : podcasts.first;
        final newest = podcasts.skip(6).toList();

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Jolly Logo
                    Image.asset(AppAssets.logo, height: 30),
                    // Profile, Notification, Search container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Profile picture with Logout Menu
                          PopupMenuButton<String>(
                            offset: const Offset(0, 40),
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage(AppAssets.logo),
                            ),
                            onSelected: (value) async {
                              if (value == 'logout') {
                                await ref
                                    .read(authViewModelProvider.notifier)
                                    .logout();
                                if (mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      AppStrings.logout,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Notification icon
                          const Icon(
                            Icons.notifications,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const SizedBox(width: 12),
                          // Theme Toggle
                          GestureDetector(
                            onTap: () =>
                                ref.read(themeProvider.notifier).toggle(),
                            child: Icon(
                              ref.watch(themeProvider)
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Search icon
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SearchScreen(),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.search,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hot & Trending Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: const [
                    Text('🔥', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.hotAndTrending,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hot & Trending List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 380, // Increased height for new card design
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  itemCount: trending.length,
                  itemBuilder: (context, index) {
                    return _buildTrendingCard(trending[index]);
                  },
                ),
              ),
            ),

            // Editor's Pick Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: const [
                    Icon(Icons.star, color: Colors.purpleAccent),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.editorsPick,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Editor's Pick Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildEditorsPickCard(editorsPick),
              ),
            ),

            // Newest Episodes Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.newestEpisodes,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (newest.isNotEmpty) {
                          final random = (newest.toList()..shuffle()).first;
                          _playPodcast(context, random);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textTertiary),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          AppStrings.shufflePlay,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Newest Episodes List
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final podcast = newest[index];
                return _buildNewestEpisodeItem(context, podcast, index + 1);
              }, childCount: newest.length),
            ),

            // See All Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      AppStrings.seeAll,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Mixed by Interest Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  AppStrings.mixedByInterest,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Mixed by Interest Grid
            _buildMixedCategories(trending), // Pass trending for images

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildTrendingCard(dynamic podcast) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: CachedNetworkImageProvider(podcast.thumbnail),
          fit: BoxFit.cover,
        ),
      ),
      child: InkWell(
        onTap: () => _playPodcast(context, podcast),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(153),
                    Colors.black.withAlpha(230),
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
            ),
            // Play Button
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A86B).withAlpha(204),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/Jolly2.png',
                          height: 16,
                          width: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          podcast.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    podcast.title, // Using title as episode title for now
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    podcast.description.isNotEmpty
                        ? podcast.description
                        : 'In this episode of the Change Africa Podcast, we host Tarek Mouganie...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleAction(
                        Icons.favorite_border,
                        podcast,
                        'favorite',
                      ),
                      _buildCircleAction(Icons.download, podcast, 'download'),
                      _buildCircleAction(Icons.share, podcast, 'share'),
                      _buildCircleAction(Icons.more_horiz, podcast, 'more'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, dynamic podcast, String action) {
    return GestureDetector(
      onTap: () => _handleAction(action, podcast),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white38),
          color: Colors.white.withAlpha(25),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _handleAction(String action, dynamic item) async {
    switch (action) {
      case 'favorite':
        // For now, we'll toggle favorite on the podcast itself
        // In real app, you'd want to favorite specific episodes
        await ref
            .read(userPreferencesViewModelProvider.notifier)
            .toggleFavorite(item.id);
        if (mounted) {
          final isFav = ref
              .read(userPreferencesViewModelProvider.notifier)
              .isFavorite(item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFav ? 'Added to favorites' : 'Removed from favorites',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        break;
      case 'download':
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download feature coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;
      case 'share':
        // In real app, use share_plus package
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Share: ${item.title}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 'more':
        // Show more options
        break;
    }
  }

  Widget _buildEditorsPickCard(dynamic podcast) {
    return InkWell(
      onTap: () => _playPodcast(context, podcast),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2929), // Darker card background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Image
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: podcast.thumbnail,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[800],
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.white54),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A86B).withAlpha(204),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Details
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By: ${podcast.author}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    podcast.description,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final isFollowing = ref.watch(
                            userPreferencesViewModelProvider.select(
                              (state) =>
                                  state.followedPodcastIds.contains(podcast.id),
                            ),
                          );
                          return GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(
                                    userPreferencesViewModelProvider.notifier,
                                  )
                                  .toggleFollow(podcast.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFollowing
                                          ? 'Unfollowed ${podcast.title}'
                                          : 'Following ${podcast.title}',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isFollowing
                                    ? const Color(0xFF00A86B).withAlpha(76)
                                    : Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(20),
                                border: isFollowing
                                    ? Border.all(color: const Color(0xFF00A86B))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isFollowing ? Icons.check : Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFollowing ? 'Following' : 'Follow',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _handleAction('share', podcast),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white70,
                          size: 20,
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
    );
  }

  Widget _buildNewestEpisodeItem(
    BuildContext context,
    dynamic podcast,
    int index,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EpisodeListScreen(podcast: podcast),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: podcast.thumbnail,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey[800],
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.white54),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A86B).withAlpha(204),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    podcast.description.isNotEmpty
                        ? podcast.description
                        : 'In this episode of the Change Africa Podcast...',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '20 June, 23 • 30 minutes',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMixedCategories(List<dynamic> podcasts) {
    final categories = [
      '#Artandculture',
      '#Motivational',
      '#Sport',
      '#Technology',
      '#Comedy',
      '#Talkshow',
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final category = categories[index % categories.length];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(
                      categoryName: category,
                      podcasts: List<Podcast>.from(
                        podcasts,
                      ), // Pass all podcasts for demo
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: List.generate(4, (i) {
                          final podcast = podcasts[i % podcasts.length];
                          return CachedNetworkImage(
                            imageUrl: podcast.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[800]),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.error,
                                color: Colors.white54,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: categories.length),
      ),
    );
  }

  Future<void> _playPodcast(BuildContext context, Podcast podcast) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch episodes for the podcast
      final episodes = await ref.read(
        episodeListViewModelProvider(podcast.id).future,
      );

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (episodes.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No episodes available for this podcast'),
            ),
          );
        }
        return;
      }

      // Play the first episode
      final episode = episodes.first;

      // Track recently played
      await ref
          .read(userPreferencesViewModelProvider.notifier)
          .addToRecentlyPlayed(episode.id, podcast.id);

      // Store episode data before navigating
      setState(() {
        _currentEpisode = episode;
        _currentPodcast = podcast;
        _allEpisodes = episodes;
      });

      // Navigate to full player and show mini player when user returns
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              episode: episode,
              podcast: podcast,
              allEpisodes: episodes,
              currentIndex: 0,
            ),
          ),
        );

        // Show mini player after returning from full player
        if (mounted) {
          setState(() {
            _miniPlayerVisible = true;
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading episodes: $e')));
      }
    }
  }
}
