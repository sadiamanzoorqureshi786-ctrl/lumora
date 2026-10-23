import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// Core Palette
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _white = Color(0xFFF0FFF3);
const Color _soft = Color(0xFFC9FBD2);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _borderDim = Color(0xFF143D20);

Color _g(double alpha) => _green.withValues(alpha: alpha);

const double _displaySize = 64.0;
const double _headlineSize = 40.0;
const double _titleSize = 24.0;
const double _bodySize = 16.0;
const double _labelSize = 14.0;
const double _smallSize = 12.0;

class CyberEncryptLandingB extends StatefulWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onSignIn;

  const CyberEncryptLandingB({
    super.key,
    this.onGetStarted,
    this.onSignIn,
  });

  @override
  State<CyberEncryptLandingB> createState() => _CyberEncryptLandingBState();
}

class _CyberEncryptLandingBState extends State<CyberEncryptLandingB>
    with TickerProviderStateMixin {
  late final AnimationController _matrix;
  late final AnimationController _pulse;
  late final AnimationController _glitch;
  late final AnimationController _float;
  late final AnimationController _lightSweep;

  final ScrollController _scroll = ScrollController();
  final GlobalKey _flowKey = GlobalKey();
  final GlobalKey _metricsKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _screensKey = GlobalKey();
  bool _solidNav = false;
  
  bool _flowRevealed = false;
  bool _metricsRevealed = false;
  bool _featuresRevealed = false;
  bool _screensRevealed = false;

  @override
  void initState() {
    super.initState();
    _matrix = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _glitch = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
    _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..repeat();
    _lightSweep = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _scroll.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scroll.hasClients) return;
    final next = _scroll.offset > 24;
    if (next != _solidNav) setState(() => _solidNav = next);

    bool checkVisible(GlobalKey key) {
      final ctx = key.currentContext;
      if (ctx == null) return false;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return false;
      final pos = box.localToGlobal(Offset.zero);
      return pos.dy < MediaQuery.of(context).size.height * 0.85;
    }

    final flowVis = checkVisible(_flowKey);
    final metVis = checkVisible(_metricsKey);
    final featVis = checkVisible(_featuresKey);
    final scrVis = checkVisible(_screensKey);

    if (flowVis != _flowRevealed) setState(() => _flowRevealed = flowVis);
    if (metVis != _metricsRevealed) setState(() => _metricsRevealed = metVis);
    if (featVis != _featuresRevealed) setState(() => _featuresRevealed = featVis);
    if (scrVis != _screensRevealed) setState(() => _screensRevealed = scrVis);
  }

  @override
  void dispose() {
    _scroll.removeListener(_handleScroll);
    _scroll.dispose();
    _matrix.dispose();
    _pulse.dispose();
    _glitch.dispose();
    _float.dispose();
    _lightSweep.dispose();
    super.dispose();
  }

  bool _wide(BuildContext context) => MediaQuery.sizeOf(context).width >= 920;

  void _go(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: 0.02,
    );
  }

  void _start() => widget.onGetStarted?.call();
  void _signIn() => widget.onSignIn?.call();

  @override
  Widget build(BuildContext context) {
    final wide = _wide(context);
    return Scaffold(
      backgroundColor: _black,
      body: Stack(
        children: [
          Positioned.fill(child: _MatrixBackground(animation: _matrix)),
          Positioned.fill(child: IgnorePointer(child: _CircuitBackground(animation: _pulse))),
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                _Hero(
                  wide: wide,
                  pulse: _pulse,
                  glitch: _glitch,
                  onStart: _start,
                  onScreens: () => _go(_screensKey),
                ),
                const _CipherTicker(),
                _ScrollReveal(visible: _flowRevealed, child: KeyedSubtree(key: _flowKey, child: _FlowSection(wide: wide))),
                _ScrollReveal(visible: _metricsRevealed, child: KeyedSubtree(key: _metricsKey, child: const _LiveMetricsSection())),
                _ScrollReveal(visible: _featuresRevealed, slideRight: true, child: KeyedSubtree(key: _featuresKey, child: _FeatureSection(wide: wide, lightController: _lightSweep))),
                _ScrollReveal(visible: _screensRevealed, child: KeyedSubtree(key: _screensKey, child: _ScreensSection(wide: wide, float: _float))),
                _FinalCta(onStart: _start),
                const _Footer(),
              ],
            ),
          ),
          _Nav(
            solid: _solidNav,
            wide: wide,
            onFlow: () => _go(_flowKey),
            onFeatures: () => _go(_featuresKey),
            onScreens: () => _go(_screensKey),
            onSignIn: _signIn,
            onStart: _start,
          ),
        ],
      ),
    );
  }
}

