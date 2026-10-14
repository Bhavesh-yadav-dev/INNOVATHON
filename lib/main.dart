import 'package:flutter/material.dart';

import 'features/file_upload/presentation/pages/file_upload_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Maya',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FileUploadPage(),
    );
  }
}
