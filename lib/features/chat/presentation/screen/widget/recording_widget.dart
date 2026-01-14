import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingWidget extends StatefulWidget {
  final Function(File file) onSend;
  final Function()? onCancel;
  const RecordingWidget({super.key, required this.onSend, this.onCancel});

  @override
  State<RecordingWidget> createState() => _RecordingWidgetState();
}

class _RecordingWidgetState extends State<RecordingWidget> with SingleTickerProviderStateMixin {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  late AnimationController _waveController;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();

    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    // بدء التسجيل مباشرة بعد تحميل الـ Widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecording();
    });
  }

  Future<void> _initRecorder() async {
    await _recorder!.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(toFile: _filePath, codec: Codec.aacADTS);

    _recordingSeconds = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordingSeconds++);
    });

    setState(() => _isRecording = true);
    _waveController.repeat(reverse: true);
  }

  Future<void> _stopRecording({bool send = true}) async {
    if (!_isRecording) return;

    _recordingTimer?.cancel();

    String? path = _filePath; // حفظ المسار قبل أي تغيير

    try {
      await _recorder!.stopRecorder();
    } catch (_) {}

    // إيقاف الموجة وإعادة الضبط
    _waveController.stop();
    _waveController.reset();

    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
      _filePath = null;
    });

    if (path != null) {
      final file = File(path);
      if (send) {
        if (file.existsSync()) widget.onSend(file);
      } else {
        if (file.existsSync()) file.deleteSync();
      }
    }
  }

  String _formatRecordingTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorder!.closeRecorder();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRecording) return const SizedBox.shrink();

    return Container(
      child: Row(
        children: [
          // زر الإلغاء

          // الرسم البياني للموجة
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: _WavePainter(progress: 1, waveHeight: _waveController.value, isMe: true),
                child: const SizedBox(width: 150, height: 40),
              );
            },
          ),
          const SizedBox(width: 10),

          // وقت التسجيل
          Text(
            _formatRecordingTime(_recordingSeconds),
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),

          const Spacer(),
          // زر الإرسال
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => _stopRecording(send: true),
          ),
        ],
      ),
    );
  }
}

// -------------------- WavePainter --------------------
class _WavePainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final double waveHeight; // 0.0 - 1.0
  final bool isMe;

  _WavePainter({required this.progress, required this.waveHeight, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 1.0;
    const gap = 1.0;
    final bars = (size.width / (barWidth + gap)).floor();

    for (int i = 0; i < bars; i++) {
      double heightFactor = (sin((i + waveHeight * 3) * pi / 5) * 0.5 + 0.5);
      double barHeight = size.height * heightFactor;

      final barProgress = i / bars;
      final color = barProgress <= progress ? Colors.green : Colors.grey[400]!;

      canvas.drawRect(
        Rect.fromLTWH(i * (barWidth + gap), size.height - barHeight, barWidth, barHeight),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
