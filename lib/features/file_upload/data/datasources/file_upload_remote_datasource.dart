import 'dart:io';

import 'package:http/http.dart' as http;

abstract class FileUploadRemoteDatasource {
  Future<void> uploadFile(File file);
}

class FileUploadRemoteDatasourceImpl implements FileUploadRemoteDatasource {
  static const String _uploadUrl = 'http://10.85.252.229:8000/api/v1/upload/csv';

  @override
  Future<void> uploadFile(File file) async {
    final uri = Uri.parse(_uploadUrl);
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // TODO: Replace with actual field name expected by the API
        file.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }
}
