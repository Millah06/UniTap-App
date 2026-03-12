// lib/services/image_processor_service.dart - NEW

// lib/services/image_processor_service.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class ImageProcessorService {
  Future<void> downloadProcessedImage({
    required String imageUrl,
    required String caption,
    required String username,
  }) async {
    try {
      // Download original image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }
      final imageBytes = response.bodyBytes;

      // Decode image
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Create canvas with image and overlays
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();

      // Draw original image
      canvas.drawImage(image, Offset.zero, paint);

      // Calculate dimensions
      final width = image.width.toDouble();
      final height = image.height.toDouble();

      // Add gradient overlay at bottom
      final gradientRect = Rect.fromLTWH(0, height - 150, width, 150);
      final gradient = ui.Gradient.linear(
        Offset(0, height - 150),
        Offset(0, height),
        [
          Colors.transparent,
          Colors.black.withOpacity(0.8),
        ],
      );

      final gradientPaint = Paint()..shader = gradient;
      canvas.drawRect(gradientRect, gradientPaint);

      // Draw caption (wrapped)
      final captionText = caption.length > 100
          ? '${caption.substring(0, 100)}...'
          : caption;

      final captionPainter = TextPainter(
        text: TextSpan(
          text: captionText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        textAlign: TextAlign.left,
      );

      captionPainter.layout(maxWidth: width - 40);
      captionPainter.paint(canvas, Offset(20, height - 100));

      // Draw username
      final usernamePainter = TextPainter(
        text: TextSpan(
          text: '@$username',
          style: const TextStyle(
            color: Color(0xFF177E85),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      usernamePainter.layout();
      usernamePainter.paint(canvas, Offset(20, height - 40));

      // Draw watermark (app name)
      final watermarkPainter = TextPainter(
        text: const TextSpan(
          text: 'Everywhere',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      watermarkPainter.layout();
      watermarkPainter.paint(
        canvas,
        Offset(
          width - watermarkPainter.width - 20,
          height - 30,
        ),
      );

      // Convert to image
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(image.width, image.height);
      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/post_$timestamp.png');
      await tempFile.writeAsBytes(pngBytes);

      // Save to gallery using gal
      await Gal.putImage(tempFile.path, album: 'Everywhere');

      // Clean up temp file
      await tempFile.delete();

    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }
}