// --- Scroll Reveal Wrapper ---
class _ScrollReveal extends StatelessWidget {
  final bool visible;
  final bool slideRight;
  final Widget child;
  const _ScrollReveal({required this.visible, required this.child, this.slideRight = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : (slideRight ? const Offset(0.15, 0) : const Offset(-0.15, 0)),
        child: child,
      ),
    );
  }
}

// --- Seamless News Ticker ---
class _CipherTicker extends StatefulWidget {
  const _CipherTicker();

  @override
  State<_CipherTicker> createState() => _CipherTickerState();
}

class _CipherTickerState extends State<_CipherTicker> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
    _controller.addListener(() {
      if (_scrollController.hasClients) {
        double max = _scrollController.position.maxScrollExtent;
        if (max > 0) {
          _scrollController.jumpTo((_controller.value * max) % max);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const items = ['AES-256', 'RSA', 'SHA-256', 'CAESAR CIPHER', 'TRANSPOSITION'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: const BoxDecoration(
        color: _black,
        border: Border(
          top: BorderSide(color: _borderDim, width: 1),
          bottom: BorderSide(color: _borderDim, width: 1),
        ),
      ),
      child: SizedBox(
        height: 20,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 100,
          itemBuilder: (context, index) {
            final item = items[index % items.length];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(item, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 16.0, fontWeight: FontWeight.bold, letterSpacing: 2)),
            );
          },
        ),
      ),
    );
  }
}

// --- PREMIUM GLASSMORPHISM HEADER ---
class _Nav extends StatelessWidget {
  final bool solid;
  final bool wide;
  final VoidCallback onFlow;
  final VoidCallback onFeatures;
  final VoidCallback onScreens;
  final VoidCallback onSignIn;
  final VoidCallback onStart;

