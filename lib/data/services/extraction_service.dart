import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/article.dart';

class ExtractionService{
  final key = '1e5c59e690cd0d8c3af63ba2bb42e009';

  final dio = Dio(
    BaseOptions(connectTimeout: 10.seconds, receiveTimeout: 10.seconds),
  );
  final cancel = CancelToken();
  void cancelRequest(){
    cancel.cancel();
  }

  Future<Article?> extractArticleBody({
    required String articleUrl,
    required Article article,
  }) async {
    try {
      final url =
          'https://api.diffbot.com/v3/article?url=$articleUrl&naturalLanguage=summary&token=$key';

      final result = await dio.get(url, cancelToken: cancel);

      if (result.statusCode == 200) {
        final objects = result.data["objects"] as List;

        if (objects.isEmpty) {
          Get.snackbar("Extraction Error", "No content found");
          return null;
        }

        final extractedData = objects[0];

        article.content = extractedData["text"] ?? "";
        article.summary = extractedData["naturalLanguage"]?["summary"] ?? "";

        return article;
      }
    } catch (e) {
      Get.snackbar("Extraction Error", "Failed to extract article: $e");
    }

    return null;
  }
}