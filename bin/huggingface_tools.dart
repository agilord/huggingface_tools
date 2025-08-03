import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:huggingface_tools/src/download_command.dart';
import 'package:huggingface_tools/src/search_command.dart';

Future<void> main(List<String> arguments) async {
  final runner =
      CommandRunner<void>(
          'huggingface_tools',
          'Command-line tools for downloading and searching HuggingFace models.',
        )
        ..addCommand(SearchCommand())
        ..addCommand(DownloadCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    // Handle argument parsing errors
    stderr.writeln(e.message);
    stderr.writeln('');
    stderr.writeln(e.usage);
    exit(64); // EX_USAGE from sysexits.h
  } catch (e, stackTrace) {
    // Handle other errors
    stderr.writeln('Error: $e');
    stderr.writeln('Stack trace:');
    stderr.writeln(stackTrace);
    exit(1);
  }
}