  const _Nav({
    required this.solid,
    required this.wide,
    required this.onFlow,
    required this.onFeatures,
    required this.onScreens,
    required this.onSignIn,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: solid ? _black.withValues(alpha: 0.80) : Colors.transparent,
          border: Border(bottom: BorderSide(color: solid ? _green.withValues(alpha: 0.2) : Colors.transparent, width: 1.5)),
          boxShadow: solid ? [BoxShadow(color: _green.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2)] : null,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: solid ? 16.0 : 0.0, sigmaY: solid ? 16.0 : 0.0),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 18, vertical: wide ? 14 : 10),
                child: Row(
                  children: [
                    const _Brand(),
                    const Spacer(),
                    if (wide) ...[
                      _NavText('FLOW', onFlow),
                      _NavText('CAPABILITIES', onFeatures),
                      _NavText('SCREENS', onScreens),
                      const SizedBox(width: 24),
                      TextButton(
                        onPressed: onSignIn,
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                        child: const Text('SIGN IN', style: TextStyle(color: _soft, fontFamily: 'monospace', fontSize: _labelSize, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      ),
                      const SizedBox(width: 16),
                    ],
                    _GreenButton(label: 'GET STARTED', onTap: onStart, compact: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavText(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: _soft,
            fontFamily: 'monospace',
            fontSize: _labelSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool wide;
  final Animation<double> pulse;
  final Animation<double> glitch;
  final VoidCallback onStart;
  final VoidCallback onScreens;

  const _Hero({
    required this.wide,
    required this.pulse,
    required this.glitch,
    required this.onStart,
    required this.onScreens,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: math.max(height * 0.85, 720)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.45,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Image.asset(
                  'assets/images/hero_hacker.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(wide ? 80 : 24, wide ? 150 : 130, wide ? 64 : 24, 90),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _GlitchText(
                      text: 'CYBERENCRYPT',
                      animation: glitch,
                      fontSize: wide ? _displaySize : 50.0,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      'Encrypted conversations with proof written to the chain.',
                      style: TextStyle(
                        color: _white,
                        fontSize: wide ? _titleSize : 18.0,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Text(
                      'A hacker-themed security app for classical ciphers, AES-256, RSA, encrypted messaging, Google OAuth, user search, history, and a tamper-evident blockchain ledger.',
                      style: TextStyle(
                        color: _soft,
                        fontFamily: 'monospace',
                        fontSize: wide ? _labelSize : _smallSize,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _GreenButton(label: 'LAUNCH SECURE ACCESS', onTap: onStart),
                      _OutlineButton(label: 'VIEW APP SCREENS', onTap: onScreens),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0, height: 140,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.95)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlitchText extends StatelessWidget {
  final String text;
  final Animation<double> animation;
  final double fontSize;
  const _GlitchText({required this.text, required this.animation, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: _green, fontSize: fontSize, height: 1.0, fontWeight: FontWeight.w900, letterSpacing: -1.5,
      shadows: [Shadow(color: _g(0.5), blurRadius: 24)],
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final phase = (animation.value * 10).floor();
        final active = phase == 0 || phase == 7;
        final dx = active ? (phase == 0 ? 4.0 : -3.0) : 0.0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (active)
              Transform.translate(offset: Offset(dx, -2), child: Text(text, style: style.copyWith(color: const Color(0x66FF0000)))),
            if (active)
              Transform.translate(offset: Offset(-dx, 2), child: Text(text, style: style.copyWith(color: const Color(0x6600FFFF)))),
            Text(text, style: style),
          ],
        );
      },
    );
  }
}

// --- LIVE METRICS SECTION ---
class _LiveMetricsSection extends StatelessWidget {
  const _LiveMetricsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.44), border: const Border.symmetric(horizontal: BorderSide(color: _borderDim))),
      child: Column(
        children: [
          const Text('NETWORK STATUS', style: TextStyle(color: _green, fontFamily: 'monospace', fontSize: _labelSize, fontWeight: FontWeight.w900, letterSpacing: 4)),
          const SizedBox(height: 16),
          const Text('Real-time system integrity', style: TextStyle(color: _soft, fontSize: _bodySize, height: 1.6)),
          const SizedBox(height: 56),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const Wrap(
              spacing: 32,
              runSpacing: 32,
              alignment: WrapAlignment.center,
              children: [
                _CountUp(target: 1204503, label: 'MESSAGES ENCRYPTED'),
                _CountUp(target: 4219, label: 'ACTIVE NODES'),
                _CountUp(target: 100, label: 'CHAIN VALIDITY', suffix: '%'),
                _CountUp(target: 0, label: 'BREACHES DETECTED'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountUp extends StatefulWidget {
  final int target;
  final String label;
  final String suffix;
  const _CountUp({required this.target, required this.label, this.suffix = ''});

  @override
  State<_CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<_CountUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = IntTween(begin: 0, end: widget.target).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Text(
              '${_animation.value}${widget.suffix}',
              style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 36.0, fontWeight: FontWeight.w900, shadows: [Shadow(color: _green, blurRadius: 12)]),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(widget.label, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: _smallSize, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ],
    );
  }
}

class _FlowSection extends StatelessWidget {
  final bool wide;
  const _FlowSection({required this.wide});

  static const steps = [
    _FlowStepData(Icons.edit_note_outlined, 'COMPOSE', 'Write the message and choose the cipher.'),
    _FlowStepData(Icons.enhanced_encryption_outlined, 'ENCRYPT', 'Transform plaintext locally with a key.'),
    _FlowStepData(Icons.send_outlined, 'DELIVER', 'Send ciphertext to the verified recipient.'),
    _FlowStepData(Icons.account_tree_outlined, 'LOG', 'Append a tamper-evident block to the chain.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: Column(
        children: [
          _SectionHead(label: 'FLOW', title: 'Plaintext enters once. Proof remains forever.', body: 'Every message follows the same clear path: compose, encrypt, deliver, and log.', wide: wide),
          const SizedBox(height: 64),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < steps.length; i++) ...[
                        Expanded(child: _FlowStep(index: i + 1, data: steps[i])),
                        if (i != steps.length - 1) Padding(padding: const EdgeInsets.only(top: 32), child: Icon(Icons.arrow_forward, color: _g(0.78))),
                      ],
                    ],
                  )
                : Column(
                    children: [
                      for (int i = 0; i < steps.length; i++) ...[
                        _FlowStep(index: i + 1, data: steps[i]),
                        if (i != steps.length - 1) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Icon(Icons.keyboard_arrow_down, color: _g(0.78))),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FlowStepData {
  final IconData icon;
  final String title;
  final String body;
  const _FlowStepData(this.icon, this.title, this.body);
}

class _FlowStep extends StatelessWidget {
  final int index;
  final _FlowStepData data;
  const _FlowStep({required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    final active = index == 2;
    return Column(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? _g(0.12) : Colors.black,
            border: Border.all(color: active ? _green : _g(0.36), width: active ? 2 : 1),
            boxShadow: active ? [BoxShadow(color: _g(0.24), blurRadius: 32)] : null,
          ),
          child: Icon(data.icon, color: _green, size: 30),
        ),
        const SizedBox(height: 20),
        Text('0$index', style: TextStyle(color: _g(0.48), fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _smallSize)),
        const SizedBox(height: 8),
        Text(data.title, style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _labelSize, letterSpacing: 2)),
        const SizedBox(height: 10),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 205), child: Text(data.body, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: _smallSize, height: 1.55))),
      ],
    );
  }
}

// --- CAPABILITIES SECTION WITH CARDS GRID & CINEMATIC LIGHT SWEEP ---
class _FeatureSection extends StatelessWidget {
  final bool wide;
  final AnimationController lightController;
  const _FeatureSection({required this.wide, required this.lightController});

  static const items = [
    _Feature(Icons.lock_outline, 'MULTI-ALGORITHM ENCRYPTION', 'Classical ciphers sit beside AES-256 and RSA for learning and real security.'),
    _Feature(Icons.forum_outlined, 'ENCRYPTED MESSAGING', 'Messages are stored and delivered as ciphertext, then decrypted by the recipient.'),
    _Feature(Icons.account_tree_outlined, 'BLOCKCHAIN LEDGER', 'Every exchange gets a hash-linked event record that can be verified.'),
    _Feature(Icons.login_outlined, 'GOOGLE OAUTH', 'Users can sign in with Google or use a dedicated CyberEncrypt account.'),
    _Feature(Icons.history_outlined, 'FULL HISTORY', 'Sent and received messages resolve into one chronological audit trail.'),
    _Feature(Icons.manage_search_outlined, 'USER DIRECTORY', 'Find registered users fast and begin a secure conversation instantly.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cinematic Light Sweep Background
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: lightController,
              builder: (context, _) {
                return CustomPaint(
                  painter: PremiumLightPainter(progress: lightController.value),
                );
              },
            ),
          ),
        ),
        // Actual Content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), border: const Border.symmetric(horizontal: BorderSide(color: _borderDim))),
          child: Column(
            children: [
              _SectionHead(label: 'CAPABILITIES', title: 'Everything under one lock.', body: 'The platform reads like a single cybersecurity system, not a collection of random widgets.', wide: wide),
              const SizedBox(height: 56),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    for (int i = 0; i < items.length; i++)
                      _FeatureCard(index: i + 1, data: items[i], wide: wide),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Painter for "Broad crescents of silver light raking over folded darkness"
class PremiumLightPainter extends CustomPainter {
  final double progress;
  PremiumLightPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Folded Darkness (Subtle dark overlapping waves)
    final darkPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.6 + i * 0.1);
      final path = Path();
      path.moveTo(0, y);
      path.quadraticBezierTo(size.width * 0.5, y - 40 + (i * 10), size.width, y);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      darkPaint.color = Colors.black.withValues(alpha: 0.4 + (i * 0.1));
      canvas.drawPath(path, darkPaint);
    }

    // Silver Light Crescents (More visible rings)
    for (int i = 0; i < 3; i++) {
      final sweep = (progress * size.width * 1.5) - (i * size.width * 0.4);
      final x = sweep % (size.width * 1.5) - size.width * 0.25;
      final y = size.height * 0.5;

      final ringPath = Path();
      // Draw a large sweeping arc to simulate the crescent/ring
      ringPath.addOval(Rect.fromCenter(center: Offset(x, y), width: 600, height: 600));
      
      final gradient = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.8, 0.9, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: Offset(x, y), radius: 300))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 80.0
        ..blendMode = BlendMode.screen;

      canvas.drawPath(ringPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PremiumLightPainter oldDelegate) => true;
}

class _Feature {
  final IconData icon;
  final String title;
  final String body;
  const _Feature(this.icon, this.title, this.body);
}

// --- PREMIUM FEATURE CARD ---
class _FeatureCard extends StatefulWidget {
  final int index;
  final _Feature data;
  final bool wide;
  const _FeatureCard({required this.index, required this.data, required this.wide});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.wide ? 340 : double.infinity,
        padding: const EdgeInsets.all(24),
        transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: _panel.withValues(alpha: 0.8),
          border: Border.all(color: _hover ? _green.withValues(alpha: 0.6) : _borderDim, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hover ? [BoxShadow(color: _green.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2)] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: Icon(widget.data.icon, color: _green, size: 24),
                ),
                const Spacer(),
                Text('0${widget.index}', style: TextStyle(color: _green.withValues(alpha: 0.4), fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              widget.data.title,
              style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _labelSize, letterSpacing: 1.2, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              widget.data.body,
              style: const TextStyle(color: _muted, fontSize: _smallSize, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreensSection extends StatelessWidget {
  final bool wide;
  final Animation<double> float;
  const _ScreensSection({required this.wide, required this.float});

  static const rows = [
    _ScreenInfo('ENCRYPTION TOOL', 'Five ciphers, one command surface', 'Switch between Caesar, transposition, substitution, AES-256, and RSA instantly. Encrypt or decrypt text right in the app.', _PhoneMode.encrypt),
    _ScreenInfo('MESSAGES', 'Talk in ciphertext by default', 'Search the directory, pick a recipient, choose the algorithm, and send. Decryption happens on the recipient side with the correct key.', _PhoneMode.messages),
    _ScreenInfo('BLOCKCHAIN LEDGER', 'Verify every exchange after delivery', 'The ledger screen turns message events into inspectable blocks with hashes, timestamps, and a one-tap integrity check.', _PhoneMode.ledger),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
          child: _SectionHead(label: 'SCREENS', title: 'A look at the real app surfaces.', body: 'Large, cinematic screen sections make the landing page feel like the preview.', wide: wide),
        ),
        for (int i = 0; i < rows.length; i++) _ScreenRow(info: rows[i], reverse: i == 1, wide: wide, float: float),
      ],
    );
  }
}

class _ScreenInfo {
  final String label;
  final String title;
  final String body;
  final _PhoneMode mode;
  const _ScreenInfo(this.label, this.title, this.body, this.mode);
}

class _ScreenRow extends StatelessWidget {
  final _ScreenInfo info;
  final bool reverse;
  final bool wide;
  final Animation<double> float;
  const _ScreenRow({required this.info, required this.reverse, required this.wide, required this.float});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final text = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(info.label, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: _labelSize, fontWeight: FontWeight.w900, letterSpacing: 4)),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(info.title, textAlign: wide ? TextAlign.left : TextAlign.center, style: TextStyle(color: _white, fontSize: wide ? _headlineSize : 28.0, fontWeight: FontWeight.w800, height: 1.2)),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(info.body, textAlign: wide ? TextAlign.left : TextAlign.center, style: const TextStyle(color: _soft, fontSize: _bodySize, height: 1.6)),
        ),
      ],
    );

    final phone = _FloatingPhone(mode: info.mode, animation: float);
    if (!wide) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 60),
        child: Column(children: [phone, const SizedBox(height: 40), text]),
      );
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: math.max(720, height * 0.82)),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: reverse
                ? [Expanded(flex: 10, child: text), const SizedBox(width: 60), Expanded(flex: 7, child: Center(child: phone))]
                : [Expanded(flex: 7, child: Center(child: phone)), const SizedBox(width: 60), Expanded(flex: 10, child: text)],
          ),
        ),
      ),
    );
  }
}

