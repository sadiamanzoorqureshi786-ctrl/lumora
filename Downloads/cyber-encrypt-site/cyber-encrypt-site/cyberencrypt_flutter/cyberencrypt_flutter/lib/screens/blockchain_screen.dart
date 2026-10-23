import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

// --- CyberEncrypt Design System (Terminal Theme) ---
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _soft = Color(0xFFC9FBD2);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _borderDim = Color(0xFF143D20);
const Color _error = Color(0xFFFF4D4D);

Color _g(double alpha) => _green.withValues(alpha: alpha);

class BlockchainScreen extends StatefulWidget {
  const BlockchainScreen({super.key});

  @override
  State<BlockchainScreen> createState() => _BlockchainScreenState();
}

class _BlockchainScreenState extends State<BlockchainScreen> {
  List<dynamic> _blocks = [];
  bool _loading = true;
  bool _verifying = false;
  bool? _isChainValid;
  String? _verificationMessage;

  @override
  void initState() {
    super.initState();
    _fetchChain();
  }

  Future<void> _fetchChain() async {
    setState(() {
      _loading = true;
      _isChainValid = null;
      _verificationMessage = null;
    });
    
    try {
      final api = context.read<AuthProvider>().api;
      final data = await api.getChain();
      
      if (mounted) {
        setState(() {
          _blocks = (data['chain'] as List<dynamic>?) ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to Blockchain network'),
            backgroundColor: _error,
          ),
        );
      }
    }
  }

