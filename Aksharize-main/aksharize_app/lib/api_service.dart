import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  /// Uploads [image] to POST /ocr and returns
  /// both OCR text and transliteration.
  Future<Map<String, String>> uploadImage(File image) async {
    final uri = Uri.parse('$baseUrl/ocr');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          json.decode(response.body);

      return {
        'text': body['text']?.toString() ?? '',
        'transliteration':
            body['transliteration']?.toString() ?? '',
      };
    } else {
      try {
        final Map<String, dynamic> body =
            json.decode(response.body);

        final detail =
            body['detail'] ?? body['error'] ?? 'Unknown error';

        throw Exception(
          'Server error ${response.statusCode}: $detail',
        );
      } catch (_) {
        throw Exception(
          'Upload failed (HTTP ${response.statusCode})',
        );
      }
    }
  }
}