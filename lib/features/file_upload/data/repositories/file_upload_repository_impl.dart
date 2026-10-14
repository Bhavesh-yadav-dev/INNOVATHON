import 'dart:io';

import '../../domain/repositories/file_upload_repository.dart';
import '../datasources/file_upload_remote_datasource.dart';

class FileUploadRepositoryImpl implements FileUploadRepository {
  final FileUploadRemoteDatasource remoteDatasource;

  FileUploadRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> uploadFile(File file) => remoteDatasource.uploadFile(file);
}
