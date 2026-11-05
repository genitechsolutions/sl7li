import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../data/chat_data.dart';

String voiceDuration(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// محتوى فقاعة الرسالة الصوتية: تشغيل/إيقاف + شريط تقدّم + المدة.
class VoiceBubbleBody extends StatefulWidget {
  const VoiceBubbleBody({
    super.key,
    required this.message,
    required this.color,
  });

  final ChatMessage message;
  final Color color;

  @override
  State<VoiceBubbleBody> createState() => _VoiceBubbleBodyState();
}

class _VoiceBubbleBodyState extends State<VoiceBubbleBody> {
  final _player = AudioPlayer();
  bool _loaded = false;
  bool _loading = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<bool> _prepare() async {
    if (_loaded) return true;
    final m = widget.message;
    String? url;
    if (m.voicePath != null) {
      url = m.voicePath;
    } else if (m.voiceKey != null) {
      url = await context.read<ConversationsCubit>().voiceUrl(m.voiceKey!);
    }
    if (url == null) return false;
    try {
      if (url.startsWith('http') || url.startsWith('blob:')) {
        await _player.setUrl(url);
      } else {
        await _player.setFilePath(url);
      }
    } on Object {
      return false;
    }
    return _loaded = true;
  }

  Future<void> _toggle() async {
    if (_loading) return;
    if (_player.playing) {
      await _player.pause();
      return;
    }
    setState(() => _loading = true);
    final ok = await _prepare();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تعذّر تشغيل التسجيل')));
      return;
    }
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    unawaited(_player.play());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = widget.message.voiceSeconds;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<bool>(
            stream: _player.playingStream,
            builder: (context, snap) {
              final playing = snap.data ?? false;
              return GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: _loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.textPrimary,
                          ),
                        )
                      : Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          color: colors.textPrimary,
                          size: 24,
                        ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snap) {
                final pos = snap.data?.inMilliseconds ?? 0;
                final value = total == 0
                    ? 0.0
                    : (pos / (total * 1000)).clamp(0.0, 1.0);
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                  color: colors.accent,
                  backgroundColor: widget.color.withValues(alpha: 0.25),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Text(
            voiceDuration(total),
            style: AppTextStyles.body14.copyWith(color: widget.color),
          ),
        ],
      ),
    );
  }
}
