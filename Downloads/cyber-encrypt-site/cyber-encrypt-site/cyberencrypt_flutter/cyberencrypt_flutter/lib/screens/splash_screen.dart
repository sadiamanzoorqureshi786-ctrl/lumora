import 'package:flutter/material.dart';
import '../theme/matrix_theme.dart';
import '../widgets/matrix_rain.dart';

/// Boot-up splash shown once when the mobile app launches, before we know whether
/// the user is logged in. Purely cosmetic — AuthProvider.init() (token
/// check) runs in parallel behind this, and _RootGate in main.dart decides
/// where to go next once both finish.
class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  final List<String> _bootLines = const [
    '> INITIALIZING SECURE CHANNEL...',
    '> LOADING ENCRYPTION MODULES...',
    '> VERIFYING BLOCKCHAIN LEDGER...',
    '> SYSTEM READY_',
  ];
  int _lineIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    for (int i = 0; i < _bootLines.length; i++) {
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _lineIndex = i);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: MatrixRain()),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Replaced emoji with actual icon for professional look
                    const Icon(Icons.lock_outline, color: MatrixColors.green, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'CYBERENCRYPT',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: MatrixColors.green,
                        fontFamily: 'monospace',
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 24,
                      child: Text(
                        _bootLines[_lineIndex],
                        style: TextStyle(
                          color: MatrixColors.greenAlpha(0.8),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}