import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import 'download.dart';
import 'search.dart';

/// Command to download files from HuggingFace models.
class DownloadCommand extends Command<void> {
  @override
  final String name = 'download';

  @override
  final String description =
      'Download a specific file from a HuggingFace model';

  DownloadCommand() {
    argParser
      ..addOption(
        'model-id',
        abbr: 'm',
        help: 'The HuggingFace model ID (e.g., microsoft/DialoGPT-medium)',
        mandatory: true,
      )
      ..addOption(
        'filename',
        abbr: 'f',
        help: 'The specific filename to download from the model',
        mandatory: true,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output directory or file path where the file should be saved',
        defaultsTo: '.',
      )
      ..addOption(
        'token',
        abbr: 't',
        help: 'HuggingFace authentication token for private/gated models',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show detailed progress information',
        defaultsTo: false,
      )
      ..addFlag(
        'resume',
        abbr: 'r',
        help: 'Resume incomplete downloads',
        defaultsTo: true,
      )
      ..addFlag(
        'auto-path',
        abbr: 'a',
        help: 'Automatically append model ID and filename to output path',
        defaultsTo: false,
      );
  }

  @override
  Future<void> run() async {
    final modelId = argResults!['model-id'] as String;
    final filename = argResults!['filename'] as String;
    final outputPath = argResults!['output'] as String;
    final token = argResults!['token'] as String?;
    final verbose = argResults!['verbose'] as bool;
    final resume = argResults!['resume'] as bool;
    final autoPath = argResults!['auto-path'] as bool;

    if (verbose) {
      print('Fetching model information for: $modelId');
    }

    try {
      // Get model information
      final modelDetails = await getModelInfo(modelId);

      if (verbose) {
        print('Found model: ${modelDetails.id}');
        print('Available files: ${modelDetails.siblings.length}');
      }

      // Find the requested file
      final modelFile = modelDetails.modelFiles
          .where((file) => file.filename == filename)
          .firstOrNull;

      if (modelFile == null) {
        final availableFiles = modelDetails.modelFiles
            .map((f) => f.filename)
            .join(', ');
        stderr.writeln('Error: File "$filename" not found in model "$modelId"');
        stderr.writeln('Available files: $availableFiles');
        exit(1);
      }

      // Determine output file path
      String targetFilePath;
      if (autoPath) {
        // Auto-path: append model-id and filename to output path
        targetFilePath = path.join(outputPath, modelId, filename);
      } else if (outputPath.endsWith('/') ||
          Directory(outputPath).existsSync()) {
        // Output is a directory
        targetFilePath = path.join(outputPath, filename);
      } else {
        // Output is a specific file path
        targetFilePath = outputPath;
      }

      if (verbose) {
        print('Downloading ${modelFile.filename} (${modelFile.size} bytes)');
        print('Target path: $targetFilePath');
      }

      // Download the file with progress callback
      await downloadFile(
        modelFile,
        targetFilePath: targetFilePath,
        token: token,
        resumeIncompleteDownloads: resume,
        onProgress: verbose
            ? (progress) {
                stdout.write('\r$progress');
              }
            : null,
      );

      if (verbose) {
        stdout.writeln();
      }
      print('✓ Successfully downloaded $filename to $targetFilePath');
    } catch (e, stackTrace) {
      stderr.writeln('Error: $e');
      stderr.writeln('Stack trace:');
      stderr.writeln(stackTrace);
      exit(1);
    }
  }
}
