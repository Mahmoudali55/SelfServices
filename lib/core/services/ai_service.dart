import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  final String apiKey;
  final List<String> _models = [
    'gemini-3-flash-preview',
    'gemini-3.1-pro-preview',
    'gemini-3.1-flash-lite-preview',
  ];

  AiService({required this.apiKey});

  Future<String> sendMessage(String message) async {
    for (var modelName in _models) {
      try {
        final model = GenerativeModel(model: modelName, apiKey: apiKey);
        final response = await model.generateContent([Content.text(message)]);
        if (response.text != null) {
          return response.text!;
        }
      } catch (e) {
        debugPrint('Error with model $modelName: $e');
      }
    }
    return 'حدث خطأ أثناء الاتصال بكل الموديلات.';
  }
}
