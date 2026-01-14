import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:gap/gap.dart';

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final bool isReading;

  const AudioMessageWidget({super.key, required this.audioUrl, required this.isReading});

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget>
    with SingleTickerProviderStateMixin {
  FlutterSoundPlayer? _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _sub;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _initPlayer();

    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  Future<void> _initPlayer() async {
    await _player!.openPlayer();
    _player!.setSubscriptionDuration(const Duration(milliseconds: 100));

    // الحصول على مدة الملف قبل التشغيل
    try {
      final tempDuration = await _player!.startPlayer(
        fromURI: widget.audioUrl,
        codec: Codec.aacADTS,
        whenFinished: () {},
      );

      if (tempDuration != null) {
        setState(() => _duration = tempDuration);
      }

      await _player!.stopPlayer(); // نوقف التشغيل فورًا بعد معرفة المدة
    } catch (e) {
      
    }
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _player!.pausePlayer();
      setState(() => _isPlaying = false);
      _waveController.stop();
    } else {
      await _player!.startPlayer(
        fromURI: widget.audioUrl,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
          _waveController.stop();
        },
      );
      _sub = _player!.onProgress!.listen((e) {
        setState(() {
          _position = e.position;
          _duration = e.duration; // تحديث مدة الملف أثناء التشغيل
        });
      });
      setState(() => _isPlaying = true);
      _waveController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player!.closePlayer();
    _player = null;
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      constraints: const BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.transparent),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 28,
              color: widget.isReading ? Colors.blue : Colors.black,
            ),
            onPressed: _playPause,
          ),
          // موجات الصوت
          Expanded(
            child: CustomPaint(
              painter: _FixedWavePainter(isReading: widget.isReading),
              child: const SizedBox(height: 24),
            ),
          ),
          Gap(20.w),
          // الوقت الحالي / مدة الملف
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _FixedWavePainter extends CustomPainter {
  final bool isReading;
  final List<double> _barHeights;

  _FixedWavePainter({required this.isReading})
    : _barHeights = List.generate(50, (index) => 0.3 + Random().nextDouble() * 0.7);

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 3.0;
    const gap = 2.0;
    final bars = (size.width / (barWidth + gap)).floor();

    for (int i = 0; i < bars; i++) {
      double variation = _barHeights[i % _barHeights.length];
      double barHeight = variation * size.height;

      final color = isReading ? Colors.blue : Colors.grey[300]!;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * (barWidth + gap), size.height - barHeight, barWidth, barHeight),
          const Radius.circular(2),
        ),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
