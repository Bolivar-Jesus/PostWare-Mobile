import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';

class DownloadService {
  static Future<String?> downloadAndSavePDF(
    Uint8List pdfBytes,
    String fileName,
    BuildContext context,
  ) async {
    try {
      // Obtener el directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');

      // Crear directorio de descargas si no existe
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Crear archivo PDF
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      return file.path;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  static Future<void> openPDF(String filePath, BuildContext context) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el PDF: ${result.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> downloadAndOpenPDF(
    Uint8List pdfBytes,
    String fileName,
    BuildContext context,
  ) async {
    final filePath = await downloadAndSavePDF(pdfBytes, fileName, context);
    if (filePath != null) {
      await openPDF(filePath, context);
    }
  }
}
