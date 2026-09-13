import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_preferences.dart';

class MediaPreview extends StatefulWidget {
  final String path;
  final bool video;

  const MediaPreview({
    super.key,
    required this.path,
    required this.video,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  late final Player _player;
  VideoController? _videoController;
  bool _isExceedingLimit = false;

  // Local state to prevent slider jitter while dragging
  bool _isSeeking = false;
  double _dragPositionMs = 0.0;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant MediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload player when navigating to a new audio/video path
    if (oldWidget.path != widget.path || oldWidget.video != widget.video) {
      _initPlayer();
    }
  }

  void _initPlayer() {
    final file = File(widget.path);
    if (!file.existsSync()) return;

    if (widget.video) {
      final limit = context.read<AppPreferences>().videoLimitMB;
      final fileSizeMB = file.lengthSync() / 1048576;

      if (fileSizeMB > limit) {
        setState(() {
          _isExceedingLimit = true;
        });
        return;
      }

      _isExceedingLimit = false;
      _videoController ??= VideoController(_player);
    } else {
      _isExceedingLimit = false;
    }

    // Open file on path change
    _player.open(Media(file.path));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds <= 0) return '00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isExceedingLimit) {
      final limit = context.read<AppPreferences>().videoLimitMB;
      return Center(
        child: Text(
          'Video exceeds the configured preview limit of $limit MB.',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (widget.video) {
      if (_videoController == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Video(controller: _videoController!);
    }

    // Audio Preview UI (Matching Video Full Layout)
    final theme = Theme.of(context);
    final fileName = File(widget.path).uri.pathSegments.last;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        children: [
          // Audio Art / Visual Display Space
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor.withOpacity(0.15),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.audiotrack_rounded,
                      size: 64,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      fileName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // YouTube Style Bottom Controls Bar
          Container(
            color: const Color(0xFF0F0F0F),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: StreamBuilder<Duration>(
              stream: _player.stream.duration,
              builder: (context, durSnapshot) {
                final duration = durSnapshot.data ?? Duration.zero;
                final totalMs = duration.inMilliseconds.toDouble();

                return StreamBuilder<Duration>(
                  stream: _player.stream.position,
                  builder: (context, posSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;
                    final posMs = position.inMilliseconds.toDouble();

                    final isReady = totalMs > 0;
                    final maxVal = isReady ? totalMs : 1.0;
                    final currentVal = _isSeeking
                        ? _dragPositionMs.clamp(0.0, maxVal)
                        : posMs.clamp(0.0, maxVal);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Seeker Slider
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3.0,
                            activeTrackColor: Colors.red,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.red,
                            overlayColor: Colors.red.withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14.0,
                            ),
                          ),
                          child: Slider(
                            value: currentVal,
                            min: 0.0,
                            max: maxVal,
                            onChanged: isReady
                                ? (val) {
                                    setState(() {
                                      _isSeeking = true;
                                      _dragPositionMs = val;
                                    });
                                  }
                                : null,
                            onChangeEnd: isReady
                                ? (val) async {
                                    await _player.seek(
                                      Duration(milliseconds: val.toInt()),
                                    );
                                    if (mounted) {
                                      setState(() {
                                        _isSeeking = false;
                                      });
                                    }
                                  }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(
                                  _isSeeking
                                      ? Duration(
                                          milliseconds: _dragPositionMs.toInt(),
                                        )
                                      : position,
                                ),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Action Controls Row
                        Row(
                          children: [
                            // Play/Pause
                            StreamBuilder<bool>(
                              stream: _player.stream.playing,
                              initialData: false,
                              builder: (context, snapshot) {
                                final isPlaying = snapshot.data ?? false;
                                return IconButton(
                                  iconSize: 32,
                                  color: Colors.white,
                                  onPressed: () {
                                    if (isPlaying) {
                                      _player.pause();
                                    } else {
                                      _player.play();
                                    }
                                  },
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(width: 8),

                            // Seek Back -10s
                            IconButton(
                              iconSize: 20,
                              color: Colors.white70,
                              onPressed: () {
                                final cur = _player.state.position;
                                _player.seek(cur - const Duration(seconds: 10));
                              },
                              icon: const Icon(Icons.replay_10_rounded),
                            ),

                            // Seek Forward +10s
                            IconButton(
                              iconSize: 20,
                              color: Colors.white70,
                              onPressed: () {
                                final cur = _player.state.position;
                                _player.seek(cur + const Duration(seconds: 10));
                              },
                              icon: const Icon(Icons.forward_10_rounded),
                            ),

                            const Spacer(),

                            // Volume Control
                            StreamBuilder<double>(
                              stream: _player.stream.volume,
                              initialData: 100.0,
                              builder: (context, snapshot) {
                                final volume = snapshot.data ?? 100.0;

                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      color: Colors.white70,
                                      onPressed: () {
                                        _player.setVolume(
                                          volume == 0 ? 100.0 : 0.0,
                                        );
                                      },
                                      icon: Icon(
                                        volume == 0
                                            ? Icons.volume_off_rounded
                                            : volume < 50
                                                ? Icons.volume_down_rounded
                                                : Icons.volume_up_rounded,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90,
                                      child: SliderTheme(
                                        data: const SliderThemeData(
                                          trackHeight: 2.0,
                                          activeTrackColor: Colors.white,
                                          inactiveTrackColor: Colors.white24,
                                          thumbColor: Colors.white,
                                          thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 4.0,
                                          ),
                                        ),
                                        child: Slider(
                                          value: volume,
                                          min: 0.0,
                                          max: 100.0,
                                          onChanged: (val) {
                                            _player.setVolume(val);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}