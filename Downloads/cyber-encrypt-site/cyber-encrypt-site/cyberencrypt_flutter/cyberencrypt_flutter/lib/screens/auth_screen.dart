import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../services/auth_provider.dart';
import '../widgets/matrix_rain.dart';
import 'dashboard_screen.dart';
import 'forgot_password_screen.dart';

// --- CyberEncrypt Design System ---
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _white = Color(0xFFF0FFF3);
const Color _soft = Color(0xFFC9FBD2);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _error = Color(0xFFFF4D4D);

Color _g(double alpha) => _green.withValues(alpha: alpha);

const double _headlineSize = 36.0;
const double _titleSize = 22.0;
const double _bodySize = 14.0;
const double _labelSize = 14.0;
const double _smallSize = 12.0;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  late final AnimationController _flip;
  late final AnimationController _matrix;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _matrix = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _flip.dispose();
    _matrix.dispose();
    super.dispose();
  }

  void _toggleMode(bool toLogin) {
    if (toLogin == _isLogin) return;
    setState(() {
      _error = null;
      _isLogin = toLogin;
    });
    if (toLogin) {
      _flip.reverse();
    } else {
      _flip.forward();
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    try {
      if (_isLogin) {
        await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await auth.signUp(_usernameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final url = Uri.parse(auth.api.googleOAuthUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(_green.withValues(alpha: 0.6)),
          trackColor: WidgetStateProperty.all(Colors.black54),
          radius: const Radius.circular(0),
          thickness: WidgetStateProperty.all(6.0),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
      ),
      child: Scaffold(
        backgroundColor: _black,
        body: Stack(
          children: [
            const Positioned.fill(child: MatrixRain()),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [Colors.black.withValues(alpha: 0.6), Colors.black.withValues(alpha: 0.92)],
                    ),
                  ),
                ),
              ),
            ),
            Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _BrandHeader(),
                        const SizedBox(height: 30),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth > 720;
                            return _AuthCard(
                              wide: wide,
                              flip: _flip,
                              isLogin: _isLogin,
                              loading: _loading,
                              error: _error,
                              emailCtrl: _emailCtrl,
                              passwordCtrl: _passwordCtrl,
                              usernameCtrl: _usernameCtrl,
                              onSubmit: _submit,
                              onGoogle: _continueWithGoogle,
                              onSwitchToLogin: () => _toggleMode(true),
                              onSwitchToSignup: () => _toggleMode(false),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: _green, width: 2),
            boxShadow: [BoxShadow(color: _g(0.4), blurRadius: 20)],
          ),
          child: const Icon(Icons.lock_outline, color: _green, size: 22),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'CYBERENCRYPT',
                style: TextStyle(
                  fontSize: _headlineSize,
                  fontWeight: FontWeight.w900,
                  color: _green,
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Secure messaging with military-grade encryption_',
              style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: _smallSize),
            ),
          ],
        )
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  final bool wide;
  final Animation<double> flip;
  final bool isLogin;
  final bool loading;
  final String? error;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController usernameCtrl;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onSwitchToLogin;
  final VoidCallback onSwitchToSignup;

  const _AuthCard({
    required this.wide,
    required this.flip,
    required this.isLogin,
    required this.loading,
    required this.error,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.usernameCtrl,
    required this.onSubmit,
    required this.onGoogle,
    required this.onSwitchToLogin,
    required this.onSwitchToSignup,
  });

  @override
  Widget build(BuildContext context) {
    final form = _FormPanel(
      isLogin: isLogin,
      loading: loading,
      error: error,
      emailCtrl: emailCtrl,
      passwordCtrl: passwordCtrl,
      usernameCtrl: usernameCtrl,
      onSubmit: onSubmit,
      onGoogle: onGoogle,
      onSwitchMode: isLogin ? onSwitchToSignup : onSwitchToLogin,
    );

    final welcome = _WelcomePanel(isLogin: isLogin, onAction: isLogin ? onSwitchToSignup : onSwitchToLogin);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        border: Border.all(color: _g(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: _g(0.2), blurRadius: 40)],
      ),
      clipBehavior: Clip.antiAlias,
      // Using IntrinsicHeight ensures the box wraps its content exactly,
      // growing or shrinking to fit the form perfectly without scrolling or clipping.
      child: wide
          ? IntrinsicHeight(
              child: AnimatedBuilder(
                animation: flip,
                builder: (context, _) {
                  final angle = flip.value * math.pi;
                  final showBack = flip.value > 0.5;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: form),
                      SizedBox(
                        width: 340,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateY(angle),
                          child: showBack
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(math.pi),
                                  child: welcome,
                                )
                              : welcome,
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                welcome,
                form,
              ],
            ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  final bool isLogin;
  final bool loading;
  final String? error;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController usernameCtrl;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onSwitchMode;

  const _FormPanel({
    required this.isLogin,
    required this.loading,
    required this.error,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.usernameCtrl,
    required this.onSubmit,
    required this.onGoogle,
    required this.onSwitchMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLogin ? 'ACCESS TERMINAL' : 'CREATE ACCOUNT',
            style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _titleSize),
          ),
          const SizedBox(height: 6),
          Text(
            isLogin ? 'Sign in to continue to your account.' : 'Join CyberEncrypt in seconds.',
            style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: _bodySize),
          ),
          const SizedBox(height: 20),
          if (!isLogin) ...[
            const _FieldLabel('USERNAME'),
            _AuthField(controller: usernameCtrl, hint: 'neo_matrix'),
            const SizedBox(height: 12),
          ],
          const _FieldLabel('EMAIL ADDRESS'),
          _AuthField(controller: emailCtrl, hint: 'you@example.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          const _FieldLabel('PASSWORD'),
          _AuthField(controller: passwordCtrl, hint: '********', obscure: true),
          
          if (isLogin) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: _soft,
                    fontFamily: 'monospace',
                    fontSize: _smallSize,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          if (error != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _error.withValues(alpha: 0.1),
                border: const Border(left: BorderSide(color: _error, width: 3)),
              ),
              child: Text('⚠ $error', style: const TextStyle(color: _error, fontFamily: 'monospace', fontSize: _smallSize, height: 1.4)),
            ),
          _CyberButton(
            label: loading ? '⏳ PROCESSING...' : (isLogin ? 'EXECUTE SIGN IN' : 'CREATE ACCOUNT'),
            onTap: loading ? null : onSubmit,
            primary: true,
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Divider(color: _g(0.2), height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('OR', style: TextStyle(color: _g(0.4), fontFamily: 'monospace', fontSize: 10)),
            ),
            Expanded(child: Divider(color: _g(0.2), height: 1)),
          ]),
          const SizedBox(height: 14),
          _CyberButton(
            label: 'CONTINUE WITH GOOGLE',
            onTap: onGoogle,
            primary: false,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onSwitchMode,
              child: Text(
                isLogin ? "New here? Create account →" : 'Already have an account? Sign in →',
                style: const TextStyle(color: _soft, fontFamily: 'monospace', fontSize: _smallSize, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;

  const _AuthField({required this.controller, this.hint, this.obscure = false, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: _bodySize),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _g(0.35), fontFamily: 'monospace'),
        filled: true,
        fillColor: _panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _g(0.3), width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _g(0.3), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: _green, width: 1.5)),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onAction;

  const _WelcomePanel({required this.isLogin, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(left: BorderSide(color: _green, width: 2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _g(0.1),
              border: Border.all(color: _green, width: 2),
              boxShadow: [BoxShadow(color: _g(0.3), blurRadius: 20)],
            ),
            child: Icon(isLogin ? Icons.terminal_outlined : Icons.person_add_alt_1, color: _green, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            isLogin ? 'ACCESS_TERMINAL' : 'IDENTITY_REQUIRED',
            style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _titleSize, height: 1.1),
          ),
          const SizedBox(height: 10),
          Text(
            isLogin
                ? 'Create your account and start sending encrypted, blockchain-logged messages in seconds.'
                : 'Sign back in to pick up where you left off — your keys and history are waiting.',
            style: const TextStyle(color: _soft, fontFamily: 'monospace', fontSize: _labelSize, height: 1.6),
          ),
          const SizedBox(height: 24), // Replaced Spacer with fixed SizedBox
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _green, width: 1.5),
              foregroundColor: _green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(isLogin ? 'CREATE ACCOUNT' : 'SIGN IN', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _labelSize, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: _smallSize, letterSpacing: 2)),
      );
}

class _CyberButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  const _CyberButton({required this.label, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, 0, 0),
        child: primary
            ? ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _labelSize, letterSpacing: 1.5)),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(color: _green, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: _labelSize, letterSpacing: 1.5)),
              ),
      ),
    );
  }
}