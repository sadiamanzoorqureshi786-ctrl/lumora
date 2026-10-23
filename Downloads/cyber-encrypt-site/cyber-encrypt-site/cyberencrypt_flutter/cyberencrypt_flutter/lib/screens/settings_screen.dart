import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_provider.dart';
import '../widgets/user_avatar.dart';

// --- CyberEncrypt Design System ---
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _white = Color(0xFFF0FFF3);
const Color _soft = Color(0xFFC9FBD2);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _borderDim = Color(0xFF143D20);
const Color _error = Color(0xFFFF4D4D);

Color _g(double alpha) => _green.withValues(alpha: alpha);

class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool>? onMatrixToggle;
  final bool initialMatrixEnabled;

  const SettingsScreen({
    super.key, 
    this.onMatrixToggle,
    this.initialMatrixEnabled = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  
  bool _pwLoading = false;
  bool _picLoading = false;
  String? _pwMessage;
  bool _pwSuccess = false;

  // Preferences State
  bool _notifications = true;
  bool _onlineStatus = true;
  bool _readReceipts = true;
  late bool _matrixRain;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _notifications = user.notificationsEnabled;
      _onlineStatus = user.onlineStatusEnabled;
      _readReceipts = user.readReceiptsEnabled;
    }
    _matrixRain = widget.initialMatrixEnabled;
  }

  Future<void> _pickImage(ImageSource source) async {
    final auth = context.read<AuthProvider>();
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile == null) return;

      setState(() => _picLoading = true);
      
      // Pass XFile directly - works on Web, Mobile, and Desktop
      final data = await auth.api.uploadProfilePic(pickedFile);
      auth.updateLocalUser(AppUser.fromJson(data));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully'), backgroundColor: _panel),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('ApiException: ', '')), backgroundColor: _error),
        );
      }
    } finally {
      if (mounted) setState(() => _picLoading = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        side: BorderSide(color: _borderDim, width: 1.5),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: _green),
                title: const Text('TAKE PHOTO', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: _green),
                title: const Text('CHOOSE FROM GALLERY', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changePassword() async {
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      setState(() { _pwMessage = 'Passwords do not match'; _pwSuccess = false; });
      return;
    }
    if (_newPwCtrl.text.length < 6) {
      setState(() { _pwMessage = 'Password must be 6+ characters'; _pwSuccess = false; });
      return;
    }

    setState(() { _pwLoading = true; _pwMessage = null; });
    try {
      final api = context.read<AuthProvider>().api;
      await api.changePassword(_currentPwCtrl.text, _newPwCtrl.text);
      setState(() {
        _pwMessage = 'Password updated successfully!';
        _pwSuccess = true;
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
      });
    } catch (e) {
      setState(() {
        _pwMessage = e.toString().replaceFirst('ApiException: ', '');
        _pwSuccess = false;
      });
    } finally {
      if (mounted) setState(() => _pwLoading = false);
    }
  }

  Future<void> _updatePreference(String key, bool value) async {
    setState(() {
      if (key == 'notifications') _notifications = value;
      if (key == 'online') _onlineStatus = value;
      if (key == 'read') _readReceipts = value;
    });

    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.updatePreferences(
        notificationsEnabled: _notifications,
        onlineStatusEnabled: _onlineStatus,
        readReceiptsEnabled: _readReceipts,
      );
      auth.updateLocalUser(AppUser.fromJson(data));
    } catch (e) {
      // Revert on failure
      setState(() {
        if (key == 'notifications') _notifications = !value;
        if (key == 'online') _onlineStatus = !value;
        if (key == 'read') _readReceipts = !value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update preference'), backgroundColor: _error),
        );
      }
    }
  }

  void _toggleMatrix(bool value) {
    setState(() => _matrixRain = value);
    widget.onMatrixToggle?.call(value);
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- PROFILE SECTION ---
        _buildSectionCard(
          title: 'ACCOUNT INFORMATION',
          icon: Icons.person_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      UserAvatar(imageUrl: user?.profilePic, fallbackInitial: user?.initial ?? 'U', size: 72),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _green,
                            border: Border.all(color: _black, width: 2),
                          ),
                          child: _picLoading 
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: _black, strokeWidth: 2))
                            : const Icon(Icons.edit, color: _black, size: 14),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.username.toUpperCase() ?? '', style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '', style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _picLoading ? null : _showImageSourceSheet,
                icon: const Icon(Icons.upload_outlined, color: _green, size: 18),
                label: const Text('CHANGE PROFILE PICTURE', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _borderDim, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- APPEARANCE SECTION ---
        _buildSectionCard(
          title: 'APPEARANCE',
          icon: Icons.visibility_outlined,
          child: Column(
            children: [
              _buildToggleTile(
                icon: Icons.blur_on_outlined,
                title: 'MATRIX BACKGROUND',
                subtitle: 'Toggle the animated matrix rain effect',
                value: _matrixRain,
                onChanged: _toggleMatrix,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- PREFERENCES SECTION ---
        _buildSectionCard(
          title: 'SYSTEM PREFERENCES',
          icon: Icons.tune_outlined,
          child: Column(
            children: [
              _buildToggleTile(
                icon: Icons.notifications_outlined,
                title: 'NOTIFICATIONS',
                subtitle: 'Receive alerts for new messages',
                value: _notifications,
                onChanged: (v) => _updatePreference('notifications', v),
              ),
              const Divider(color: _borderDim, height: 1),
              _buildToggleTile(
                icon: Icons.wifi_tethering,
                title: 'ONLINE STATUS',
                subtitle: 'Show when you are active',
                value: _onlineStatus,
                onChanged: (v) => _updatePreference('online', v),
              ),
              const Divider(color: _borderDim, height: 1),
              _buildToggleTile(
                icon: Icons.done_all_outlined,
                title: 'READ RECEIPTS',
                subtitle: 'Send confirmation when you read messages',
                value: _readReceipts,
                onChanged: (v) => _updatePreference('read', v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- SECURITY SECTION ---
        _buildSectionCard(
          title: 'SECURITY SETTINGS',
          icon: Icons.lock_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_pwMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_pwSuccess ? _green : _error).withValues(alpha: 0.1),
                    border: Border(left: BorderSide(color: _pwSuccess ? _green : _error, width: 3)),
                  ),
                  child: Text(_pwMessage!, style: TextStyle(color: _pwSuccess ? _green : _error, fontFamily: 'monospace', fontSize: 12)),
                ),
              _buildPasswordField(_currentPwCtrl, 'CURRENT PASSWORD'),
              const SizedBox(height: 16),
              _buildPasswordField(_newPwCtrl, 'NEW PASSWORD'),
              const SizedBox(height: 16),
              _buildPasswordField(_confirmPwCtrl, 'CONFIRM PASSWORD'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _pwLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: _black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: _pwLoading 
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: _black, strokeWidth: 2))
                  : const Text('UPDATE PASSWORD', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- APP INFO SECTION ---
        _buildSectionCard(
          title: 'APPLICATION',
          icon: Icons.info_outline,
          child: Column(
            children: [
              _buildInfoTile(label: 'VERSION', value: '1.0.0'),
              const Divider(color: _borderDim, height: 1),
              _buildInfoTile(label: 'STATUS', value: 'ONLINE'),
              const Divider(color: _borderDim, height: 1),
              _buildInfoTile(label: 'NETWORK', value: 'MAINNET'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- LOGOUT SECTION ---
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.power_settings_new, color: _black, size: 20),
          label: const Text('TERMINATE SESSION', style: TextStyle(color: _black, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _error,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panel,
        border: Border.all(color: _borderDim, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _green, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5),
              ),
            ],
          ),
          const Divider(color: _borderDim, height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: _soft, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _green,
            activeTrackColor: _g(0.3),
            inactiveThumbColor: _muted,
            inactiveTrackColor: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text(value, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 11, letterSpacing: 1),
        filled: true,
        fillColor: _black,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _borderDim, width: 1)),
        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _borderDim, width: 1)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _green, width: 1.5)),
      ),
    );
  }
}