class _FinalCta extends StatelessWidget {
  final VoidCallback onStart;
  const _FinalCta({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 90),
      decoration: BoxDecoration(color: _panel.withValues(alpha: 0.82), border: Border.symmetric(horizontal: BorderSide(color: _g(0.22)))),
      child: Column(
        children: [
          const Icon(Icons.security_outlined, color: _green, size: 56),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text('Make every message encrypted, logged, and verifiable.', textAlign: TextAlign.center, style: TextStyle(color: _white, fontSize: _headlineSize, height: 1.2, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: const Text('CyberEncrypt combines learning-friendly ciphers with production-grade cryptography and a visible audit trail.', textAlign: TextAlign.center, style: TextStyle(color: _soft, fontSize: _bodySize, height: 1.6)),
          ),
          const SizedBox(height: 36),
          _GreenButton(label: 'CREATE FREE ACCOUNT', onTap: onStart),
        ],
      ),
    );
  }
}

// --- FOOTER WITH WORKING LINKS ---
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      color: Colors.black,
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 32,
          runSpacing: 32,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Brand(),
                SizedBox(height: 16),
                Text('Secure by design.', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: _smallSize)),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _FooterLink('Privacy Policy', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _DocumentScreen(title: 'PRIVACY POLICY')))),
                _FooterLink('Terms of Service', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _DocumentScreen(title: 'TERMS OF SERVICE')))),
                _FooterLink('Documentation', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _DocumentScreen(title: 'DOCUMENTATION')))),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Copyright 2026 CyberEncrypt', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: _smallSize)),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: _green, size: 8),
                    const SizedBox(width: 8),
                    Text('All systems operational', style: TextStyle(color: _green.withValues(alpha: 0.8), fontFamily: 'monospace', fontSize: _smallSize)),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _FooterLink(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      child: Text(label, style: const TextStyle(color: _soft, fontFamily: 'monospace', fontSize: _smallSize, fontWeight: FontWeight.bold)),
    );
  }
}

