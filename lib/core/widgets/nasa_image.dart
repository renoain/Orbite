import 'package:flutter/material.dart';
import 'package:orbite/core/widgets/shimmer_loading.dart';

class NasaImage extends StatelessWidget {
  const NasaImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.height,
    this.width,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isAsset = url.startsWith('assets/');
    Widget image;
    if (isAsset) {
      image = Image.asset(
        url,
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (context, error, stackTrace) {
          return _errorPlaceholder(height, width);
        },
      );
    } else {
      image = Image.network(
        url,
        fit: fit,
        height: height,
        width: width,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ShimmerLoading(
            child: Container(
              height: height,
              width: width,
              color: Colors.grey[850],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _errorPlaceholder(height, width);
        },
      );
    }

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _errorPlaceholder(double? height, double? width) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[850],
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, color: Colors.white54, size: 32),
          SizedBox(height: 4),
          Text(
            'Gagal memuat gambar',
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
