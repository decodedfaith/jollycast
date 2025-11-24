class Episode {
  final String id;
  final String podcastId;
  final String title;
  final String description;
  final String audioUrl;
  final String thumbnail;
  final Duration duration;
  final DateTime publishedAt;
  final String? author;

  Episode({
    required this.id,
    required this.podcastId,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.thumbnail,
    required this.duration,
    required this.publishedAt,
    this.author,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    // Parse duration from seconds or string format
    Duration parseDuration(dynamic value) {
      if (value == null) return Duration.zero;
      if (value is int) return Duration(seconds: value);
      if (value is String) {
        final parts = value.split(':');
        if (parts.length == 3) {
          return Duration(
            hours: int.tryParse(parts[0]) ?? 0,
            minutes: int.tryParse(parts[1]) ?? 0,
            seconds: int.tryParse(parts[2]) ?? 0,
          );
        } else if (parts.length == 2) {
          return Duration(
            minutes: int.tryParse(parts[0]) ?? 0,
            seconds: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      return Duration.zero;
    }

    // Parse published date
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Episode(
      id: json['id']?.toString() ?? '',
      podcastId:
          json['podcast_id']?.toString() ?? json['show_id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Episode',
      description: json['description'] ?? json['summary'] ?? '',
      audioUrl:
          json['audio_url'] ??
          json['content_url'] ?? // Added content_url based on logs
          json['file_url'] ??
          json['url'] ??
          json['audio'] ??
          json['media_url'] ??
          json['enclosure_url'] ??
          '',
      thumbnail:
          json['picture_url'] ??
          json['image_url'] ??
          json['thumbnail'] ??
          json['cover_picture_url'] ??
          '',
      duration: parseDuration(json['duration'] ?? json['length']),
      publishedAt: parseDate(
        json['published_at'] ?? json['pub_date'] ?? json['created_at'],
      ),
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'podcast_id': podcastId,
      'title': title,
      'description': description,
      'audio_url': audioUrl,
      'thumbnail': thumbnail,
      'duration': duration.inSeconds,
      'published_at': publishedAt.toIso8601String(),
      'author': author,
    };
  }
}
