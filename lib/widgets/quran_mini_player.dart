import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../main.dart';

class QuranMiniPlayer extends StatelessWidget {
  const QuranMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final playing = playbackState?.playing ?? false;
            final processingState = playbackState?.processingState ?? AudioProcessingState.idle;

            if (processingState == AudioProcessingState.idle) return const SizedBox.shrink();

            return Container(
              height: 65,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book, color: Color(0xFF1A237E)),
                ),
                title: Text(
                  mediaItem.album ?? 'Quran',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  mediaItem.title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: audioHandler.skipToPrevious,
                    ),
                    if (processingState == AudioProcessingState.buffering ||
                        processingState == AudioProcessingState.loading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                      )
                    else
                      IconButton(
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.amber, size: 30),
                        onPressed: playing ? audioHandler.pause : audioHandler.play,
                      ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: audioHandler.skipToNext,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: audioHandler.stop,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
