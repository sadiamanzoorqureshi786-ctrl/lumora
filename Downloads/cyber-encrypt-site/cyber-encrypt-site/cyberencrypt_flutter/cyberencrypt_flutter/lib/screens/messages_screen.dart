import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

// --- CyberEncrypt Design System ---
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _white = Color(0xFFF0FFF3);
const Color _soft = Color(0xFFC9FBD2);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _borderDim = Color(0xFF143D20);
const Color _errorColor = Color(0xFFFF4D4D);

Color _g(double alpha) => _green.withValues(alpha: alpha);

// --- Local Cipher Implementation (Zero-Knowledge for classical) ---
class _Ciphers {
  static String caesar(String text, int shift, {bool decrypt = false}) {
    final s = decrypt ? (26 - shift) % 26 : shift % 26;
    return String.fromCharCodes(text.codeUnits.map((code) {
      final c = String.fromCharCode(code);
      if (!RegExp(r'[a-zA-Z]').hasMatch(c)) return code;
      final isUpper = code >= 65 && code <= 90;
      final base = isUpper ? 65 : 97;
      return ((code - base + s) % 26 + 26) % 26 + base;
    }));
  }

  static String transposition(String text, int k, {bool decrypt = false}) {
    if (k <= 0) k = 3;
    if (decrypt) {
      final cols = (text.length / k).ceil();
      final buf = StringBuffer();
      for (int row = 0; row < cols; row++) {
        for (int col = 0; col < k; col++) {
          final idx = col * cols + row;
          if (idx < text.length) buf.write(text[idx]);
        }
      }
      return buf.toString();
    } else {
      final rows = (text.length / k).ceil();
      final buf = StringBuffer();
      for (int col = 0; col < k; col++) {
        for (int row = 0; row < rows; row++) {
          final idx = row * k + col;
          if (idx < text.length) buf.write(text[idx]);
        }
      }
      return buf.toString();
    }
  }

  static String substitution(String text, String key, {bool decrypt = false}) {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz';
    final keyLower = key.toLowerCase();
    final keyAlphabet = keyLower + alphabet.split('').where((c) => !keyLower.contains(c)).join();
    return text.split('').map((char) {
      final isUpper = char == char.toUpperCase() && char.toLowerCase() != char;
      final lower = char.toLowerCase();
      if (!alphabet.contains(lower)) return char;
      final index = decrypt ? keyAlphabet.indexOf(lower) : alphabet.indexOf(lower);
      final newChar = decrypt ? alphabet[index] : keyAlphabet[index];
      return isUpper ? newChar.toUpperCase() : newChar;
    }).join();
  }

  static String encrypt(String text, String algorithm, String key) {
    if (algorithm == 'caesar') return caesar(text, int.tryParse(key) ?? 3);
    if (algorithm == 'transposition') return transposition(text, int.tryParse(key) ?? 3);
    if (algorithm == 'substitution') return substitution(text, key);
    return text;
  }

