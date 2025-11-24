class Podcast {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String audioUrl;
  final String author;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.audioUrl,
    required this.author,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? '',
      thumbnail: json['picture_url'] ?? json['cover_picture_url'] ?? '',
      audioUrl:
          json['audio_url'] ??
          json['file_url'] ??
          json['url'] ??
          json['audio'] ??
          '',
      author: json['author'] ?? 'Unknown Author',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'picture_url': thumbnail, // Use original key for consistency
      'audio_url': audioUrl,
      'author': author,
    };
  }
}
