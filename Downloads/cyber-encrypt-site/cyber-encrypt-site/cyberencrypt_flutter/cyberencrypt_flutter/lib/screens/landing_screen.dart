import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'landingpage_b.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _openAuth(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CyberEncryptLandingB(
      onGetStarted: () => _openAuth(context),
      onSignIn: () => _openAuth(context),
    );
  }
}