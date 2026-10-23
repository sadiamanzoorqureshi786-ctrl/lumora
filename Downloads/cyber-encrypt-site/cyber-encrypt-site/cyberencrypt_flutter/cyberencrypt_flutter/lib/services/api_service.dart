import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

/// IMPORTANT — set this to wherever your Node backend actually runs.
/// - Android emulator -> 10.0.2.2 reaches your host machine's localhost
/// - iOS simulator / desktop / web -> localhost works directly
/// - Physical device -> your machine's LAN IP, e.g. http://192.168.1.20:5001
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5001',
  );
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final String? token;
  ApiService({this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _u(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

   dynamic _decode(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body ?? {}; // Prevent returning null
    }
    throw ApiException(body['error']?.toString() ?? 'Request failed (${res.statusCode})');
  }
  // ---------------- AUTH — routes/auth.js ----------------
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final res = await http.post(_u('/api/auth/signin'),
        headers: _headers, body: jsonEncode({'email': email, 'password': password}));
    return _decode(res);
  }

  Future<Map<String, dynamic>> signUp(String username, String email, String password) async {
    final res = await http.post(_u('/api/auth/signup'),
        headers: _headers,
        body: jsonEncode({'username': username, 'email': email, 'password': password}));
    return _decode(res);
  }

  /// GET /api/auth/me — persistent login check
  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(_u('/api/auth/me'), headers: _headers);
    return _decode(res);
  }

  /// Google OAuth is a browser redirect flow in the original app
  String get googleOAuthUrl => '${ApiConfig.baseUrl}/api/auth/google';

  /// POST /api/auth/forgot-password
  Future<void> sendPasswordResetEmail(String email) async {
    final res = await http.post(
      _u('/api/auth/forgot-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    _decode(res);
  }

  // ---------------- USERS — routes/users.js ----------------
  Future<List<dynamic>> getAllUsers() async {
    final res = await http.get(_u('/api/users/all'), headers: _headers);
    return _decode(res) as List<dynamic>;
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final res = await http.get(_u('/api/users/search?query=$query'), headers: _headers);
    return _decode(res) as List<dynamic>;
  }

  // ---------------- MESSAGES — routes/messages.js ----------------
  Future<Map<String, dynamic>> sendMessage({
    required String recipient,
    required String message,
    required String algorithm,
    required String key,
  }) async {
    final res = await http.post(_u('/api/messages/send'),
        headers: _headers,
        body: jsonEncode({
          'recipient': recipient,
          'message': message,
          'algorithm': algorithm,
          'key': key,
        }));
    return _decode(res);
  }

  Future<List<dynamic>> getReceivedMessages() async {
    final res = await http.get(_u('/api/messages/received'), headers: _headers);
    return _decode(res) as List<dynamic>;
  }

  Future<List<dynamic>> getSentMessages() async {
    final res = await http.get(_u('/api/messages/sent'), headers: _headers);
    return _decode(res) as List<dynamic>;
  }

  Future<int> getUnreadCount() async {
    final res = await http.get(_u('/api/messages/unread-count'), headers: _headers);
    final data = _decode(res);
    return data['count'] ?? 0;
  }

  Future<String> decryptMessage(String messageId, String key) async {
    final res = await http.post(_u('/api/messages/decrypt'),
        headers: _headers, body: jsonEncode({'messageId': messageId, 'key': key}));
    final data = _decode(res);
    return data['decryptedText'] as String;
  }

  // ---------------- HISTORY — routes/history.js ----------------
  Future<List<dynamic>> getHistory() async {
    final res = await http.get(_u('/api/history'), headers: _headers);
    return _decode(res) as List<dynamic>;
  }

  // ---------------- ENCRYPTION — routes/encryption.js ----------------
  Future<Map<String, dynamic>> encrypt({
    required String text,
    required String algorithm, // 'AES-256' or 'RSA'
    String? key,
  }) async {
    final res = await http.post(_u('/api/encrypt'),
        headers: _headers,
        body: jsonEncode({'text': text, 'algorithm': algorithm, if (key != null) 'key': key}));
    return _decode(res);
  }

  Future<Map<String, dynamic>> decrypt({
    required String encrypted,
    required String algorithm,
    String? key,
    String? iv,
  }) async {
    final res = await http.post(_u('/api/decrypt'),
        headers: _headers,
        body: jsonEncode({
          'encrypted': encrypted,
          'algorithm': algorithm,
          if (key != null) 'key': key,
          if (iv != null) 'iv': iv,
        }));
    return _decode(res);
  }

  // ---------------- BLOCKCHAIN — routes/blockchain.js ----------------
  Future<Map<String, dynamic>> getChain() async {
    final res = await http.get(_u('/api/blockchain/chain'), headers: _headers);
    return _decode(res);
  }

  Future<Map<String, dynamic>> verifyChain() async {
    final res = await http.get(_u('/api/blockchain/verify'), headers: _headers);
    return _decode(res);
  }

  // ---------------- SETTINGS — routes/settings.js ----------------
  Future<Map<String, dynamic>> getSettings() async {
    final res = await http.get(_u('/api/settings'), headers: _headers);
    return _decode(res);
  }

  /// PUT /api/settings/profile (Cross-Platform File Upload)
  Future<Map<String, dynamic>> uploadProfilePic(XFile file) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/settings/profile');
    var request = http.MultipartRequest('PUT', uri);
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Read as bytes - works on Web, Mobile, and Desktop!
    final bytes = await file.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'profilePic',
      bytes,
      filename: file.name,
    ));
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return _decode(response);
  }

  /// PUT /api/settings/preferences (For Toggle Switches)
  Future<Map<String, dynamic>> updatePreferences({
    bool? notificationsEnabled,
    bool? onlineStatusEnabled,
    bool? readReceiptsEnabled,
  }) async {
    final res = await http.put(
      _u('/api/settings/preferences'),
      headers: _headers,
      body: jsonEncode({
        if (notificationsEnabled != null) 'notificationsEnabled': notificationsEnabled,
        if (onlineStatusEnabled != null) 'onlineStatusEnabled': onlineStatusEnabled,
        if (readReceiptsEnabled != null) 'readReceiptsEnabled': readReceiptsEnabled,
      }),
    );
    return _decode(res);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final res = await http.put(_u('/api/settings/password'),
        headers: _headers,
        body: jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword}));
    _decode(res);
  }
}