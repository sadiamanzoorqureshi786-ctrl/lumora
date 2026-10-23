import 'package:flutter/material.dart';

// --- CyberEncrypt Design System ---
const Color _black = Color(0xFF000000);
const Color _green = Color(0xFF00FF66);
const Color _white = Color(0xFFF0FFF3);
const Color _soft = Color(0xFFC9FBD2);
const Color _muted = Color(0xFF83BF8D);
const Color _panel = Color(0xFF020802);
const Color _borderDim = Color(0xFF143D20);


const double _headlineSize = 32.0;
const double _titleSize = 20.0;
const double _bodySize = 14.0;
const double _smallSize = 12.0;

// Data model for our document sections
class _DocSection {
  final String heading;
  final List<String> body;
  const _DocSection({required this.heading, required this.body});
}

// Reusable Document Viewer Screen
class DocumentScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<_DocSection> sections;

  const DocumentScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      appBar: AppBar(
        backgroundColor: _black,
        elevation: 0,
        iconTheme: const IconThemeData(color: _green),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _green,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _borderDim, height: 1.0),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: sections.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: _white,
                    fontFamily: 'monospace',
                    fontSize: _headlineSize,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'LAST UPDATED: $lastUpdated',
                  style: const TextStyle(
                    color: _muted,
                    fontFamily: 'monospace',
                    fontSize: _smallSize,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          }

          final section = sections[index - 1];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Heading
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _panel,
                  border: Border(left: BorderSide(color: _green, width: 3)),
                ),
                child: Text(
                  section.heading.toUpperCase(),
                  style: const TextStyle(
                    color: _green,
                    fontFamily: 'monospace',
                    fontSize: _titleSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Section Body
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: section.body.map((text) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: _soft,
                        fontFamily: 'monospace',
                        fontSize: _bodySize,
                        height: 1.6,
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- PRE-BUILT SCREENS ---

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DocumentScreen(
      title: 'PRIVACY POLICY',
      lastUpdated: 'AUGUST 2024',
      sections: [
        _DocSection(
          heading: '1. DATA COLLECTION',
          body: [
            'CyberEncrypt operates on a zero-knowledge architecture where possible. We collect only the essential information required to provide our services: your username, email address, and profile picture.',
            'We do not read, store, or have access to the plaintext of your encrypted messages. Messages are encrypted locally on your device before ever touching our servers.',
          ],
        ),
        _DocSection(
          heading: '2. BLOCKCHAIN LEDGER',
          body: [
            'Every encrypted message transaction is logged on our tamper-evident blockchain. This ledger contains cryptographic hashes, timestamps, and algorithm metadata.',
            'It does NOT contain your plaintext message or your encryption keys. The ledger exists solely to prove that a transaction occurred between two nodes and has not been altered.',
          ],
        ),
        _DocSection(
          heading: '3. AUTHENTICATION',
          body: [
            'We use JSON Web Tokens (JWT) for session management. If you choose to sign in with Google, we request only basic profile information (name, email, and avatar) via OAuth 2.0.',
            'We do not have access to your Google password.',
          ],
        ),
        _DocSection(
          heading: '4. DATA RETENTION',
          body: [
            'Your encrypted messages and blockchain history are retained indefinitely to preserve the integrity of the audit trail.',
            'If you request account deletion, your user profile will be removed, but your hashed transaction records will remain on the chain permanently to maintain ledger continuity.',
          ],
        ),
      ],
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DocumentScreen(
      title: 'TERMS OF SERVICE',
      lastUpdated: 'AUGUST 2024',
      sections: [
        _DocSection(
          heading: '1. ACCEPTABLE USE',
          body: [
            'You agree to use CyberEncrypt only for lawful purposes. You may not use this platform to transmit malicious code, illegal content, or to facilitate cyberattacks.',
            'The encryption tools provided are designed for educational purposes and secure communication. Any attempt to reverse engineer the platform to compromise other users is strictly prohibited.',
          ],
        ),
        _DocSection(
          heading: '2. ACCOUNT SECURITY',
          body: [
            'You are solely responsible for maintaining the security of your account credentials and your encryption keys.',
            'Because we employ a zero-knowledge architecture for message content, we cannot recover your encrypted messages if you lose your encryption key. Keep your keys secure.',
          ],
        ),
        _DocSection(
          heading: '3. INTELLECTUAL PROPERTY',
          body: [
            'All software, design elements, and code associated with CyberEncrypt are the intellectual property of the platform owners.',
            'Users retain full ownership of the plaintext content they encrypt and transmit through the service.',
          ],
        ),
        _DocSection(
          heading: '4. LIMITATION OF LIABILITY',
          body: [
            'CyberEncrypt is provided "as is" without warranties of any kind. We do not guarantee that the service will be uninterrupted or completely immune to all forms of attack.',
            'Under no circumstances shall the developers be held liable for any data loss, breach, or damages arising from the use of this platform.',
          ],
        ),
      ],
    );
  }
}

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DocumentScreen(
      title: 'DOCUMENTATION',
      lastUpdated: 'AUGUST 2024',
      sections: [
        _DocSection(
          heading: '1. SYSTEM ARCHITECTURE',
          body: [
            'CyberEncrypt is built on a Node.js/Express backend with MongoDB for user and message storage. The frontend is powered by Flutter, ensuring cross-platform compatibility.',
            'The blockchain ledger is implemented in-memory on the backend and synchronized with the database to ensure persistent, tamper-evident logging.',
          ],
        ),
        _DocSection(
          heading: '2. SUPPORTED ALGORITHMS',
          body: [
            'AES-256: Industry standard symmetric encryption. Requires a 32-character key.',
            'RSA: Asymmetric public-key cryptography. Uses generated public/private key pairs.',
            'Caesar Cipher: Classical substitution cipher. Requires an integer shift (1-25).',
            'Transposition: Rail-fence style cipher. Requires an integer key.',
            'Substitution: Custom alphabet mapping based on a keyword.',
          ],
        ),
        _DocSection(
          heading: '3. API ENDPOINTS',
          body: [
            'POST /api/auth/signup : Register a new user.',
            'POST /api/auth/signin : Authenticate and receive JWT.',
            'POST /api/messages/send : Transmit encrypted ciphertext.',
            'GET /api/blockchain/chain : Retrieve the full ledger.',
            'GET /api/blockchain/verify : Recalculate hashes to verify chain integrity.',
          ],
        ),
        _DocSection(
          heading: '4. INTEGRATION',
          body: [
            'To integrate with the CyberEncrypt API, include the Authorization: Bearer <token> header in your requests.',
            'All payload data must be sent as JSON. Ensure that ciphertext is properly base64 encoded before transmission.',
          ],
        ),
      ],
    );
  }
}