import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_provider.dart';
import '../widgets/matrix_rain.dart';
import '../widgets/user_avatar.dart';
import 'blockchain_screen.dart';
import 'encryption_screen.dart';
import 'history_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CyberEncrypt Design System (Strict Terminal Theme)
// ─────────────────────────────────────────────────────────────────────────────

const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _white = Color(0xFFF0FFF3);
const Color _soft = Color(0xFFC9FBD2);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _borderDim = Color(0xFF143D20);
const Color _error = Color(0xFFFF4D4D);

Color _g(double alpha) => _green.withValues(alpha: alpha);

const List<_NavigationItem> _navigationItems = [
  _NavigationItem(
    id: 'encryption',
    label: 'Encrypt',
    command: 'ENCRYPTION_TOOL',
    icon: Icons.enhanced_encryption_outlined,
  ),
  _NavigationItem(
    id: 'messages',
    label: 'Messages',
    command: 'SECURE_MESSAGES',
    icon: Icons.forum_outlined,
  ),
  _NavigationItem(
    id: 'history',
    label: 'History',
    command: 'ACTIVITY_LOG',
    icon: Icons.history_outlined,
  ),
  _NavigationItem(
    id: 'blockchain',
    label: 'Ledger',
    command: 'BLOCKCHAIN_LEDGER',
    icon: Icons.account_tree_outlined,
  ),
  _NavigationItem(
    id: 'profile',
    label: 'Profile',
    command: 'USER_PROFILE',
    icon: Icons.person_outline,
  ),
  _NavigationItem(
    id: 'settings',
    label: 'Config',
    command: 'SYSTEM_CONFIG',
    icon: Icons.settings_outlined,
  ),
];

class _NavigationItem {
  final String id;
  final String label;
  final String command;
  final IconData icon;

