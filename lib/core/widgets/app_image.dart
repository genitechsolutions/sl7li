import 'package:flutter/material.dart';

import 'photo_source.dart';

/// صورة من asset محلي أو رابط شبكة (الخلفية بترجع روابط CloudFront).
class AppImage extends StatelessWidget {
  const AppImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;

  bool get _isNetwork => src.startsWith('http');

  @override
  Widget build(BuildContext context) {
    if (!_isNetwork) {
      return SizedBox(
        width: width,
        height: height,
        child: photoImage(src, fit: fit),
      );
    }
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, _, _) => SizedBox(width: width, height: height),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : SizedBox(width: width, height: height),
    );
  }
}
