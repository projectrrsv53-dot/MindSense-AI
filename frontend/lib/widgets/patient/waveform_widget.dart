// lib/widgets/patient/waveform_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class WaveformWidget extends StatefulWidget {
  final bool isPlaying;
  final Color? color;
  final double height;
  final int barCount;

  const WaveformWidget({
    super.key,
    this.isPlaying = false,
    this.color,
    this.height = 60,
    this.barCount = 30,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        size: Size(double.infinity, widget.height),
        painter: _WaveformPainter(
          progress: widget.isPlaying ? _controller.value : 0.0,
          color: widget.color ?? PatientColors.primary,
          barCount: widget.barCount,
          isPlaying: widget.isPlaying,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int barCount;
  final bool isPlaying;

  _WaveformPainter({
    required this.progress,
    required this.color,
    required this.barCount,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final barWidth = size.width / (barCount * 2);
    final centerY = size.height / 2;
    final rng = math.Random(42); // fixed seed for stable idle bars

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth * 2 + barWidth;

      double amplitude;
      if (isPlaying) {
        final phase = (i / barCount * 2 * math.pi) + (progress * 2 * math.pi);
        amplitude = (math.sin(phase) * 0.5 + 0.5);
      } else {
        // Static waveform shape when not playing
        amplitude = rng.nextDouble() * 0.6 + 0.2;
      }

      final barHeight = 6 + amplitude * (centerY - 6);

      paint.color = color.withOpacity(isPlaying ? 0.9 : 0.5);
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.isPlaying != isPlaying;
}

// ── Static waveform bars (for upload preview) ───────────────────────────────
class StaticWaveformBars extends StatelessWidget {
  final Color? color;
  final double height;

  const StaticWaveformBars({
    super.key,
    this.color,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(7);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(24, (i) {
        final h = (rng.nextDouble() * 0.7 + 0.3) * height;
        return Container(
          width: 3,
          height: h,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: (color ?? PatientColors.primary).withOpacity(0.6),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}