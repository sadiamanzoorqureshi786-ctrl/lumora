import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import ApiService directly
import '../widgets/matrix_rain.dart';

// Re-using colors from main theme for consistency
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _white = Color(0xFFF0FFF3);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _error = Color(0xFFFF4D4D);

Color _g(double alpha) => _green.withValues(alpha: alpha);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _isError = false;

  Future<void> _sendResetLink() async {
    setState(() {
      _loading = true;
      _message = null;
      _isError = false;
    });

    try {
      // Call ApiService directly since no auth token is needed
      final api = ApiService();
      await api.sendPasswordResetEmail(_emailCtrl.text.trim());
      
      setState(() {
        _message = "If an account exists for that email, a reset link has been sent.";
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('ApiException: ', '');
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: MatrixRain()),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: _panel,
                  border: Border.all(color: _g(0.5), width: 1.5),
                  boxShadow: [BoxShadow(color: _g(0.2), blurRadius: 40)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RECOVERY_MODE',
                      style: TextStyle(
                        color: _green,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter your registered email address. We will send you a secure link to reset your password.',
                      style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'EMAIL ADDRESS',
                      style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        hintStyle: TextStyle(color: _g(0.35), fontFamily: 'monospace'),
                        filled: true,
                        fillColor: _black,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _g(0.3), width: 1)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _g(0.3), width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: _green, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_message != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: (_isError ? _error : _green).withValues(alpha: 0.1),
                          border: Border(left: BorderSide(color: _isError ? _error : _green, width: 3)),
                        ),
                        child: Text(
                          _message!,
                          style: TextStyle(color: _isError ? _error : _green, fontFamily: 'monospace', fontSize: 12, height: 1.5),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _sendResetLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          _loading ? '⏳ TRANSMITTING...' : 'SEND RESET LINK',
                          style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5),
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