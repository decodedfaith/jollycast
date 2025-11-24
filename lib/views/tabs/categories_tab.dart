import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/podcast_model.dart';
import '../../viewmodels/podcast_list_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../category_screen.dart';

class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({super.key});

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podcastListState = ref.watch(podcastListViewModelProvider);
    final categoryState = ref.watch(categoryViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF003334),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'All podcast categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search categories or podcasts',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withAlpha(25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // Categories Grid
            Expanded(
              child: podcastListState.when(
                data: (podcasts) {
                  if (categoryState.categorizedPodcasts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return _buildCategoriesGrid(
                    context,
                    categoryState.categorizedPodcasts,
                    categoryState.availableCategories,
                    podcasts,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading categories',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(
    BuildContext context,
    Map<String, List<Podcast>> categorizedPodcasts,
    List<String> availableCategories,
    List<Podcast> allPodcasts,
  ) {
    // Filter categories based on search query
    final filteredCategories = _searchQuery.isEmpty
        ? availableCategories
        : availableCategories.where((category) {
            return category.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'No categories found for "$_searchQuery"',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final podcasts = categorizedPodcasts[category] ?? [];
        final podcastCount = podcasts.length;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    CategoryScreen(categoryName: category, podcasts: podcasts),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Background collage
                if (podcasts.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: List.generate(4, (i) {
                        if (i >= podcasts.length) {
                          return Container(color: Colors.grey[800]);
                        }
                        final podcast = podcasts[i];
                        return CachedNetworkImage(
                          imageUrl: podcast.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[800]),
                          errorWidget: (context, url, error) =>
                              Container(color: Colors.grey[800]),
                        );
                      }),
                    ),
                  ),
                // Overlay with label
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withAlpha(178)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$podcastCount podcast${podcastCount != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
