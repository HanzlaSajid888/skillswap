import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioMessageBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMe;
  final String timeText;
  final bool isRead;

  const AudioMessageBubble({
    super.key,
    required this.audioUrl,
    required this.isMe,
    required this.timeText,
    required this.isRead,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Set the URL so we can get the duration before playing
    final source = widget.audioUrl.startsWith('http') 
        ? UrlSource(widget.audioUrl) 
        : DeviceFileSource(widget.audioUrl);
        
    _audioPlayer.setSource(source).catchError((_) {
      // Ignore initial load errors, might be due to network
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isMe ? Colors.indigo : Colors.grey.shade200;
    final fgColor = widget.isMe ? Colors.white : Colors.indigo;
    final textColor = widget.isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: widget.isMe ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight: widget.isMe ? const Radius.circular(0) : const Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      // Ensure source is set before playing
                      final source = widget.audioUrl.startsWith('http') 
                          ? UrlSource(widget.audioUrl) 
                          : DeviceFileSource(widget.audioUrl);
                      await _audioPlayer.play(source);
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: widget.isMe ? Colors.white24 : Colors.white,
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: fgColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                          trackHeight: 3.0,
                        ),
                        child: Slider(
                          min: 0.0,
                          max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                          value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0),
                          activeColor: fgColor,
                          inactiveColor: widget.isMe ? Colors.indigo.shade300 : Colors.grey.shade400,
                          onChanged: (value) async {
                            final position = Duration(milliseconds: value.toInt());
                            await _audioPlayer.seek(position);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.timeText,
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (widget.isMe) const SizedBox(width: 4),
                if (widget.isMe)
                  Icon(
                    widget.isRead ? Icons.done_all : Icons.check,
                    size: 14,
                    color: widget.isRead ? Colors.blueAccent : Colors.white70,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
