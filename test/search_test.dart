import 'dart:convert';

import 'package:huggingface_tools/src/search.dart';
import 'package:test/test.dart';

void main() {
  group('ModelSearchResponse', () {
    test('serialization roundtrip test with "open source" search', () async {
      // Search for "open source" models
      final response = await searchModels(search: 'open source', limit: 5);

      // Verify we got results
      expect(response.items, isNotEmpty);

      // Test serialization roundtrip
      final json1 = response.toJson();
      final jsonString = jsonEncode(json1);
      final parsedJson = jsonDecode(jsonString) as Map<String, dynamic>;
      final deserializedResponse = ModelSearchResponse.fromJson(parsedJson);
      final json2 = deserializedResponse.toJson();

      // Compare the two JSON representations - they should be identical
      expect(jsonEncode(json2), equals(jsonString));

      // Verify the content is preserved
      expect(deserializedResponse.items.length, equals(response.items.length));

      // Check first item details are preserved
      if (response.items.isNotEmpty) {
        final original = response.items.first;
        final deserialized = deserializedResponse.items.first;

        expect(deserialized.id, equals(original.id));
        expect(deserialized.createdAt, equals(original.createdAt));
        expect(deserialized.downloads, equals(original.downloads));
        expect(deserialized.likes, equals(original.likes));
        expect(deserialized.private, equals(original.private));
        expect(deserialized.tags, equals(original.tags));
        expect(deserialized.pipelineTag, equals(original.pipelineTag));
        expect(deserialized.libraryName, equals(original.libraryName));
        expect(deserialized.trendingScore, equals(original.trendingScore));
      }
    });
  });
}