class _SectionHead extends StatelessWidget {
  final String label;
  final String title;
  final String body;
  final bool wide;
  const _SectionHead({required this.label, required this.title, required this.body, required this.wide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: _labelSize, fontWeight: FontWeight.w900, letterSpacing: 4)),
        const SizedBox(height: 16),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 880), child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: _white, fontSize: wide ? _headlineSize : 28.0, height: 1.2, fontWeight: FontWeight.w800))),
        const SizedBox(height: 16),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700), child: Text(body, textAlign: TextAlign.center, style: const TextStyle(color: _soft, fontSize: _bodySize, height: 1.6))),
      ],
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.black, border: Border.all(color: _green), boxShadow: [BoxShadow(color: _g(0.22), blurRadius: 16)]), child: const Icon(Icons.lock_outline, color: _green, size: 22)),
        const SizedBox(width: 12),
        const Text('CYBERENCRYPT', style: TextStyle(color: _green, fontFamily: 'monospace', fontSize: _bodySize, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ],
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool compact;
  const _GreenButton({required this.label, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green, foregroundColor: Colors.black, elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 32, vertical: compact ? 16 : 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: _labelSize, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _green, side: const BorderSide(color: _green, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: _labelSize, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ),
    );
  }
}

class _HoverLift extends StatefulWidget {
  final Widget child;
  const _HoverLift({required this.child});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        child: widget.child,
      ),
    );
  }
}

