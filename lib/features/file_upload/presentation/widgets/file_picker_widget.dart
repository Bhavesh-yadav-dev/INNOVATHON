import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerWidget extends StatefulWidget {
  /// Called with the picked [File] when the user selects one.
  final void Function(File file) onFilePicked;

  const FilePickerWidget({super.key, required this.onFilePicked});

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    setState(() => _fileName = result.files.single.name);
    widget.onFilePicked(file);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Pick CSV / Excel File'),
        ),
        if (_fileName != null) ...[
          const SizedBox(height: 8),
          Text(
            _fileName!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
