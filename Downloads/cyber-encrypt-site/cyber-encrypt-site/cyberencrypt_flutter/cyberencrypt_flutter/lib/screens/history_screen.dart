import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

// --- CyberEncrypt Design System ---
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _soft = Color(0xFFC9FBD2);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _borderDim = Color(0xFF143D20);

Color _g(double alpha) => _green.withValues(alpha: alpha);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _logs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<AuthProvider>().api;
      final logs = await api.getHistory();
      if (mounted) setState(() => _logs = logs);
    } catch (_) {
      if (mounted) setState(() => _error = 'Failed to load activity log.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'UNKNOWN TIME';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
             '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'INVALID DATE';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _green, strokeWidth: 2));
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      color: _green,
      backgroundColor: _black,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _panel,
              border: Border.all(color: _borderDim, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_outlined, color: _green, size: 18),
                    SizedBox(width: 10),
                    Text('ACTIVITY LOG', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
                  ],
                ),
                const Divider(color: _borderDim, height: 24),
                const Text(
                  'Combined log of sent and received encrypted messages',
                  style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      border: const Border(left: BorderSide(color: Colors.red, width: 3)),
                    ),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontFamily: 'monospace', fontSize: 12)),
                  )
                else if (_logs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('NO ACTIVITY LOGGED', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12, letterSpacing: 1))),
                  )
                else
                  for (final log in _logs) _HistoryTile(log: log, formatDate: _formatDate),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> log;
  final String Function(String?) formatDate;

  const _HistoryTile({required this.log, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final isSent = log['type'] == 'sent';
    final algorithm = log['algorithm']?.toString().toUpperCase() ?? 'N/A';
    final dateStr = formatDate(log['createdAt']);
    final user = isSent ? log['recipient'] : log['sender'];
    final encryptedText = log['encryptedText'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border.all(color: _g(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSent ? _g(0.1) : Colors.transparent,
                  border: Border.all(color: isSent ? _green : _borderDim, width: 1),
                ),
                child: Text(
                  isSent ? 'SENT' : 'RECEIVED', 
                  style: TextStyle(color: isSent ? _green : _muted, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _panel,
                  border: Border.all(color: _borderDim),
                ),
                child: Text(algorithm, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text(dateStr, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${isSent ? "TO" : "FROM"}: ${user?.toString().toUpperCase() ?? 'UNKNOWN'}',
            style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: _panel,
              border: Border(left: BorderSide(color: _muted, width: 2)),
            ),
            child: SelectableText(
              encryptedText, 
              style: const TextStyle(color: _soft, fontFamily: 'monospace', fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}