enum _PhoneMode { encrypt, messages, ledger }

class _FloatingPhone extends StatelessWidget {
  final _PhoneMode mode;
  final Animation<double> animation;
  const _FloatingPhone({required this.mode, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final y = math.sin(animation.value * math.pi * 2) * 10;
        final rotate = math.sin(animation.value * math.pi * 2) * 0.006;
        return Transform.translate(offset: Offset(0, y), child: Transform.rotate(angle: rotate, child: child));
      },
      child: _PhoneFrame(mode: mode),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  final _PhoneMode mode;
  const _PhoneFrame({required this.mode});

  @override
  Widget build(BuildContext context) {
    const baseWidth = 340.0;
    const baseHeight = 640.0;
    final available = math.max(260.0, MediaQuery.sizeOf(context).width - 56);
    final scale = math.min(1.0, available / baseWidth);
    return SizedBox(
      width: baseWidth * scale,
      height: baseHeight * scale,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: baseWidth,
          height: baseHeight,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: _g(0.22), blurRadius: 80, spreadRadius: 12),
                BoxShadow(color: _g(0.34), blurRadius: 40, offset: const Offset(0, 20)),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(44), border: Border.all(color: _green, width: 2.5)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.96),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    children: [
                      Container(
                        width: 100, height: 18,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black, border: Border.all(color: _g(0.48))),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: _PhoneContent(mode: mode),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneContent extends StatelessWidget {
  final _PhoneMode mode;
  const _PhoneContent({required this.mode});

  @override
  Widget build(BuildContext context) {
    if (mode == _PhoneMode.encrypt) return const _EncryptPhone();
    if (mode == _PhoneMode.messages) return const _MessagesPhone();
    return const _LedgerPhone();
  }
}

class _PhoneHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;
  const _PhoneHeader({required this.icon, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Icon(icon, color: _green, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _smallSize, letterSpacing: 2)),
          const Spacer(),
          Text(trailing, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: _smallSize))
        ]),
        const SizedBox(height: 16),
        Divider(color: _g(0.32), height: 1),
      ],
    );
  }
}

class _EncryptPhone extends StatelessWidget {
  const _EncryptPhone();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PhoneHeader(icon: Icons.enhanced_encryption_outlined, title: 'ENCRYPT', trailing: 'AES'),
        const SizedBox(height: 16),
        const Row(children: [Expanded(child: _PhoneButton(label: 'ENCRYPT', active: true)), SizedBox(width: 8), Expanded(child: _PhoneButton(label: 'DECRYPT', active: false))]),
        const SizedBox(height: 16),
        for (final item in const [['Caesar Cipher', 'SHIFT 13'], ['Transposition', 'KEY ROUTE'], ['Substitution', 'MAP READY'], ['AES-256', 'ACTIVE'], ['RSA', 'PUBLIC KEY']]) _PhoneLine(title: item[0], meta: item[1]),
        const SizedBox(height: 16),
        const _PhoneTerminal(lines: ['ciphertext_output', '7f2a9c10e4bd19a0', 'iv generated, key required']),
      ],
    );
  }
}

