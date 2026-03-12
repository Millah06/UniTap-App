// lib/screens/create_post_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../services/social_api_service.dart';
import '../../../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final SocialApiService _apiService = SocialApiService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isPosting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image');
    }
  }

  Future<void> _createPost() async {
    final text = _textController.text.trim();

    if (text.isEmpty && _selectedImage == null) {
      _showError('Please add some text or an image');
      return;
    }

    if (text.length > 500) {
      _showError('Post text cannot exceed 500 characters');
      return;
    }

    setState(() => _isPosting = true);

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _apiService.uploadPostImage(_selectedImage!);
      }

      await _apiService.createPost(
        text: text,
        imageUrl: imageUrl,
      );

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccess('Post created successfully!');
      }
    } catch (e) {
      _showError('Failed to create post: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textLength = _textController.text.length;
    final isOverLimit = textLength > 500;

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isPosting || isOverLimit ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: _isPosting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImage != null) ...[
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF334155),
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: Colors.blue[700],
                  ),
                  onPressed: _isPosting ? null : _pickImage,
                ),
                const Spacer(),
                Text(
                  '$textLength/500',
                  style: TextStyle(
                    color: isOverLimit ? Colors.red : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}