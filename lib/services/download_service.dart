import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/download_model.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

class DownloadService {
  final Map<String, CancelToken> _activeDownloads = {};

  Future<String> getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir.path;
  }

  Future<Download> downloadEpisode(
    Download download,
    Function(Download) onProgress,
  ) async {
    try {
      final dio = Dio();
      final downloadDir = await getDownloadsDirectory();
      final fileName = '${download.episodeId}.mp3';
      final filePath = '$downloadDir/$fileName';

      _activeDownloads[download.id] = CancelToken();

      await dio.download(
        download.audioUrl,
        filePath,
        cancelToken: _activeDownloads[download.id],
        onReceiveProgress: (received, total) {
          final progress = total > 0 ? received / total : 0.0;
          final updated = download.copyWith(
            progress: progress,
            status: DownloadStatus.downloading,
            localPath: filePath,
          );
          onProgress(updated);
        },
      );

      _activeDownloads.remove(download.id);

      return download.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        localPath: filePath,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      _activeDownloads.remove(download.id);
      return download.copyWith(
        status: DownloadStatus.failed,
      );
    }
  }

  Future<void> pauseDownload(String downloadId) async {
    _activeDownloads[downloadId]?.cancel();
  }

  Future<void> resumeDownload(String downloadId) async {
    _activeDownloads.remove(downloadId);
  }

  Future<void> deleteDownload(String downloadId, String? localPath) async {
    if (localPath != null && File(localPath).existsSync()) {
      await File(localPath).delete();
    }
    _activeDownloads.remove(downloadId);
  }

  Future<bool> isEpisodeDownloaded(String episodeId) async {
    final downloadDir = await getDownloadsDirectory();
    final filePath = '$downloadDir/$episodeId.mp3';
    return File(filePath).existsSync();
  }

  Future<String?> getDownloadedFilePath(String episodeId) async {
    final downloadDir = await getDownloadsDirectory();
    final filePath = '$downloadDir/$episodeId.mp3';

    if (File(filePath).existsSync()) {
      return filePath;
    }
    return null;
  }
}