class _MessagesPhone extends StatelessWidget {
  const _MessagesPhone();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PhoneHeader(icon: Icons.forum_outlined, title: 'MESSAGES', trailing: ''),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(border: Border.all(color: _g(0.38))), child: const Text('search: alice.gray', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700))),
        const SizedBox(height: 16),
        const _MessageCell(label: 'TO: ALICE', value: 'aGVsbG8gd29ybGQ=', algorithm: 'AES-256'),
        const _MessageCell(label: 'FROM: BOB', value: 'x9F21a...sealed', algorithm: 'RSA'),
        const _MessageCell(label: 'TO: MAYA', value: '0110 1011 0010', algorithm: 'Caesar'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, 
          padding: const EdgeInsets.symmetric(vertical: 14), 
          color: _green, 
          child: const Text('SEND ENCRYPTED', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 11)),
        ),
      ],
    );
  }
}

class _LedgerPhone extends StatelessWidget {
  const _LedgerPhone();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PhoneHeader(icon: Icons.account_tree_outlined, title: 'LEDGER', trailing: 'valid'),
        const SizedBox(height: 16),
        for (int i = 0; i < 4; i++) _BlockCell(index: i),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, 
          padding: const EdgeInsets.symmetric(vertical: 14), 
          decoration: BoxDecoration(border: Border.all(color: _green)), 
          child: const Text('VERIFY CHAIN', textAlign: TextAlign.center, style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 11)),
        ),
      ],
    );
  }
}

class _PhoneButton extends StatelessWidget {
  final String label;
  final bool active;
  const _PhoneButton({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: active ? _green : Colors.transparent, border: Border.all(color: _green)),
      child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.black : _green, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

class _PhoneLine extends StatelessWidget {
  final String title;
  final String meta;
  const _PhoneLine({required this.title, required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: _g(0.30))),
      child: Row(children: [Expanded(child: Text(title, style: const TextStyle(color: _soft, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700))), Text(meta, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10))]),
    );
  }
}

class _PhoneTerminal extends StatelessWidget {
  final List<String> lines;
  const _PhoneTerminal({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _panel, border: Border.all(color: _g(0.34))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final line in lines) Text(line, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10, height: 1.5))]),
    );
  }
}

class _MessageCell extends StatelessWidget {
  final String label;
  final String value;
  final String algorithm;
  const _MessageCell({required this.label, required this.value, required this.algorithm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(color: _panel, border: Border(left: BorderSide(color: _green, width: 3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(label, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w900))), Text(algorithm, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BlockCell extends StatelessWidget {
  final int index;
  const _BlockCell({required this.index});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: _g(0.34))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BLOCK #$index', style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('hash: e0a97164${index}f', style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('prev: c482e01b$index', style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        if (index != 3) Positioned(left: 36, bottom: 0, child: Container(width: 2, height: 14, color: _g(0.55))),
      ],
    );
  }
}

// --- DOCUMENT SCREEN (WORKING LEGAL SCREENS) ---
class _DocumentScreen extends StatelessWidget {
  final String title;
  const _DocumentScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      appBar: AppBar(
        backgroundColor: _black,
        elevation: 0,
        iconTheme: const IconThemeData(color: _green),
        title: Text(title, style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _borderDim, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(title, style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 32.0, fontWeight: FontWeight.w900, height: 1.2)),
          const SizedBox(height: 8),
          const Text('LAST UPDATED: AUGUST 2024', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12.0, letterSpacing: 1)),
          const SizedBox(height: 32),
          _buildSection('1. OVERVIEW', 'CyberEncrypt operates on a zero-knowledge architecture where possible. We collect only the essential information required to provide our services: your username, email address, and profile picture. We do not read, store, or have access to the plaintext of your encrypted messages.'),
          _buildSection('2. DATA COLLECTION', 'Messages are encrypted locally on your device before ever touching our servers. We use JWT for session management. If you choose to sign in with Google, we request only basic profile information via OAuth 2.0. We do not have access to your Google password.'),
          _buildSection('3. BLOCKCHAIN LEDGER', 'Every encrypted message transaction is logged on our tamper-evident blockchain. This ledger contains cryptographic hashes, timestamps, and algorithm metadata. It does NOT contain your plaintext message or your encryption keys.'),
          _buildSection('4. DATA RETENTION', 'Your encrypted messages and blockchain history are retained indefinitely to preserve the integrity of the audit trail. If you request account deletion, your user profile will be removed, but your hashed transaction records will remain on the chain permanently.'),
          _buildSection('5. ACCEPTABLE USE', 'You agree to use CyberEncrypt only for lawful purposes. You may not use this platform to transmit malicious code, illegal content, or to facilitate cyberattacks. Any attempt to reverse engineer the platform to compromise other users is strictly prohibited.'),
        ],
      ),
    );
  }

  Widget _buildSection(String heading, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: _panel,
            border: Border(left: BorderSide(color: _green, width: 3)),
          ),
          child: Text(heading, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 20.0, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 32.0),
          child: Text(body, style: const TextStyle(color: _soft, fontFamily: 'monospace', fontSize: 14.0, height: 1.6)),
        ),
      ],
    );
  }
}

