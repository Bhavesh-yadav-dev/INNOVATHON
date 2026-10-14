import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/datasources/file_upload_remote_datasource.dart';
import '../../data/repositories/file_upload_repository_impl.dart';
import '../../domain/usecases/upload_file_usecase.dart';
import '../widgets/file_picker_widget.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final _uploadFileUsecase = UploadFileUsecase(
    FileUploadRepositoryImpl(FileUploadRemoteDatasourceImpl()),
  );

  bool _isUploading = false;

  Future<void> _handleFilePicked(File file) async {
    setState(() => _isUploading = true);
    try {
      await _uploadFileUsecase(file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Center(
        child: _isUploading
            ? const CircularProgressIndicator()
            : FilePickerWidget(onFilePicked: _handleFilePicked),
      ),
    );
  }
}
