import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? selectedImage;

  String extractedText = '';
  String transliteratedText = '';

  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  // ─────────────────────────────────────────────────────────────
  // Image Selection
  // ─────────────────────────────────────────────────────────────

  Future<void> _pickFromCamera() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        extractedText = '';
        transliteratedText = '';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        extractedText = '';
        transliteratedText = '';
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Upload Image
  // ─────────────────────────────────────────────────────────────

  Future<void> _uploadImage() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an image first'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      extractedText = '';
      transliteratedText = '';
    });

    try {
      final result =
          await _apiService.uploadImage(selectedImage!);

      setState(() {
        extractedText =
            (result['text'] ?? '').isEmpty
                ? 'No text found'
                : result['text']!;

        transliteratedText =
            result['transliteration'] ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aksharize OCR'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _ImagePreview(image: selectedImage),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            isLoading ? null : _pickFromCamera,
                        icon:
                            const Icon(Icons.camera_alt),
                        label:
                            const Text('Camera'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            isLoading ? null : _pickFromGallery,
                        icon: const Icon(
                            Icons.photo_library),
                        label:
                            const Text('Gallery'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed:
                      isLoading ? null : _uploadImage,
                  icon: const Icon(Icons.upload),
                  label:
                      const Text('Extract Text'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (extractedText.isNotEmpty)
                  _OcrResultCard(
                    text: extractedText,
                    transliteration:
                        transliteratedText,
                  ),
              ],
            ),
          ),

          if (isLoading)
            const ColoredBox(
              color: Color(0x55000000),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Image Preview
// ─────────────────────────────────────────────────────────────

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.image,
  });

  final File? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:
            BorderRadius.circular(12),
        border:
            Border.all(color: Colors.grey[400]!),
      ),
      clipBehavior: Clip.hardEdge,
      child: image == null
          ? const Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'No image selected',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          : Image.file(
              image!,
              fit: BoxFit.contain,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// OCR Result Card
// ─────────────────────────────────────────────────────────────

class _OcrResultCard extends StatelessWidget {
  const _OcrResultCard({
    required this.text,
    required this.transliteration,
  });

  final String text;
  final String transliteration;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'OCR Result',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const Divider(),

            SelectableText(
              text,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'English Transliteration',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const Divider(),

            SelectableText(
              transliteration,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}