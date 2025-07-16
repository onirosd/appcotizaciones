// lib/src/utils/image_utils.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:appcotizaciones/src/utils/image_result.dart';

class ImageUtils {
  static Future<ImageResult> descargarYGuardarImagen(
      String urlImagen, String nombreArchivo) async {
    try {
      final ByteData byteData =
          await NetworkAssetBundle(Uri.parse(urlImagen)).load("");
      final Uint8List bytes = byteData.buffer.asUint8List();
      final String dir = (await getTemporaryDirectory()).path;
      final String fullPath = '$dir/$nombreArchivo';

      final File file = File(fullPath);
      await file.writeAsBytes(bytes);

      return ImageResult(path: fullPath);
    } catch (e) {
      return ImageResult(error: e.toString());
    }
  }
}
