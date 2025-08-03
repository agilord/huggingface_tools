# HuggingFace Tools

Dart CLI and library for searching and downloading HuggingFace models.

## CLI

Search models:
```bash
dart run huggingface_tools search --query "llama" --limit 5
```

Download files:
```bash
dart run huggingface_tools download --model-id microsoft/DialoGPT-medium --filename pytorch_model.bin
```

## Library

```dart
import 'package:huggingface_tools/huggingface_tools.dart';

final response = await searchModels(search: 'text generation', limit: 5);
final modelInfo = await getModelInfo('mistralai/Mistral-7B-Instruct-v0.1');
await downloadFile(modelInfo.modelFiles.first, targetFilePath: './model.bin');
```
