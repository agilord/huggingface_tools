import 'dart:io';

import 'package:huggingface_tools/huggingface_tools.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('search and download ChristianAzinn/gte-small-gguf', () async {
    final model = await getModelInfo('ChristianAzinn/gte-small-gguf');

    final q2kFile = model.ggufModelFiles.firstWhere(
      (f) => f.filename == 'gte-small.Q2_K.gguf',
    );

    final tempDir = await Directory.systemTemp.createTemp('hf_test_');

    try {
      final targetPath = p.join(tempDir.path, q2kFile.filename);
      final filePath = await downloadFile(q2kFile, targetFilePath: targetPath);

      final file = File(filePath);
      expect(await file.exists(), isTrue);
      final expectedSize = q2kFile.size == 0 ? 25250080 : q2kFile.size;
      expect(await file.length(), equals(expectedSize));
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
