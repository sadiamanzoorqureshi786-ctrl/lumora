import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

Color _g(double alpha) => _green.withValues(alpha: alpha);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<dynamic> _users = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final users = await auth.api.getAllUsers();
      setState(() => _users = users);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search(String q) async {
    if (q.length < 2) {
      _fetchAllUsers();
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final results = await auth.api.searchUsers(q);
      setState(() => _users = results);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.user;
    final filtered = _users.where((u) => u['_id'] != me?.id).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- USER IDENTITY CARD ---
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _panel,
            border: Border.all(color: _borderDim, width: 1.5),
            boxShadow: [BoxShadow(color: _g(0.05), blurRadius: 20)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _black,
                  border: Border.all(color: _green, width: 2),
                  boxShadow: [BoxShadow(color: _g(0.4), blurRadius: 16)],
                ),
                child: UserAvatar(imageUrl: me?.profilePic, fallbackInitial: me?.initial ?? 'U', size: 72),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (me?.username ?? 'OPERATOR').toUpperCase(),
                      style: const TextStyle(
                        color: _green,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      me?.email ?? 'N/A',
                      style: const TextStyle(
                        color: _muted,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _g(0.1),
                        border: Border.all(color: _green, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: _green, size: 6),
                          SizedBox(width: 6),
                          Text(
                            'STATUS: ONLINE',
                            style: TextStyle(
                              color: _green,
                              fontFamily: 'monospace',
                              fontSize: 9.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // --- NETWORK DIRECTORY ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _panel,
            border: Border.all(color: _borderDim, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.people_outline, color: _green, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'NETWORK DIRECTORY',
                    style: TextStyle(
                      color: _green,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Browse connected nodes to initiate secure messaging',
                style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 11),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchCtrl,
                onChanged: _search,
                style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                cursorColor: _green,
                decoration: const InputDecoration(
                  hintText: 'SEARCH NODES BY NAME',
                  hintStyle: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12, letterSpacing: 1),
                  filled: true,
                  fillColor: _black,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _borderDim, width: 1)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _borderDim, width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _green, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: _green, strokeWidth: 2)),
                )
              else if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'NO NODES FOUND',
                      style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final u = filtered[i];
                    return _UserCard(
                      username: u['username'] ?? 'UNKNOWN',
                      profilePic: u['profilePic'],
                      onSendMessage: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigate to Messages tab to contact ${u['username']}'),
                            backgroundColor: _panel,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final String username;
  final String? profilePic;
  final VoidCallback onSendMessage;

  const _UserCard({
    required this.username,
    required this.profilePic,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border.all(color: _g(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _borderDim, width: 1),
            ),
            child: UserAvatar(
              imageUrl: profilePic,
              fallbackInitial: username.isNotEmpty ? username[0].toUpperCase() : 'U',
              size: 64,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            username.toUpperCase(),
            style: const TextStyle(
              color: _soft,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onSendMessage,
            icon: const Icon(Icons.send_outlined, color: _green, size: 14),
            label: const Text(
              'CONNECT',
              style: TextStyle(
                color: _green,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _borderDim, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
        ],
      ),
    );
  }
}