import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/podcast_model.dart';
import '../models/episode_model.dart';

final playerViewModelProvider = NotifierProvider<PlayerViewModel, PlayerState>(
  () {
    return PlayerViewModel();
  },
);

class PlayerState {
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final Podcast? currentPodcast;
  final Episode? currentEpisode;
  final List<Episode> queue;
  final int currentIndex;
  final double playbackSpeed;

  PlayerState({
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.currentPodcast,
    this.currentEpisode,
    this.queue = const [],
    this.currentIndex = 0,
    this.playbackSpeed = 1.0,
  });

  PlayerState copyWith({
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    Podcast? currentPodcast,
    Episode? currentEpisode,
    List<Episode>? queue,
    int? currentIndex,
    double? playbackSpeed,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      currentPodcast: currentPodcast ?? this.currentPodcast,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

class PlayerViewModel extends Notifier<PlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  PlayerState build() {
    _init();
    ref.onDispose(() {
      _audioPlayer.dispose();
    });
    return PlayerState();
  }

  void _init() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        // Playlist completion is handled by ConcatenatingAudioSource usually,
        // but if the whole list finishes:
        state = state.copyWith(
          isPlaying: false,
          position: Duration.zero,
          isBuffering: false,
        );
        _audioPlayer.seek(Duration.zero, index: 0);
        _audioPlayer.pause();
      } else {
        state = state.copyWith(
          isPlaying: isPlaying,
          isBuffering:
              processingState == ProcessingState.buffering ||
              processingState == ProcessingState.loading,
        );
      }
    });

    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      state = state.copyWith(bufferedPosition: bufferedPosition);
    });

    _audioPlayer.durationStream.listen((duration) {
      state = state.copyWith(duration: duration ?? Duration.zero);
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null &&
          state.queue.isNotEmpty &&
          index < state.queue.length) {
        state = state.copyWith(
          currentIndex: index,
          currentEpisode: state.queue[index],
          // Reset duration/position for new track until stream updates
        );
      }
    });
  }

  Future<void> playPodcast(Podcast podcast) async {
    // Legacy support or single podcast playback
    if (state.currentPodcast?.id != podcast.id) {
      state = state.copyWith(currentPodcast: podcast);
      try {
        if (podcast.audioUrl.isEmpty) return;
        await _audioPlayer.setUrl(podcast.audioUrl);
        _audioPlayer.play();
      } catch (e) {
        print("PlayerViewModel: Error playing podcast: $e");
      }
    } else {
      togglePlayPause();
    }
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void skipForward({int seconds = 10}) {
    final newPosition = state.position + Duration(seconds: seconds);
    if (newPosition < state.duration) {
      _audioPlayer.seek(newPosition);
    } else {
      _audioPlayer.seek(state.duration);
    }
  }

  void skipBackward({int seconds = 10}) {
    final newPosition = state.position - Duration(seconds: seconds);
    if (newPosition > Duration.zero) {
      _audioPlayer.seek(newPosition);
    } else {
      _audioPlayer.seek(Duration.zero);
    }
  }

  void setPlaybackSpeed(double speed) {
    _audioPlayer.setSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  Future<void> playEpisode(Episode episode) async {
    // Play single episode (creates a 1-item playlist)
    await playPlaylist([episode], 0);
  }

  Future<void> playPlaylist(List<Episode> episodes, int initialIndex) async {
    try {
      state = state.copyWith(queue: episodes, currentIndex: initialIndex);

      final children = episodes.map((e) {
        return AudioSource.uri(
          Uri.parse(e.audioUrl),
          tag: e, // Store episode metadata
        );
      }).toList();

      final playlist = ConcatenatingAudioSource(
        children: children,
        useLazyPreparation: true, // Prefetching optimization
        shuffleOrder: DefaultShuffleOrder(),
      );

      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      _audioPlayer.play();
    } catch (e) {
      print("PlayerViewModel: Error playing playlist: $e");
    }
  }

  void playNext() {
    if (_audioPlayer.hasNext) {
      _audioPlayer.seekToNext();
    }
  }

  void playPrevious() {
    if (_audioPlayer.hasPrevious) {
      _audioPlayer.seekToPrevious();
    }
  }
}
