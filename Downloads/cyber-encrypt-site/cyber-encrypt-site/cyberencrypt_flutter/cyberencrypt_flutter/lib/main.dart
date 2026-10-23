import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- ADDED to detect web
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'theme/matrix_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const CyberEncryptApp());
}

class CyberEncryptApp extends StatelessWidget {
  const CyberEncryptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..init(),
      child: MaterialApp(
        title: 'CyberEncrypt',
        debugShowCheckedModeBanner: false,
        theme: MatrixTheme.theme,
        home: const _RootGate(),
      ),
    );
  }
}

/// Flow: 
/// - Web: Goes directly to Auth check -> Dashboard or Landing page.
/// - Mobile: Shows Splash (boot animation) -> Auth check -> Dashboard or Landing page.
class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    // Bypass the mobile splash screen entirely if running on Web
    if (kIsWeb) {
      _splashDone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!_splashDone) {
      return SplashScreen(onDone: () => setState(() => _splashDone = true));
    }

    if (auth.loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: MatrixColors.green, strokeWidth: 2),
        ),
      );
    }

    return auth.isAuthenticated ? const DashboardScreen() : const LandingScreen();
  }
}