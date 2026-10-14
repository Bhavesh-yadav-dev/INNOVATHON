import 'dart:io';

abstract class FileUploadRepository {
  Future<void> uploadFile(File file);
}
