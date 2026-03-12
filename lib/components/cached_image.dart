import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget networkTemplate(String url) {

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade600,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
    ),
  );

}
