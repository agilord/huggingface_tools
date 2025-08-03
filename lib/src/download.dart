import 'dart:io';
import 'package:http/http.dart' as http;
import '_http.dart';

class DownloadProgress {
  final int downloaded;
  final int total;
  final double percentage;
  final String filename;

  DownloadProgress({
    required this.downloaded,
    required this.total,
    required this.percentage,
    required this.filename,
  });

  @override
  String toString() {
    return 'Downloading $filename: ${percentage.toStringAsFixed(1)}% ($downloaded/$total bytes)';
  }
}

class ModelFile {
  final String filename;
  final int size;
  final String downloadUrl;

  ModelFile({
    required this.filename,
    required this.size,
    required this.downloadUrl,
  });

  factory ModelFile.fromSibling(String modelId, Map<String, dynamic> sibling) {
    final filename = sibling['rfilename'] as String;
    final size = sibling['size'] as int? ?? 0;
    final downloadUrl =
        'https://huggingface.co/$modelId/resolve/main/$filename';

    return ModelFile(filename: filename, size: size, downloadUrl: downloadUrl);
  }
}

/// Downloads a file from HuggingFace to the specified target path.
///
/// Returns the path to the downloaded file upon successful completion.
///
/// Parameters:
/// - [file]: The ModelFile containing download URL, filename, and size information
/// - [targetFilePath]: The complete path where the file should be saved
/// - [token]: Authentication token for accessing private/gated models
/// - [onProgress]: Callback function to receive download progress updates
/// - [resumeIncompleteDownloads]: Whether to resume partial downloads (default: true)
/// - [maxRetries]: Maximum number of retry attempts on failure (default: 3)
/// - [timeout]: Maximum time to wait for the download to complete (default: 30 minutes)
/// - [client]: Optional HTTP client to use for the download
///
/// Throws [DownloadException] if the download fails after all retries.
Future<String> downloadFile(
  ModelFile file, {
  required String targetFilePath,
  String? token,
  Function(DownloadProgress)? onProgress,
  bool resumeIncompleteDownloads = true,
  int maxRetries = 3,
  Duration timeout = const Duration(minutes: 30),
  http.Client? client,
}) async {
  return withHttpClient(
    client: client,
    fn: (client) async {
      await File(targetFilePath).parent.create(recursive: true);

      final uri = Uri.parse(file.downloadUrl);
      final destinationFile = File(targetFilePath);

      int startByte = 0;
      if (resumeIncompleteDownloads && await destinationFile.exists()) {
        startByte = await destinationFile.length();
        if (startByte >= file.size) {
          onProgress?.call(
            DownloadProgress(
              downloaded: file.size,
              total: file.size,
              percentage: 100.0,
              filename: file.filename,
            ),
          );
          return targetFilePath;
        }
      }

      final headers = <String, String>{};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      if (startByte > 0) {
        headers['Range'] = 'bytes=$startByte-';
      }

      int retryCount = 0;
      while (retryCount <= maxRetries) {
        try {
          final request = http.Request('GET', uri)..headers.addAll(headers);
          final streamedResponse = await client.send(request).timeout(timeout);

          if (streamedResponse.statusCode == 404) {
            throw DownloadException('File not found: ${file.filename}');
          }

          if (streamedResponse.statusCode != 200 &&
              streamedResponse.statusCode != 206) {
            throw DownloadException(
              'Download failed: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}',
            );
          }

          final sink = destinationFile.openWrite(
            mode: startByte > 0 ? FileMode.append : FileMode.write,
          );
          int downloaded = startByte;

          await for (final chunk in streamedResponse.stream) {
            sink.add(chunk);
            downloaded += chunk.length;

            if (onProgress != null) {
              final percentage = (downloaded / file.size * 100).clamp(
                0.0,
                100.0,
              );
              onProgress(
                DownloadProgress(
                  downloaded: downloaded,
                  total: file.size,
                  percentage: percentage,
                  filename: file.filename,
                ),
              );
            }
          }

          await sink.close();
          return targetFilePath;
        } catch (e) {
          retryCount++;
          if (retryCount > maxRetries) {
            rethrow;
          }

          await Future.delayed(Duration(seconds: retryCount * 2));

          if (await destinationFile.exists()) {
            startByte = await destinationFile.length();
            headers['Range'] = 'bytes=$startByte-';
          }
        }
      }

      return targetFilePath;
    },
  );
}

class DownloadException implements Exception {
  final String message;

  DownloadException(this.message);

  @override
  String toString() => 'DownloadException: $message';
}
