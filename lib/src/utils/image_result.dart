// lib/src/utils/image_result.dart
import 'dart:io';

class ImageResult {
  final String? path;
  final String? error;

  ImageResult({this.path, this.error});

  bool get hasError => error != null;
}