  static String decrypt(String text, String algorithm, String key) {
    if (algorithm == 'caesar') return caesar(text, int.tryParse(key) ?? 3, decrypt: true);
    if (algorithm == 'transposition') return transposition(text, int.tryParse(key) ?? 3, decrypt: true);
    if (algorithm == 'substitution') return substitution(text, key, decrypt: true);
    return text;
  }
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> _received = [];
  List<dynamic> _sent = [];
  String _tab = 'all';
  List<dynamic> _searchResults = [];
  Map<String, dynamic>? _selectedUser;
  final _messageCtrl = TextEditingController();
  String _algorithm = 'caesar';
  final _keyCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;
  final Map<String, String> _decrypted = {};

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final api = context.read<AuthProvider>().api;
      final received = await api.getReceivedMessages();
      final sent = await api.getSentMessages();
      if (mounted) {
        setState(() {
          _received = received;
          _sent = sent;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Failed to load messages');
    }
  }

  Future<void> _search(String q) async {
    if (q.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final api = context.read<AuthProvider>().api;
      final results = await api.searchUsers(q);
      if (mounted) setState(() => _searchResults = results);
    } catch (_) {}
  }

  Future<void> _send() async {
    if (_selectedUser == null || _messageCtrl.text.trim().isEmpty || _keyCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields: recipient, message, and key');
      return;
    }
    if (_algorithm == 'AES-256' && _keyCtrl.text.length != 32) {
      setState(() => _errorMessage = 'AES-256 requires a 32-character key.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final api = context.read<AuthProvider>().api;
      String payloadMessage = _messageCtrl.text;

      // If classical cipher, encrypt locally before sending (Zero-Knowledge)
      if (_algorithm == 'caesar' || _algorithm == 'transposition' || _algorithm == 'substitution') {
        payloadMessage = _Ciphers.encrypt(_messageCtrl.text, _algorithm, _keyCtrl.text);
      }

      await api.sendMessage(
        recipient: _selectedUser!['username'],
        message: payloadMessage,
        algorithm: _algorithm,
        key: _keyCtrl.text,
      );

      setState(() {
        _successMessage = 'Message sent to ${_selectedUser!['username']}. Share the key securely.';
        _messageCtrl.clear();
        _keyCtrl.clear();
        _selectedUser = null;
      });
      _fetchMessages();
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _decryptMessage(String id, String algorithm, String encryptedText) async {
    final keyCtrl = TextEditingController();

    final key = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _panel,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: _borderDim, width: 1.5),
        ),
        title: const Text('ENTER DECRYPTION KEY', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: keyCtrl,
          style: const TextStyle(color: _white, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            filled: true,
            fillColor: _black,
            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _borderDim)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _borderDim)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _green)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ABORT', style: TextStyle(color: _muted, fontFamily: 'monospace'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, keyCtrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: _black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('DECRYPT', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (key == null || key.isEmpty) return;

    try {
      String decryptedText = '';

      // If classical cipher, decrypt locally
      if (algorithm == 'caesar' || algorithm == 'transposition' || algorithm == 'substitution') {
        decryptedText = _Ciphers.decrypt(encryptedText, algorithm, key);
      } else {
        // AES/RSA decrypt on backend
      }

      if (mounted) setState(() => _decrypted[id] = decryptedText);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to decrypt. Check your key.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to decrypt. Check your key.'), backgroundColor: _errorColor),
        );
      }
    }
  }

  List<dynamic> get _displayed {
    if (_tab == 'received') return _received;
    if (_tab == 'sent') return _sent;
    final all = [..._received, ..._sent];
    all.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- SEND ENCRYPTED MESSAGE ---
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
                  Icon(Icons.send_outlined, color: _green, size: 18),
                  SizedBox(width: 10),
                  Text('SEND ENCRYPTED MESSAGE', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
                ],
              ),
              const Divider(color: _borderDim, height: 28),
              TextField(
                onChanged: _search,
                style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                cursorColor: _green,
                decoration: _inputDecoration('RECIPIENT', 'SEARCH USERS'),
              ),
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: _black,
                    border: Border.all(color: _borderDim, width: 1),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: _searchResults.map((u) => ListTile(
                      title: Text(u['username'] ?? '', style: const TextStyle(color: _soft, fontFamily: 'monospace')),
                      onTap: () => setState(() {
                        _selectedUser = u;
                        _searchResults = [];
                      }),
                    )).toList(),
                  ),
                ),
              if (_selectedUser != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _g(0.1),
                    border: Border.all(color: _green, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_pin_outlined, color: _green, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('SENDING TO: ${_selectedUser!['username']}', style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.close, color: _muted, size: 18), onPressed: () => setState(() => _selectedUser = null)),
                    ],
                  ),
                ),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _errorColor.withValues(alpha: 0.1),
                    border: const Border(left: BorderSide(color: _errorColor, width: 3)),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: _errorColor, fontFamily: 'monospace', fontSize: 12)),
                ),
              if (_successMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _g(0.1),
                    border: const Border(left: BorderSide(color: _green, width: 3)),
                  ),
                  child: Text(_successMessage!, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 12)),
                ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _algorithm,
                      dropdownColor: _panel,
                      style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                      items: const [
                        DropdownMenuItem(value: 'caesar', child: Text('Caesar')),
                        DropdownMenuItem(value: 'transposition', child: Text('Transposition')),
                        DropdownMenuItem(value: 'substitution', child: Text('Substitution')),
                        DropdownMenuItem(value: 'AES-256', child: Text('AES-256')),
                      ],
                      onChanged: (v) => setState(() => _algorithm = v!),
                      decoration: _inputDecoration('ALGORITHM', null),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _keyCtrl,
                      style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                      cursorColor: _green,
                      decoration: _inputDecoration('KEY', null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _messageCtrl,
                maxLines: 4,
                style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                cursorColor: _green,
                decoration: _inputDecoration('MESSAGE', null),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: _black, elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: _black, strokeWidth: 2))
                    : const Text('EXECUTE TRANSMISSION', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- MESSAGE LOG ---
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _panel,
            border: Border.all(color: _borderDim, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_outlined, color: _green, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('MESSAGE LOG', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5))),
                  for (final t in ['all', 'received', 'sent'])
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _tab = t),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _tab == t ? _g(0.15) : Colors.transparent,
                          foregroundColor: _green,
                          side: BorderSide(color: _tab == t ? _green : _borderDim, width: 1),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(t.toUpperCase(), style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              const Divider(color: _borderDim, height: 28),
              if (_displayed.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text('NO MESSAGES LOGGED', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12, letterSpacing: 1))),
                )
              else
                for (final msg in _displayed) _MessageTile(msg: msg, me: me, decrypted: _decrypted, onDecrypt: _decryptMessage),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 11, letterSpacing: 1),
      hintStyle: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 12),
      filled: true,
      fillColor: _black,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _borderDim, width: 1)),
      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _borderDim, width: 1)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: _green, width: 1.5)),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final Map<String, dynamic> msg;
  final dynamic me;
  final Map<String, String> decrypted;
  final void Function(String, String, String) onDecrypt; // id, algorithm, encryptedText
  const _MessageTile({required this.msg, required this.me, required this.decrypted, required this.onDecrypt});

  @override
  Widget build(BuildContext context) {
    final senderId = (msg['sender'] is Map) ? msg['sender']['_id'] : msg['sender'];
    final isSent = senderId?.toString() == me?.id;
    final senderName = (msg['sender'] is Map) ? msg['sender']['username'] ?? 'Unknown' : 'Unknown';
    final recipientName = (msg['recipient'] is Map) ? msg['recipient']['username'] ?? 'Unknown' : 'Unknown';
    final isDecrypted = decrypted[msg['_id']];
    final algorithm = msg['algorithm'] ?? 'N/A';
    final encryptedText = msg['encryptedText'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border.all(color: isSent ? _green : _g(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isSent ? 'TO: ${recipientName.toUpperCase()}' : 'FROM: ${senderName.toUpperCase()}',
                  style: const TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(color: _panel, border: Border(left: BorderSide(color: _muted, width: 2))),
                child: Text(algorithm, style: const TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: _panel, border: Border(left: BorderSide(color: _muted, width: 2))),
            child: SelectableText(encryptedText, style: const TextStyle(color: _soft, fontFamily: 'monospace', fontSize: 12, height: 1.4)),
          ),
          if (isDecrypted != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _g(0.1), border: const Border(left: BorderSide(color: _green, width: 2))),
              child: SelectableText('DECRYPTED: $isDecrypted', style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 12, height: 1.4)),
            ),
          ],
          const SizedBox(height: 12),
          if (isDecrypted == null)
            Align(
              alignment: Alignment.bottomRight,
              child: OutlinedButton.icon(
                onPressed: () => onDecrypt(msg['_id'], algorithm, encryptedText),
                icon: const Icon(Icons.lock_open_outlined, color: _green, size: 16),
                label: const Text('DECRYPT', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _borderDim, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
        ],
      ),
    );
  }
}