  const _NavigationItem({
    required this.id,
    required this.label,
    required this.command,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentPage = 'encryption';
  bool _matrixEnabled = true;

  _NavigationItem get _activeItem {
    return _navigationItems.firstWhere(
      (item) => item.id == _currentPage,
      orElse: () => _navigationItems.first,
    );
  }

  void _selectPage(String id) {
    if (_currentPage == id) return;
    setState(() => _currentPage = id);
  }

  void _toggleMatrix(bool enabled) {
    setState(() => _matrixEnabled = enabled);
  }

  Widget _renderPage() {
    switch (_currentPage) {
      case 'messages':
        return const MessagesScreen();
      case 'history':
        return const HistoryScreen();
      case 'blockchain':
        return const BlockchainScreen();
      case 'profile':
        return const ProfileScreen();
      case 'settings':
        return const SettingsScreen();
      case 'encryption':
      default:
        return const EncryptionScreen();
    }
  }

  Future<void> _confirmLogout(AuthProvider auth) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _panel,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: _borderDim, width: 1.5),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: const Row(
            children: [
              Icon(Icons.power_settings_new, color: _error, size: 24),
              SizedBox(width: 14),
              Text(
                'TERMINATE_SESSION?',
                style: TextStyle(
                  color: _green,
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          content: const Text(
            '> You will be signed out of the secure console. Any unsaved work may be lost.',
            style: TextStyle(
              color: _soft,
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: _muted,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: _borderDim),
                ),
              ),
              child: const Text('ABORT', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _error,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('EXECUTE_LOGOUT', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      await auth.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: _black,
      body: Stack(
        children: [
          // Base background
          const Positioned.fill(
            child: ColoredBox(color: _black),
          ),

          // Matrix rain (Visible when enabled)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _matrixEnabled ? 1.0 : 0.0, // Fully visible when ON
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: const MatrixRain(),
              ),
            ),
          ),

          // Dark Overlay - Fixed opacity logic
          // When ON: Lower opacity so rain shows through clearly.
          // When OFF: 100% solid opacity to hide everything behind it.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                color: _matrixEnabled
                    ? Colors.black.withValues(alpha: 0.75) // Translucent when ON
                    : _black, // Completely solid when OFF
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. HEADER
                _DashboardHeader(
                  activeItem: _activeItem,
                  user: user,
                  matrixEnabled: _matrixEnabled,
                  onMatrixChanged: _toggleMatrix,
                  onNavigate: _selectPage,
                  onLogout: () => _confirmLogout(auth),
                ),

                // 2. MAIN CONTENT AREA
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final horizontalPadding = width < 600 ? 12.0 : width < 1100 ? 20.0 : 28.0;
                      final verticalPadding = width < 600 ? 12.0 : 22.0;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          verticalPadding,
                          horizontalPadding,
                          verticalPadding,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1500),
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 260),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  final slideAnimation = Tween<Offset>(
                                    begin: const Offset(0.015, 0),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: slideAnimation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey(_currentPage),
                                  child: _renderPage(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 3. NAVIGATION BAR (Cyberpunk Command Footer)
                _BottomCommandBar(
                  currentPage: _currentPage,
                  onSelect: _selectPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Header
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final _NavigationItem activeItem;
  final dynamic user;
  final bool matrixEnabled;
  final ValueChanged<bool> onMatrixChanged;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const _DashboardHeader({
    required this.activeItem,
    required this.user,
    required this.matrixEnabled,
    required this.onMatrixChanged,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: _borderDim, width: 1.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final showMatrixLabel = width >= 660;
          final showUsername = width >= 800;

          return Row(
            children: [
              const _ApplicationBrand(),
              if (width >= 500) ...[
                const SizedBox(width: 16),
                const SizedBox(
                  width: 1,
                  height: 28,
                  child: ColoredBox(color: _borderDim),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '> ${activeItem.command}',
                        style: const TextStyle(
                          color: _green,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Row(
                        children: [
                          Icon(Icons.circle, color: _green, size: 6),
                          SizedBox(width: 6),
                          Text(
                            'STATUS: ONLINE',
                            style: TextStyle(
                              color: _muted,
                              fontFamily: 'monospace',
                              fontSize: 9.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else
                const Spacer(),
              _MatrixToggle(
                enabled: matrixEnabled,
                showLabel: showMatrixLabel,
                onChanged: onMatrixChanged,
              ),
              const SizedBox(width: 12),
              if (user != null)
                _UserMenu(
                  user: user,
                  showUsername: showUsername,
                  onNavigate: onNavigate,
                  onLogout: onLogout,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ApplicationBrand extends StatelessWidget {
  const _ApplicationBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: _green, width: 1.5),
            boxShadow: [BoxShadow(color: _g(0.3), blurRadius: 12)],
          ),
          child: const Icon(Icons.lock_outline, color: _green, size: 20),
        ),
        const SizedBox(width: 12),
        const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'CYBER', style: TextStyle(color: _green)),
                  TextSpan(text: 'ENCRYPT', style: TextStyle(color: _white)),
                ],
              ),
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'SECURE_CONSOLE',
              style: TextStyle(
                color: _muted,
                fontFamily: 'monospace',
                fontSize: 8.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatrixToggle extends StatelessWidget {
  final bool enabled;
  final bool showLabel;
  final ValueChanged<bool> onChanged;

  const _MatrixToggle({
    required this.enabled,
    required this.showLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: enabled ? 'Disable Matrix rain' : 'Enable Matrix rain',
      child: InkWell(
        onTap: () => onChanged(!enabled),
        child: Container(
          height: 36,
          padding: EdgeInsets.only(left: showLabel ? 12 : 8, right: 8),
          decoration: BoxDecoration(
            color: _panel,
            border: Border.all(color: enabled ? _green : _borderDim, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLabel) ...[
                Icon(Icons.blur_on_rounded, size: 16, color: enabled ? _green : _muted),
                const SizedBox(width: 8),
                Text(
                  'MATRIX_FX',
                  style: TextStyle(
                    color: enabled ? _soft : _muted,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: enabled ? _green : Colors.black,
                  border: Border.all(color: enabled ? _green : _muted, width: 1),
                  boxShadow: enabled ? [BoxShadow(color: _g(0.8), blurRadius: 6)] : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cyberpunk Bottom Command Bar (Footer)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomCommandBar extends StatelessWidget {
  final String currentPage;
  final ValueChanged<String> onSelect;

  const _BottomCommandBar({
    required this.currentPage,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.black,
        border: const Border(top: BorderSide(color: _borderDim, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200), 
          child: Row(
            children: _navigationItems.map((item) {
              final isActive = currentPage == item.id;
              return _BottomCommandTile(
                item: item,
                isActive: isActive,
                onTap: () => onSelect(item.id),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _BottomCommandTile extends StatelessWidget {
  final _NavigationItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomCommandTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: Colors.transparent,
          splashColor: _g(0.05),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isActive ? _green : Colors.transparent,
                  width: 2,
                ),
              ),
              color: isActive ? _g(0.08) : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isActive ? _green : _muted,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label.toUpperCase(),
                  style: TextStyle(
                    color: isActive ? _green : _muted,
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Menu
// ─────────────────────────────────────────────────────────────────────────────

enum _UserAction { profile, settings, logout }

class _UserMenu extends StatelessWidget {
  final dynamic user;
  final bool showUsername;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const _UserMenu({
    required this.user,
    required this.showUsername,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final username = (user?.username ?? 'Operator').toString();
    final fallbackInitial = (user?.initial ?? 
      (username.isNotEmpty ? username.substring(0, 1) : 'U')).toString().toUpperCase();

    final String? validProfilePic = 
        (user?.profilePic != null && user!.profilePic.toString().isNotEmpty) 
            ? user!.profilePic 
            : null;

    return PopupMenuButton<_UserAction>(
      tooltip: 'Account menu',
      color: _panel,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      offset: const Offset(0, 10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: _borderDim, width: 1.5),
      ),
      onSelected: (action) {
        switch (action) {
          case _UserAction.profile: onNavigate('profile'); break;
          case _UserAction.settings: onNavigate('settings'); break;
          case _UserAction.logout: onLogout(); break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<_UserAction>(
          value: _UserAction.profile,
          height: 44,
          child: _PopupMenuRow(icon: Icons.person_outline, label: 'VIEW_PROFILE'),
        ),
        PopupMenuItem<_UserAction>(
          value: _UserAction.settings,
          height: 44,
          child: _PopupMenuRow(icon: Icons.settings_outlined, label: 'SYSTEM_CONFIG'),
        ),
        PopupMenuDivider(height: 1),
        PopupMenuItem<_UserAction>(
          value: _UserAction.logout,
          height: 44,
          child: _PopupMenuRow(icon: Icons.power_settings_new, label: 'TERMINATE_SESSION', danger: true),
        ),
      ],
      child: Container(
        height: 36,
        padding: EdgeInsets.fromLTRB(4, 4, showUsername ? 12 : 4, 4),
        decoration: BoxDecoration(
          color: _panel,
          border: Border.all(color: _borderDim, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(
              imageUrl: validProfilePic,
              fallbackInitial: fallbackInitial,
              size: 28,
            ),
            if (showUsername) ...[
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  username.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _soft,
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more_rounded, color: _muted, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _PopupMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;

  const _PopupMenuRow({required this.icon, required this.label, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? _error : _green;
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: color, 
            fontFamily: 'monospace', 
            fontSize: 12, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}