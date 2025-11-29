import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../models/article.dart';

class ExtractionService {
  final diffbotKey = '1e5c59e690cd0d8c3af63ba2bb42e009';
  final dio = Dio(
    BaseOptions(connectTimeout: 10.seconds, receiveTimeout: 10.seconds),
  );

  final cancel = CancelToken();

  void cancelRequest() {
    cancel.cancel();
  }

  /// Extract article body using Diffbot
  Future<Article?> extractArticleBody({
    required String articleUrl,
    required Article article,
  }) async {
    try {
      final encodedUrl = Uri.encodeComponent(articleUrl);
      final url =
          'https://api.diffbot.com/v3/article?url=$encodedUrl&naturalLanguage=summary&token=$diffbotKey';

      developer.log('🔗 Extracting article from: $articleUrl');

      final result = await dio.get(url, cancelToken: cancel);

      if (result.statusCode == 200) {
        developer.log('✅ Article extracted successfully');

        final objects = result.data["objects"] as List?;
        if (objects == null || objects.isEmpty) {
          developer.log('⚠️ No extracted data found');
          return null;
        }

        final extractedData = objects[0];
        final extractedText = extractedData["text"] ?? "";
        final extractedSummary = extractedData["naturalLanguage"]?["summary"] ?? "";

        // تحقق من أن الـ extraction بتحتوي على محتوى فعلي
        if (extractedText.isEmpty || extractedSummary.isEmpty) {
          developer.log('⚠️ Extracted data is empty');
          return null;
        }

        article.content = extractedText;
        article.summary = extractedSummary;

        developer.log('✅ Successfully extracted - Summary length: ${extractedSummary.length}');
        return article;
      } else {
        developer.log('❌ API returned status code: ${result.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      developer.log('❌ Extraction DioException: ${e.type} - ${e.message}');
      developer.log('Response status: ${e.response?.statusCode}');
      developer.log('Response data: ${e.response?.data}');
    } catch (e) {
      developer.log('❌ Extraction error: $e');
    }

    return null;
  }
}