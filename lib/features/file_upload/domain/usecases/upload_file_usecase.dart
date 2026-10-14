import 'dart:io';

import '../repositories/file_upload_repository.dart';

class UploadFileUsecase {
  final FileUploadRepository repository;

  UploadFileUsecase(this.repository);

  Future<void> call(File file) => repository.uploadFile(file);
}
