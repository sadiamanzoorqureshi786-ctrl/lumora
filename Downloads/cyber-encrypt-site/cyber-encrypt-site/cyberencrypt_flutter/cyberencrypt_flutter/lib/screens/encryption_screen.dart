import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

// --- CyberEncrypt Design System ---
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _white = Color(0xFFF0FFF3);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _borderDim = Color(0xFF143D20);
const Color _errorColor = Color(0xFFFF4D4D);


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
}

class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({super.key});

  @override
  State<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  String _mode = 'encrypt';
  String _algorithm = 'caesar';
  final _inputCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  final _ivCtrl = TextEditingController();
  String _output = '';
  String? _errorMessage; // Renamed to prevent shadowing
  bool _loading = false;

  Future<void> _process() async {
    setState(() {
      _errorMessage = null;
      _output = '';
    });
    if (_inputCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter text');
      return;
    }
    setState(() => _loading = true);
    try {
      final decrypt = _mode == 'decrypt';
      if (_algorithm == 'caesar') {
        final shift = int.tryParse(_keyCtrl.text) ?? 3;
        setState(() => _output = _Ciphers.caesar(_inputCtrl.text, shift, decrypt: decrypt));
      } else if (_algorithm == 'transposition') {
        final k = int.tryParse(_keyCtrl.text) ?? 3;
        setState(() => _output = _Ciphers.transposition(_inputCtrl.text, k, decrypt: decrypt));
      } else if (_algorithm == 'substitution') {
        setState(() => _output = _Ciphers.substitution(_inputCtrl.text, _keyCtrl.text, decrypt: decrypt));
      } else {
        // AES-256 / RSA -> real backend call
        final api = context.read<AuthProvider>().api;
        if (_mode == 'encrypt') {
          final res = await api.encrypt(text: _inputCtrl.text, algorithm: _algorithm, key: _keyCtrl.text);
          if (mounted) {
            setState(() {
              _output = res['encrypted'] ?? '';
              if (res['iv'] != null) _ivCtrl.text = res['iv'];
            });
          }
        } else {
          final res = await api.decrypt(
              encrypted: _inputCtrl.text, algorithm: _algorithm, key: _keyCtrl.text, iv: _ivCtrl.text);
          if (mounted) setState(() => _output = res['decrypted'] ?? '');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                  Icon(Icons.enhanced_encryption_outlined, color: _green, size: 18),
                  SizedBox(width: 10),
                  Text('ENCRYPTION TOOL', style: TextStyle(color: _green, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
                ],
              ),
              const Divider(color: _borderDim, height: 28),
              
              // Mode Toggle
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _mode = 'encrypt'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _mode == 'encrypt' ? _green : Colors.transparent,
                        foregroundColor: _mode == 'encrypt' ? _black : _green,
                        side: BorderSide(color: _mode == 'encrypt' ? _green : _borderDim, width: 1.5),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('ENCRYPT', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _mode = 'decrypt'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _mode == 'decrypt' ? _green : Colors.transparent,
                        foregroundColor: _mode == 'decrypt' ? _black : _green,
                        side: BorderSide(color: _mode == 'decrypt' ? _green : _borderDim, width: 1.5),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('DECRYPT', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Algorithm Selection
              DropdownButtonFormField<String>(
                initialValue: _algorithm,
                dropdownColor: _panel,
                style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                items: const [
                  DropdownMenuItem(value: 'caesar', child: Text('Caesar Cipher')),
                  DropdownMenuItem(value: 'transposition', child: Text('Transposition')),
                  DropdownMenuItem(value: 'substitution', child: Text('Substitution')),
                  DropdownMenuItem(value: 'AES-256', child: Text('AES-256')),
                  DropdownMenuItem(value: 'RSA', child: Text('RSA')),
                ],
                onChanged: (v) => setState(() => _algorithm = v!),
                decoration: _inputDecoration('ALGORITHM', null),
              ),
              const SizedBox(height: 16),

              // Key Input
              if (_algorithm != 'RSA')
                TextField(
                  controller: _keyCtrl,
                  style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                  cursorColor: _green,
                  decoration: _inputDecoration(
                    _algorithm == 'caesar'
                        ? 'SHIFT (1-25)'
                        : _algorithm == 'AES-256'
                            ? 'SECRET KEY (32 CHARS)'
                            : 'KEY',
                    null,
                  ),
                ),
              
              // IV Input for AES-256 Decrypt
              if (_algorithm == 'AES-256' && _mode == 'decrypt') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _ivCtrl,
                  style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                  cursorColor: _green,
                  decoration: _inputDecoration('IV (FROM ENCRYPTION)', null),
                ),
              ],
              
              const SizedBox(height: 16),

              // Input Text
              TextField(
                controller: _inputCtrl,
                maxLines: 4,
                style: const TextStyle(color: _white, fontFamily: 'monospace', fontSize: 14),
                cursorColor: _green,
                decoration: _inputDecoration('INPUT TEXT', null),
              ),
              const SizedBox(height: 24),

              // Process Button
              ElevatedButton(
                onPressed: _loading ? null : _process,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green, 
                  foregroundColor: _black, 
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: _loading 
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: _black, strokeWidth: 2))
                  : Text(
                      _mode == 'encrypt' ? 'EXECUTE ENCRYPTION' : 'EXECUTE DECRYPTION', 
                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
                    ),
              ),
              
              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _errorColor.withValues(alpha: 0.1),
                    border: const Border(left: BorderSide(color: _errorColor, width: 3)),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: _errorColor, fontFamily: 'monospace', fontSize: 12, height: 1.4)),
                ),
              ],
              
              // Output Panel
              if (_output.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.terminal_outlined, color: _muted, size: 16),
                    SizedBox(width: 8),
                    Text('OUTPUT', style: TextStyle(color: _muted, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _black,
                    border: Border.all(color: _green, width: 1),
                  ),
                  child: SelectableText(_output, style: const TextStyle(color: _green, fontFamily: 'monospace', fontSize: 14, height: 1.5)),
                ),
                if (_ivCtrl.text.isNotEmpty && _mode == 'encrypt') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _errorColor.withValues(alpha: 0.1),
                      border: const Border(left: BorderSide(color: _errorColor, width: 3)),
                    ),
                    child: Text(
                      'SAVE THIS IV: ${_ivCtrl.text}',
                      style: const TextStyle(color: _errorColor, fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, height: 1.4),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}