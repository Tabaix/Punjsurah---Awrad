import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/quran_download_service.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  int? _currentAyahIndex;

  QuranAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForIndexChanges();
    _listenForSequenceStateChanges();
  }

  void _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      debugPrint("Error loading empty playlist: $e");
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForIndexChanges() {
    _player.currentIndexStream.listen((index) {
      if (index != null && index < queue.value.length) {
        _currentAyahIndex = index;
        mediaItem.add(queue.value[index]);
      }
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem).toList();
      queue.add(items);
    });
  }

  Future<void> loadAyahs(List<dynamic> ayahs, String reciter, String title) async {
    final mediaItems = <MediaItem>[];
    final audioSources = <AudioSource>[];

    for (var i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      final ayahNumber = ayah['number'];
      final ayahInSurah = ayah['numberInSurah'];
      final surahName = ayah['surah'] != null ? ayah['surah']['englishName'] : title;
      
      final mediaItem = MediaItem(
        id: 'ayah_$ayahNumber',
        album: surahName,
        title: 'Aya $ayahInSurah',
        artist: reciter,
        extras: {'index': i, 'ayahNumber': ayahNumber},
      );
      mediaItems.add(mediaItem);

      final localPath = await QuranDownloadService.getAudioPath(ayahNumber, reciter);
      if (await File(localPath).exists()) {
        audioSources.add(AudioSource.uri(Uri.file(localPath), tag: mediaItem));
      } else {
        final url = 'https://cdn.islamic.network/quran/audio/128/$reciter/$ayahNumber.mp3';
        audioSources.add(AudioSource.uri(Uri.parse(url), tag: mediaItem));
      }
    }

    await _playlist.clear();
    await _playlist.addAll(audioSources);
    queue.add(mediaItems);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  Stream<int?> get currentAyahIndexStream => _player.currentIndexStream;
}
