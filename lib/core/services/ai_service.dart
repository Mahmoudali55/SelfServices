import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  final GenerativeModel _model;

  AiService({required String apiKey})
    : _model = GenerativeModel(
        model: 'gemini-2.5-pro', // فقط اسم الموديل
        apiKey: apiKey,
      );

  Future<String> sendMessage(String message) async {
    try {
      final response = await _model.generateContent([Content.text(message)]);
      return response.text ?? 'لم يتم العثور على رد من الذكاء الاصطناعي.';
    } catch (e) {
      return 'حدث خطأ أثناء الاتصال: $e';
    }
  }
}
