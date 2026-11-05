import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

class RecordedVoice {
  const RecordedVoice(this.path, this.seconds);

  final String path;
  final int seconds;
}

class VoiceRecorder {
  final _recorder = AudioRecorder();
  DateTime? _startedAt;

  Future<bool> start() async {
    try {
      return await _start();
    } on Object catch (e) {
      debugPrint('Voice recording failed: $e');
      return false;
    }
  }

  Future<bool> _start() async {
    if (!await _recorder.hasPermission()) return false;
    final path = kIsWeb
        ? ''
        : '${Directory.systemTemp.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      RecordConfig(encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc),
      path: path,
    );
    _startedAt = DateTime.now();
    return true;
  }

  Future<RecordedVoice?> stop() async {
    final path = await _recorder.stop();
    final started = _startedAt;
    _startedAt = null;
    if (path == null || started == null) return null;
    final seconds = DateTime.now().difference(started).inSeconds;
    return RecordedVoice(path, seconds < 1 ? 1 : seconds);
  }

  Future<void> cancel() async {
    _startedAt = null;
    await _recorder.cancel();
  }

  Future<void> dispose() => _recorder.dispose();
}
