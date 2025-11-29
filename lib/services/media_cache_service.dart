import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final mediaCacheServiceProvider = Provider<MediaCacheService>((ref) {
  return MediaCacheService();
});

class MediaCacheService {
  final Dio _dio = Dio();
  static const int _maxCacheSize = 5; // Max number of files to keep

  Future<String> get _cacheDirectory async {
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/media_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  Future<String?> getCachedFilePath(String url) async {
    try {
      final fileName = _getFileNameFromUrl(url);
      final dir = await _cacheDirectory;
      final file = File('$dir/$fileName');
      if (await file.exists()) {
        return file.path;
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }

  Future<void> prefetch(String url) async {
    try {
      final fileName = _getFileNameFromUrl(url);
      final dir = await _cacheDirectory;
      final filePath = '$dir/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        return; // Already cached
      }

      // Download file
      await _dio.download(url, filePath);

      // Manage cache size
      await _cleanupCache();
    } catch (e) {
      // Ignore download errors
    }
  }

  Future<void> _cleanupCache() async {
    try {
      final dir = Directory(await _cacheDirectory);
      final files = dir.listSync().whereType<File>().toList();

      if (files.length > _maxCacheSize) {
        // Sort by modification time (oldest first)
        files.sort(
          (a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()),
        );

        // Delete oldest files until we are within limit
        final filesToDelete = files.take(files.length - _maxCacheSize);
        for (final file in filesToDelete) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  String _getFileNameFromUrl(String url) {
    // Simple hash to ensure valid filename
    return '${url.hashCode}.mp3';
  }

  Future<void> clearCache() async {
    try {
      final dir = Directory(await _cacheDirectory);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore errors
    }
  }
}
