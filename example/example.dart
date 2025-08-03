import 'dart:convert';

import 'package:huggingface_tools/huggingface_tools.dart';

Future<void> main() async {
  final response = await searchModels(search: 'text generation', limit: 5);
  print(json.encode(response.toJson()));

  final modelInfo = await getModelInfo('mistralai/Mistral-7B-Instruct-v0.1');
  await downloadFile(modelInfo.modelFiles.first, targetFilePath: './model.bin');
}