  Future<void> _verifyChain() async {
    setState(() => _verifying = true);
    
    try {
      final api = context.read<AuthProvider>().api;
      final res = await api.verifyChain();
      
      if (mounted) {
        setState(() {
          _isChainValid = res['valid'] ?? false;
          _verificationMessage = res['message'] ?? 'Verification complete';
          _verifying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _isChainValid = false;
          _verificationMessage = 'Error reaching consensus network';
        });
      }
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'UNKNOWN TIME';
    try {
      int ms = timestamp is int ? timestamp : int.parse(timestamp.toString());
      final date = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
             '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp.toString();
    }
  }

  String _truncateHash(String? hash) {
    if (hash == null || hash.isEmpty) return '0x000...000';
    if (hash.length <= 12) return hash;
    return '${hash.substring(0, 6)}...${hash.substring(hash.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _green, strokeWidth: 2));
    }

    if (_blocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off, color: _muted, size: 48),
            const SizedBox(height: 16),
            const Text('LEDGER EMPTY', style: TextStyle(color: _green, fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('No blocks have been mined yet.', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12)),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _fetchChain,
              style: OutlinedButton.styleFrom(foregroundColor: _green, side: const BorderSide(color: _green)),
              child: const Text('REFRESH LEDGER', style: TextStyle(fontFamily: 'monospace')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchChain,
      color: _green,
      backgroundColor: _black,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSystemStatus(),
          const SizedBox(height: 24),
          for (int i = 0; i < _blocks.length; i++) 
            _BlockTimelineItem(
              block: _blocks[i] as Map<String, dynamic>, 
              isFirst: i == 0,
              isLast: i == _blocks.length - 1,
              formatTimestamp: _formatTimestamp,
              truncateHash: _truncateHash,
            ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panel,
        border: Border.all(color: _borderDim, width: 1.5),
        boxShadow: [BoxShadow(color: _g(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEDGER OVERVIEW',
                    style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tamper-evident message log',
                    style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 11),
                  ),
                ],
              ),
              if (_isChainValid != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isChainValid! ? _g(0.1) : _error.withValues(alpha: 0.1),
                    border: Border.all(color: _isChainValid! ? _green : _error, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: _isChainValid! ? _green : _error, size: 8),
                      const SizedBox(width: 6),
                      Text(
                        _isChainValid! ? 'CHAIN VALID' : 'CHAIN INVALID',
                        style: TextStyle(color: _isChainValid! ? _green : _error, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _borderDim, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: _muted, size: 8),
                      SizedBox(width: 6),
                      Text('AWAITING AUDIT', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
            ],
          ),
          if (_verificationMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _verificationMessage!.toUpperCase(),
              style: TextStyle(color: _isChainValid == true ? _muted : _error, fontFamily: 'monospace', fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatTile(label: 'TOTAL BLOCKS', value: _blocks.length.toString())),
              Container(width: 1, height: 30, color: _borderDim),
              const Expanded(child: _StatTile(label: 'DIFFICULTY', value: '02')),
              Container(width: 1, height: 30, color: _borderDim),
              const Expanded(child: _StatTile(label: 'ALGORITHM', value: 'SHA-256')),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _verifying ? null : _verifyChain,
              icon: _verifying 
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: _black, strokeWidth: 2)) 
                : const Icon(Icons.security_outlined, color: _black, size: 16),
              label: Text(
                _verifying ? 'VERIFYING...' : 'VERIFY INTEGRITY',
                style: const TextStyle(color: _black, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _BlockTimelineItem extends StatelessWidget {
  final Map<String, dynamic> block;
  final bool isFirst;
  final bool isLast;
  final String Function(dynamic) formatTimestamp;
  final String Function(String?) truncateHash;

  const _BlockTimelineItem({
    required this.block,
    required this.isFirst,
    required this.isLast,
    required this.formatTimestamp,
    required this.truncateHash,
  });

  @override
  Widget build(BuildContext context) {
    final index = block['index'] ?? 0;
    final isGenesis = index == 0;
    final timestamp = formatTimestamp(block['timestamp']);
    final hash = block['hash'] ?? '';
    final prevHash = block['previousHash'] ?? '0';
    final nonce = block['nonce'] ?? 0;
    final data = block['data'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Column
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _black,
                  shape: BoxShape.circle,
                  border: Border.all(color: _green, width: 2),
                  boxShadow: [BoxShadow(color: _g(0.4), blurRadius: 8)],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 160, // Connects to the next block
                  color: _borderDim,
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // Block Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              border: Border.all(color: _g(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _g(0.05),
                    border: const Border(bottom: BorderSide(color: _borderDim, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(isGenesis ? Icons.star_outline : Icons.view_in_ar_outlined, color: _green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'BLOCK #${index.toString().padLeft(3, '0')}',
                            style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                          if (isGenesis) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              color: _panel,
                              child: const Text('GENESIS', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ]
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: _muted, size: 12),
                          const SizedBox(width: 4),
                          Text(timestamp, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Body
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHashRow('HASH', truncateHash(hash), true),
                      const SizedBox(height: 6),
                      _buildHashRow('PREV', truncateHash(prevHash), false),
                      
                      if (data != null) ...[
                        const SizedBox(height: 12),
                        _buildDataPayload(data),
                      ],
                      
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text('NONCE: $nonce', style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHashRow(String label, String hash, bool isPrimary) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(label, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _panel,
              border: Border.all(color: _borderDim, width: 1),
            ),
            child: SelectableText(
              hash,
              style: TextStyle(color: isPrimary ? _green : _soft, fontFamily: 'monospace', fontSize: 11, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataPayload(dynamic data) {
    // Handling Genesis block or strings
    if (data is String || data['message'] != null) {
      final text = data is String ? data : data['message'];
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: _panel,
          border: Border(left: BorderSide(color: _muted, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PAYLOAD (SYSTEM)', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 4),
            SelectableText(
              text.toString(),
              style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    // Handling Encrypted Message Object
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(left: BorderSide(color: _green, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PAYLOAD (TRANSACTION)', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          _buildPayloadRow('MESSAGE ID', data['messageId']?.toString() ?? 'N/A'),
          _buildPayloadRow('SENDER', data['sender']?.toString() ?? 'N/A'),
          _buildPayloadRow('RECIPIENT', data['recipient']?.toString() ?? 'N/A'),
          _buildPayloadRow('ALGORITHM', data['algorithm']?.toString() ?? 'N/A'),
          const Divider(color: _borderDim, height: 12),
          _buildPayloadRow('MSG HASH', truncateHash(data['hash']?.toString()), isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildPayloadRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(label, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10)),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: isHighlight ? _green : _soft,
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}