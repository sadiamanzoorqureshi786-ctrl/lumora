import 'package:flutter/material.dart';
import '../theme/matrix_theme.dart';

/// One avatar widget for the whole app. Original React code had THREE
/// different, inconsistent implementations:
///  - userList.js: correctly showed <img src={profilePic}> with fallback
///  - Profile.js / Header.js / Dashboard.js: ALWAYS showed initials only,
///    even when a real profilePic (e.g. from Google login) existed.
/// This widget fixes that everywhere at once.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackInitial;
  final double size;
  final double borderWidth;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackInitial,
    this.size = 64,
    this.borderWidth = 2,
  });

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: MatrixColors.green, width: borderWidth),
        color: MatrixColors.greenAlpha(0.2),
        boxShadow: [BoxShadow(color: MatrixColors.greenAlpha(0.3), blurRadius: 12)],
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              // If the URL 404s / fails to load (e.g. a stale Google photo
              // URL), gracefully fall back to initials instead of a broken
              // image icon.
              errorBuilder: (context, error, stackTrace) => _initials(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MatrixColors.green,
                    ),
                  ),
                );
              },
            )
          : _initials(),
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        fallbackInitial,
        style: TextStyle(
          color: MatrixColors.green,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w900,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
