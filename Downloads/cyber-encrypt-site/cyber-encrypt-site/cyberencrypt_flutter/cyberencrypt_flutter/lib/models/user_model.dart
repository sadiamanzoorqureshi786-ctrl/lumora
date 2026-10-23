/// Mirrors backend/models/User.js
class AppUser {
  final String id;
  final String username;
  final String email;
  final String? profilePic;
  final DateTime? createdAt;
  final bool isVerified;
  
  // --- User Preference Toggles (For Settings Screen) ---
  final bool notificationsEnabled;
  final bool onlineStatusEnabled;
  final bool readReceiptsEnabled;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.profilePic,
    this.createdAt,
    this.isVerified = false,
    this.notificationsEnabled = true,
    this.onlineStatusEnabled = true,
    this.readReceiptsEnabled = true,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? json['_id']).toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePic: json['profilePic'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      isVerified: json['isVerified'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      onlineStatusEnabled: json['onlineStatusEnabled'] ?? true,
      readReceiptsEnabled: json['readReceiptsEnabled'] ?? true,
    );
  }

  /// True if profilePic is a real, non-empty URL — used to decide between
  /// NetworkImage and the initials-circle fallback everywhere in the UI.
  bool get hasProfilePic => profilePic != null && profilePic!.trim().isNotEmpty;

  String get initial => username.isNotEmpty ? username[0].toUpperCase() : 'U';
}