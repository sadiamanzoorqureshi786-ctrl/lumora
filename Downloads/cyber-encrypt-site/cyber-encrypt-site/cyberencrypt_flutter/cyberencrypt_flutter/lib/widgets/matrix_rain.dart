import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Matrix rain, performance-fixed version.
///
/// KEY FIX: the previous version created a brand-new TextPainter (which
/// runs text layout — genuinely expensive) for every character, every
/// trail slot, every single frame. With ~190 columns × 40 trail slots
/// that's 7,000+ fresh layouts every 10ms — far more than the UI thread
/// can do, which is why it looked stuck/frozen.
/// Fix: there are only 62 possible characters and a small set of opacity
/// "buckets" — pre-build and CACHE a TextPainter per (char, opacity bucket)
/// pair once, then just reuse them every frame. Actual painting is cheap;
/// building the painter was the expensive part.
class MatrixRain extends StatefulWidget {
  const MatrixRain({super.key});

  @override
  State<MatrixRain> createState() => _MatrixRainState();
}

class _Column {
  double head;
  final List<String> trail;
  _Column(this.head, this.trail);
}

class _MatrixRainState extends State<MatrixRain> with SingleTickerProviderStateMixin {
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%^&*()_+-=[]{}|;:,.<>?';

  static const double _fontSize = 11;
  static const int _tickMs = 20; // fall speed — lower = faster
  static const double _decay = 0.95; // trail fade rate — higher = longer visible trail
  static const int _trailLength = 40;

  late final Ticker _ticker;
  final Random _rand = Random();
  final List<_Column> _columns = [];
  int _lastMs = 0;

  // char -> (opacity bucket 0-20) -> cached TextPainter
  final Map<String, Map<int, TextPainter>> _painterCache = {};

  TextPainter _getPainter(String char, double opacity) {
    final bucket = (opacity * 20).round().clamp(1, 20); // 20 opacity steps
    final byChar = _painterCache.putIfAbsent(char, () => {});
    return byChar.putIfAbsent(bucket, () {
      final tp = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            color: const Color(0xFF00FF00).withValues(alpha: bucket / 20),
            fontFamily: 'monospace',
            fontSize: _fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      return tp;
    });
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final ms = elapsed.inMilliseconds;
    if (ms - _lastMs >= _tickMs) {
      _lastMs = ms;
      _advance();
      setState(() {});
    }
  }

  void _advance() {
    for (final col in _columns) {
      col.trail.insert(0, _chars[_rand.nextInt(_chars.length)]);
      if (col.trail.length > _trailLength) col.trail.removeLast();
      col.head += 1;
    }
  }

  void _ensureColumns(int count) {
    while (_columns.length < count) {
      _columns.add(_Column(1, []));
    }
    if (_columns.length > count) {
      _columns.removeRange(count, _columns.length);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = (constraints.maxWidth / _fontSize).floor().clamp(1, 800);
        _ensureColumns(columnCount);

        return ClipRect(
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _MatrixPainter(
              columns: _columns,
              fontSize: _fontSize,
              maxRows: constraints.maxHeight / _fontSize,
              random: _rand,
              getPainter: _getPainter,
            ),
          ),
        );
      },
    );
  }
}

class _MatrixPainter extends CustomPainter {
  _MatrixPainter({
    required this.columns,
    required this.fontSize,
    required this.maxRows,
    required this.random,
    required this.getPainter,
  });

  final List<_Column> columns;
  final double fontSize;
  final double maxRows;
  final Random random;
  final TextPainter Function(String char, double opacity) getPainter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black);

    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];
      final x = i * fontSize;

      for (int t = 0; t < col.trail.length; t++) {
        final opacity = pow(_MatrixRainState._decay, t).toDouble();
        if (opacity < 0.05) break;

        final row = col.head - t;
        if (row < 0 || row > maxRows) continue;
        final y = row * fontSize;

        getPainter(col.trail[t], opacity).paint(canvas, Offset(x, y));
      }

      if (col.head * fontSize > maxRows * fontSize && random.nextDouble() > 0.975) {
        col.head = 0;
        col.trail.clear();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter oldDelegate) => true;
}