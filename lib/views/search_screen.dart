import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/podcast_list_viewmodel.dart';
import '../models/podcast_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final podcastsAsync = ref.watch(podcastListViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF003334),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      ref.read(searchViewModelProvider.notifier).clearSearch();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) {
                        podcastsAsync.whenData((podcasts) {
                          ref
                              .read(searchViewModelProvider.notifier)
                              .search(value, podcasts);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search podcasts...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withAlpha(25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        suffixIcon: searchState.query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(searchViewModelProvider.notifier)
                                      .clearSearch();
                                },
                              )
                            : null,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: searchState.query.isEmpty
                  ? _buildSearchHistory(searchState.searchHistory)
                  : searchState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSearchResults(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory(List<String> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              'Search for podcasts',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Find your favorite shows',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchViewModelProvider.notifier).clearHistory();
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Color(0xFF00A86B)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final query = history[index];
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.white54),
                title: Text(query, style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () {
                    ref
                        .read(searchViewModelProvider.notifier)
                        .removeFromHistory(query);
                  },
                ),
                onTap: () {
                  _searchController.text = query;
                  final podcastsAsync = ref.read(podcastListViewModelProvider);
                  podcastsAsync.whenData((podcasts) {
                    ref
                        .read(searchViewModelProvider.notifier)
                        .search(query, podcasts);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    final results = searchState.podcastResults;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'No results for "${searchState.query}"',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${results.length} podcast${results.length != 1 ? 's' : ''} found',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _buildPodcastItem(results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodcastItem(Podcast podcast) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: podcast.thumbnail,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[800]),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.podcasts, color: Colors.white54),
          ),
        ),
      ),
      title: Text(
        podcast.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        podcast.author,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // Navigate to podcast detail or episode list
        Navigator.of(context).pop();
      },
    );
  }
}
