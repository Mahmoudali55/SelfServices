import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class FilePreviewScreen extends StatelessWidget {
  final String base64Data;
  final String fileName;

  const FilePreviewScreen({super.key, required this.base64Data, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: Center(child: buildFileView(base64Data, fileName)),
    );
  }
}

Widget buildFileView(String base64String, String fileName) {
  final isImage = fileName.endsWith('.jpg') || fileName.endsWith('.png');
  final Uint8List bytes = base64Decode(base64String);

  if (isImage) {
    // ✅ عرض الصورة مباشرة
    return Image.memory(bytes, fit: BoxFit.contain);
  } else {
    // ✅ حفظ الملف مؤقتًا وفتحه
    return FutureBuilder(
      future: _saveAndOpenFile(bytes, fileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Text('تم فتح الملف في تطبيق خارجي ✅');
      },
    );
  }
}

Future<void> _saveAndOpenFile(Uint8List bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  await OpenFilex.open(file.path);
}
