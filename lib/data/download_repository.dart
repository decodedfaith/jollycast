import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/download_model.dart';

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepository();
});

class DownloadRepository {
  static const String _boxName = 'downloads';

  Future<Box<dynamic>> _getBox() async {
    return await Hive.openBox(_boxName);
  }

  Future<void> saveDownload(Download download) async {
    final box = await _getBox();
    await box.put(download.id, download.toJson());
  }

  Future<void> updateDownload(Download download) async {
    final box = await _getBox();
    await box.put(download.id, download.toJson());
  }

  Future<void> deleteDownload(String downloadId) async {
    final box = await _getBox();
    await box.delete(downloadId);
  }

  Future<List<Download>> getAllDownloads() async {
    final box = await _getBox();
    return box.values
        .map((e) => Download.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Download?> getDownload(String downloadId) async {
    final box = await _getBox();
    final data = box.get(downloadId);
    if (data != null) {
      return Download.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
}
