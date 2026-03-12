// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  Future<String> uploadPostImage(File imageFile) async {
    try {
      // Compress and resize image
      final compressedFile = await _compressImage(imageFile);

      // Generate unique filename
      final extension = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$extension';
      final ref = _storage.ref().child('posts/$fileName');

      // Upload
      final uploadTask = ref.putFile(compressedFile);
      final snapshot = await uploadTask;

      // Get download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<File> _compressImage(File file) async {
    // Read image
    final imageBytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) throw Exception('Invalid image');

    // Resize if width > 1080
    if (image.width > 1080) {
      image = img.copyResize(image, width: 1080);
    }

    // Compress to JPEG
    final compressedBytes = img.encodeJpg(image, quality: 85);

    // Write to temp file
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/${_uuid.v4()}.jpg');
    await tempFile.writeAsBytes(compressedBytes);

    return tempFile;
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Image might not exist, ignore error
      print('Failed to delete image: $e');
    }
  }
}

