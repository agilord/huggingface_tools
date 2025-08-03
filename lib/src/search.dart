import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import '_http.dart';
import 'download.dart';

part 'search.g.dart';

@JsonSerializable()
class ModelSearchResponse {
  final List<ModelSearchResult> items;

  ModelSearchResponse({required this.items});

  factory ModelSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ModelSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ModelSearchResponseToJson(this);
}

@JsonSerializable()
class ModelSearchResult {
  final String id;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  final int downloads;
  final int likes;
  final bool private;
  final List<String> tags;
  @JsonKey(name: 'pipeline_tag')
  final String? pipelineTag;
  @JsonKey(name: 'library_name')
  final String? libraryName;
  final int trendingScore;

  ModelSearchResult({
    required this.id,
    required this.createdAt,
    this.downloads = 0,
    this.likes = 0,
    this.private = false,
    this.tags = const [],
    this.pipelineTag,
    this.libraryName,
    this.trendingScore = 0,
  });

  factory ModelSearchResult.fromJson(Map<String, dynamic> json) =>
      _$ModelSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$ModelSearchResultToJson(this);
}

@JsonSerializable()
class ModelDetails {
  final String id;
  final String? author;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  final int downloads;
  final int likes;
  final bool private;
  final List<String> tags;
  @JsonKey(name: 'pipeline_tag')
  final String? pipelineTag;
  @JsonKey(name: 'library_name')
  final String? libraryName;
  final Map<String, dynamic>? cardData;
  final List<ModelSibling> siblings;
  final bool gated;
  final DateTime lastModified;
  final SecurityStatus? securityStatus;

  ModelDetails({
    required this.id,
    this.author,
    required this.createdAt,
    this.downloads = 0,
    this.likes = 0,
    this.private = false,
    this.tags = const [],
    this.pipelineTag,
    this.libraryName,
    this.cardData,
    this.siblings = const [],
    this.gated = false,
    required this.lastModified,
    this.securityStatus,
  });

  factory ModelDetails.fromJson(Map<String, dynamic> json) =>
      _$ModelDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ModelDetailsToJson(this);

  bool get hasGgufFiles {
    return siblings.any((sibling) => sibling.rfilename.endsWith('.gguf'));
  }

  List<ModelSibling> get ggufFiles {
    return siblings
        .where((sibling) => sibling.rfilename.endsWith('.gguf'))
        .toList();
  }

  List<ModelFile> get modelFiles {
    return siblings
        .map(
          (sibling) => ModelFile(
            filename: sibling.rfilename,
            size: sibling.size,
            downloadUrl:
                'https://huggingface.co/$id/resolve/main/${sibling.rfilename}',
          ),
        )
        .toList();
  }

  List<ModelFile> get ggufModelFiles {
    return ggufFiles
        .map(
          (sibling) => ModelFile(
            filename: sibling.rfilename,
            size: sibling.size,
            downloadUrl:
                'https://huggingface.co/$id/resolve/main/${sibling.rfilename}',
          ),
        )
        .toList();
  }
}

@JsonSerializable()
class ModelSibling {
  final String rfilename;
  final int size;

  ModelSibling({required this.rfilename, this.size = 0});

  factory ModelSibling.fromJson(Map<String, dynamic> json) =>
      _$ModelSiblingFromJson(json);

  Map<String, dynamic> toJson() => _$ModelSiblingToJson(this);
}

@JsonSerializable()
class SecurityStatus {
  final String status;
  final List<String>? scannedRevisions;

  SecurityStatus({required this.status, this.scannedRevisions});

  factory SecurityStatus.fromJson(Map<String, dynamic> json) =>
      _$SecurityStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityStatusToJson(this);
}

const String _baseUrl = 'https://huggingface.co/api/models';

/// Searches for models on Hugging Face.
///
/// Parameters:
/// - [search]: Text query to search for in model names and descriptions
/// - [author]: Filter by specific author/organization
/// - [filter]: Additional filter criteria (e.g., 'gguf')
/// - [sort]: Sort field ('downloads', 'likes', 'lastModified', 'createdAt')
/// - [sortDescending]: Whether to sort in descending order (default: true)
/// - [limit]: Maximum number of results to return
/// - [full]: Whether to return full model information (default: false)
/// - [pipelineTag]: Filter by pipeline tag (e.g., 'text-generation')
/// - [library]: Filter by library name (e.g., 'transformers')
/// - [tags]: List of tags to filter by
/// - [client]: Optional HTTP client to use for requests
Future<ModelSearchResponse> searchModels({
  String? search,
  String? author,
  String? filter,
  String? sort,
  bool sortDescending = true,
  int? limit,
  bool full = false,
  String? pipelineTag,
  String? library,
  List<String>? tags,
  http.Client? client,
}) async {
  return withHttpClient(
    client: client,
    fn: (client) async {
      final params = <String, String>{};

      if (search != null) params['search'] = search;
      if (author != null) params['author'] = author;
      if (filter != null) params['filter'] = filter;
      if (sort != null) {
        params['sort'] = sort;
        // API only supports descending (-1) for downloads and lastModified
        if (sortDescending && (sort == 'downloads' || sort == 'lastModified')) {
          params['direction'] = '-1';
        }
      }
      if (limit != null) params['limit'] = limit.toString();
      if (full) params['full'] = 'true';
      if (pipelineTag != null) params['pipeline_tag'] = pipelineTag;
      if (library != null) params['library'] = library;
      if (tags != null && tags.isNotEmpty) {
        params['tags'] = tags.join(',');
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

      final response = await client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to search models: ${response.statusCode} ${response.reasonPhrase}',
          response.statusCode,
        );
      }

      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      final items = jsonList
          .map(
            (json) => ModelSearchResult.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return ModelSearchResponse(items: items);
    },
  );
}

Future<ModelDetails> getModelInfo(String modelId, {http.Client? client}) async {
  return withHttpClient(
    client: client,
    fn: (client) async {
      final uri = Uri.parse('$_baseUrl/$modelId');

      final response = await client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 404) {
        throw ApiException('Model not found: $modelId', 404);
      }

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to get model info: ${response.statusCode} ${response.reasonPhrase}',
          response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ModelDetails.fromJson(json);
    },
  );
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message';
}