// Backgrounds
class _MatrixBackground extends StatelessWidget {
  final Animation<double> animation;
  const _MatrixBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: animation, builder: (context, _) => CustomPaint(painter: _MatrixPainter(progress: animation.value), child: const SizedBox.expand()));
  }
}

class _MatrixPainter extends CustomPainter {
  final double progress;
  const _MatrixPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = Colors.black);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(center: const Alignment(0.55, -0.15), radius: 0.95, colors: [_green.withValues(alpha: 0.18), const Color(0xFF001808).withValues(alpha: 0.92), Colors.black], stops: const [0.0, 0.44, 1.0]).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black.withValues(alpha: 0.84), Colors.black.withValues(alpha: 0.18), Colors.black.withValues(alpha: 0.74)]).createShader(rect),
    );

    const chars = 'IKHR A0BLCYSE256ENCRYPTAUTHKEYSHA01';
    const columnWidth = 52.0;
    final columns = (size.width / columnWidth).ceil() + 2;
    final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    for (int col = 0; col < columns; col++) {
      final x = col * columnWidth + (col % 2) * 16;
      final speed = 0.40 + (col % 8) * 0.06;
      final start = ((progress * size.height * speed) + col * 73) % (size.height + 360) - 240;
      for (int row = 0; row < 18; row++) {
        final y = start + row * 22;
        if (y < -30 || y > size.height + 30) continue;
        final char = chars[(row * 3 + col * 5) % chars.length];
        final opacity = (0.035 + (row % 7) * 0.018).clamp(0.02, 0.16).toDouble();
        tp.text = TextSpan(text: char, style: TextStyle(color: _green.withValues(alpha: opacity), fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w900));
        tp.layout();
        tp.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter oldDelegate) => oldDelegate.progress != progress;
}

class _CircuitBackground extends StatelessWidget {
  final Animation<double> animation;
  const _CircuitBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: animation, builder: (context, _) => CustomPaint(painter: _CircuitPainter(progress: animation.value), child: const SizedBox.expand()));
  }
}

class _CircuitPainter extends CustomPainter {
  final double progress;
  const _CircuitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = _green.withValues(alpha: 0.12 + progress * 0.07);
    final nodePaint = Paint()..color = _green.withValues(alpha: 0.42 + progress * 0.25);
    final path = Path()
      ..moveTo(size.width * 0.58, size.height * 0.16)
      ..lineTo(size.width * 0.68, size.height * 0.16)
      ..lineTo(size.width * 0.68, size.height * 0.35)
      ..lineTo(size.width * 0.76, size.height * 0.35)
      ..lineTo(size.width * 0.76, size.height * 0.49)
      ..lineTo(size.width * 0.86, size.height * 0.49)
      ..moveTo(size.width * 0.64, size.height * 0.36)
      ..lineTo(size.width * 0.64, size.height * 0.69)
      ..lineTo(size.width * 0.52, size.height * 0.69)
      ..lineTo(size.width * 0.52, size.height * 0.94)
      ..lineTo(size.width * 0.66, size.height * 0.94)
      ..lineTo(size.width * 0.66, size.height * 0.80)
      ..moveTo(size.width * 0.78, size.height * 0.30)
      ..lineTo(size.width * 0.88, size.height * 0.30)
      ..moveTo(size.width * 0.78, size.height * 0.73)
      ..lineTo(size.width * 0.84, size.height * 0.73)
      ..lineTo(size.width * 0.84, size.height * 0.88);
    canvas.drawPath(path, paint);
    for (final point in <Offset>[
      Offset(size.width * 0.15, size.height * 0.27),
      Offset(size.width * 0.32, size.height * 0.42),
      Offset(size.width * 0.43, size.height * 0.64),
      Offset(size.width * 0.69, size.height * 0.77),
      Offset(size.width * 0.80, size.height * 0.77),
      Offset(size.width * 0.90, size.height * 0.92),
    ]) {
      canvas.drawCircle(point, 8 + progress * 4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) => oldDelegate.progress != progress;
}