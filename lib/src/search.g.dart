// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelSearchResponse _$ModelSearchResponseFromJson(Map<String, dynamic> json) =>
    ModelSearchResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => ModelSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModelSearchResponseToJson(
  ModelSearchResponse instance,
) => <String, dynamic>{'items': instance.items};

ModelSearchResult _$ModelSearchResultFromJson(Map<String, dynamic> json) =>
    ModelSearchResult(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      downloads: (json['downloads'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      private: json['private'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      pipelineTag: json['pipeline_tag'] as String?,
      libraryName: json['library_name'] as String?,
      trendingScore: (json['trendingScore'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ModelSearchResultToJson(ModelSearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'downloads': instance.downloads,
      'likes': instance.likes,
      'private': instance.private,
      'tags': instance.tags,
      'pipeline_tag': instance.pipelineTag,
      'library_name': instance.libraryName,
      'trendingScore': instance.trendingScore,
    };

ModelDetails _$ModelDetailsFromJson(Map<String, dynamic> json) => ModelDetails(
  id: json['id'] as String,
  author: json['author'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  downloads: (json['downloads'] as num?)?.toInt() ?? 0,
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  private: json['private'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  pipelineTag: json['pipeline_tag'] as String?,
  libraryName: json['library_name'] as String?,
  cardData: json['cardData'] as Map<String, dynamic>?,
  siblings:
      (json['siblings'] as List<dynamic>?)
          ?.map((e) => ModelSibling.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  gated: json['gated'] as bool? ?? false,
  lastModified: DateTime.parse(json['lastModified'] as String),
  securityStatus: json['securityStatus'] == null
      ? null
      : SecurityStatus.fromJson(json['securityStatus'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ModelDetailsToJson(ModelDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'createdAt': instance.createdAt.toIso8601String(),
      'downloads': instance.downloads,
      'likes': instance.likes,
      'private': instance.private,
      'tags': instance.tags,
      'pipeline_tag': instance.pipelineTag,
      'library_name': instance.libraryName,
      'cardData': instance.cardData,
      'siblings': instance.siblings,
      'gated': instance.gated,
      'lastModified': instance.lastModified.toIso8601String(),
      'securityStatus': instance.securityStatus,
    };

ModelSibling _$ModelSiblingFromJson(Map<String, dynamic> json) => ModelSibling(
  rfilename: json['rfilename'] as String,
  size: (json['size'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ModelSiblingToJson(ModelSibling instance) =>
    <String, dynamic>{'rfilename': instance.rfilename, 'size': instance.size};

SecurityStatus _$SecurityStatusFromJson(Map<String, dynamic> json) =>
    SecurityStatus(
      status: json['status'] as String,
      scannedRevisions: (json['scannedRevisions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SecurityStatusToJson(SecurityStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'scannedRevisions': instance.scannedRevisions,
    };
