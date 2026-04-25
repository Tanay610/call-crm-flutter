import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> recordingsRoot() async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, 'recordings');
  }

  Future<String> buildRecordingPath({
    required String customerId,
    required String recordingId,
  }) async {
    final root = await recordingsRoot();
    final dirPath = p.join(root, customerId);
    await Directory(dirPath).create(recursive: true);
    return p.join(dirPath, '$recordingId.m4a');
  }

  Future<int> fileSizeBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  Future<void> deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteCustomerDirectoryIfExists(String customerId) async {
    final root = await recordingsRoot();
    final dir = Directory(p.join(root, customerId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}

