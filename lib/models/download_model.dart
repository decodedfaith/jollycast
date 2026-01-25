enum DownloadStatus { pending, downloading, completed, failed, paused }

class Download {
  final String id;
  final String episodeId;
  final String episodeName;
  final String podcastName;
  final String audioUrl;
  final String? localPath;
  final DownloadStatus status;
  final double progress;
  final DateTime createdAt;
  final DateTime? completedAt;

  Download({
    required this.id,
    required this.episodeId,
    required this.episodeName,
    required this.podcastName,
    required this.audioUrl,
    this.localPath,
    required this.status,
    required this.progress,
    required this.createdAt,
    this.completedAt,
  });

  factory Download.fromJson(Map<String, dynamic> json) {
    return Download(
      id: json['id'] ?? '',
      episodeId: json['episode_id'] ?? '',
      episodeName: json['episode_name'] ?? '',
      podcastName: json['podcast_name'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      localPath: json['local_path'],
      status: DownloadStatus.values[json['status'] ?? 0],
      progress: (json['progress'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episode_id': episodeId,
      'episode_name': episodeName,
      'podcast_name': podcastName,
      'audio_url': audioUrl,
      'local_path': localPath,
      'status': status.index,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Download copyWith({
    String? id,
    String? episodeId,
    String? episodeName,
    String? podcastName,
    String? audioUrl,
    String? localPath,
    DownloadStatus? status,
    double? progress,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Download(
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      episodeName: episodeName ?? this.episodeName,
      podcastName: podcastName ?? this.podcastName,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
