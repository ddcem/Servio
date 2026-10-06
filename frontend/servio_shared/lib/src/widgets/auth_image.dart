import 'package:flutter/material.dart';

import '../theme/servio_colors.dart';

/// An image from an authorized API endpoint (menu item or profile image). [version] busts the cache
/// after an upload. Without an image, [fallback] is shown.
class AuthImage extends StatelessWidget {
  const AuthImage({
    super.key,
    required this.url,
    required this.headers,
    required this.hasImage,
    this.size = 48,
    this.version,
    this.fallback = Icons.restaurant,
    this.circle = false,
  });

  final String url;
  final Map<String, String> headers;
  final bool hasImage;
  final double size;
  final Object? version;
  final IconData fallback;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ServioColors.infoLight,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size / 5),
      ),
      child: Icon(fallback, size: size * 0.5, color: ServioColors.primary),
    );

    if (!hasImage) return placeholder;

    final image = Image.network(
      version == null ? url : '$url?v=$version',
      headers: headers,
      width: size,
      height: size,
      fit: circle ? BoxFit.cover : BoxFit.contain,
      cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
      errorBuilder: (_, _, _) => placeholder,
    );

    return circle ? ClipOval(child: image) : image;
  }
}
