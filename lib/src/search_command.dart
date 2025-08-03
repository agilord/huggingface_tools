import 'dart:io';
import 'package:args/command_runner.dart';
import 'search.dart';

/// Command to search for models on HuggingFace.
class SearchCommand extends Command<void> {
  @override
  final String name = 'search';

  @override
  final String description = 'Search for models on HuggingFace';

  SearchCommand() {
    argParser
      ..addOption(
        'query',
        abbr: 'q',
        help: 'Text query to search for in model names and descriptions',
      )
      ..addOption(
        'author',
        abbr: 'a',
        help: 'Filter by specific author/organization',
      )
      ..addOption('filter', help: 'Additional filter criteria (e.g., "gguf")')
      ..addOption(
        'sort',
        abbr: 's',
        help: 'Sort field: downloads, likes, lastModified, createdAt',
        allowed: ['downloads', 'likes', 'lastModified', 'createdAt'],
        defaultsTo: 'downloads',
      )
      ..addFlag(
        'ascending',
        help: 'Sort in ascending order (default is descending)',
        defaultsTo: false,
      )
      ..addOption(
        'limit',
        abbr: 'l',
        help: 'Maximum number of results to return',
        defaultsTo: '20',
      )
      ..addFlag(
        'full',
        abbr: 'f',
        help: 'Return full model information',
        defaultsTo: false,
      )
      ..addOption(
        'pipeline-tag',
        abbr: 'p',
        help: 'Filter by pipeline tag (e.g., "text-generation")',
      )
      ..addOption(
        'library',
        help: 'Filter by library name (e.g., "transformers")',
      )
      ..addMultiOption(
        'tags',
        abbr: 't',
        help: 'Filter by tags (can be used multiple times)',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show detailed model information',
        defaultsTo: false,
      )
      ..addFlag(
        'json',
        help: 'Output results in JSON format',
        defaultsTo: false,
      );
  }

  @override
  Future<void> run() async {
    final query = argResults!['query'] as String?;
    final author = argResults!['author'] as String?;
    final filter = argResults!['filter'] as String?;
    final sort = argResults!['sort'] as String;
    final ascending = argResults!['ascending'] as bool;
    final limitStr = argResults!['limit'] as String;
    final full = argResults!['full'] as bool;
    final pipelineTag = argResults!['pipeline-tag'] as String?;
    final library = argResults!['library'] as String?;
    final tags = argResults!['tags'] as List<String>;
    final verbose = argResults!['verbose'] as bool;
    final jsonOutput = argResults!['json'] as bool;

    final limit = int.tryParse(limitStr);
    if (limit == null || limit <= 0) {
      stderr.writeln('Error: Invalid limit value: $limitStr');
      exit(1);
    }

    try {
      final response = await searchModels(
        search: query,
        author: author,
        filter: filter,
        sort: sort,
        sortDescending: !ascending,
        limit: limit,
        full: full,
        pipelineTag: pipelineTag,
        library: library,
        tags: tags.isNotEmpty ? tags : null,
      );

      if (response.items.isEmpty) {
        print('No models found matching your criteria.');
        return;
      }

      if (jsonOutput) {
        // Output as JSON
        print(response.toJson());
      } else {
        // Human-readable output
        print('Found ${response.items.length} model(s):');
        print('');

        for (final model in response.items) {
          _printModel(model, verbose);
          print('');
        }
      }
    } catch (e, stackTrace) {
      stderr.writeln('Error: $e');
      stderr.writeln('Stack trace:');
      stderr.writeln(stackTrace);
      exit(1);
    }
  }

  void _printModel(ModelSearchResult model, bool verbose) {
    print('📦 ${model.id}');

    if (verbose) {
      print('   Created: ${model.createdAt.toIso8601String()}');
      print('   Downloads: ${model.downloads}');
      print('   Likes: ${model.likes}');
      print('   Private: ${model.private ? 'Yes' : 'No'}');
      print('   Trending Score: ${model.trendingScore}');

      if (model.pipelineTag != null) {
        print('   Pipeline: ${model.pipelineTag}');
      }

      if (model.libraryName != null) {
        print('   Library: ${model.libraryName}');
      }

      if (model.tags.isNotEmpty) {
        print('   Tags: ${model.tags.join(', ')}');
      }
    } else {
      final info = <String>[];
      info.add('${model.downloads} downloads');
      info.add('${model.likes} likes');

      if (model.pipelineTag != null) {
        info.add(model.pipelineTag!);
      }

      print('   ${info.join(' • ')}');

      if (model.tags.isNotEmpty) {
        final displayTags = model.tags.take(5).join(', ');
        final moreCount = model.tags.length - 5;
        print(
          '   Tags: $displayTags${moreCount > 0 ? ' (+$moreCount more)' : ''}',
        );
      }
    }
  }
}
