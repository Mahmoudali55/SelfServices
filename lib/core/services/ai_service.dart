import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  final String apiKey;
  final List<String> _models = [
    'gemini-2.5-flash-lite-preview-09-2025',
    'gemini-2.5-pro',
    'gemini-2.0',
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
      } catch (e) {}
    }
    return 'حدث خطأ أثناء الاتصال بكل الموديلات.';
  }
}
