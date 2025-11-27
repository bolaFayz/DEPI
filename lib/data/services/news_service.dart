import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../models/article.dart';
import 'cache_helper.dart';

class NewsService {
  final key = 'ac28a32e200403e9526a2d26525c8ebf';
  final dio = Dio(
    BaseOptions(connectTimeout: 10.seconds, receiveTimeout: 10.seconds),
  );

  final cancel = CancelToken();

  void cancelRequest(){
    cancel.cancel();
  }

  Future<List<Article>?> showNews({required String search}) async {
    final url =
        'https://gnews.io/api/v4/search?apikey=$key&lang=ar&q="$search"&max=10';
    return await _fetchNews(url);
  }

  Future<List<Article>?> showTopHeadlinesNews() async {
    final url =
        'https://gnews.io/api/v4/top-headlines?category=general&country=eg&max=10&apikey=$key';
    return await _fetchNews(url);
  }

  Future<List<Article>?> showNewsByCategory({required String category}) async {
    final url =
        'https://gnews.io/api/v4/top-headlines?&lang=ar&country=eg&category=$category&apikey=$key';
    return await _fetchNews(url);
  }

  Future<List<Article>?> _fetchNews(
      String url, {
        int retries = 2,
        Duration retryDelay = const Duration(seconds: 2),
      }) async {
    DioException? finalError;

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        developer.log('📡 Attempting request: $url (Attempt ${attempt + 1})');

        final result = await dio.get(url, cancelToken: cancel);

        if (result.statusCode == 200) {
          developer.log('✅ Response received: ${result.data}');

          final data = result.data['articles'] as List;

          if (data.isEmpty) {
            developer.log('⚠️ Articles list is empty');
            return [];
          }

          developer.log('📰 Found ${data.length} articles');

          final articles = data.map<Article>((a) {
            try {
              return Article.fromJson(a);
            } catch (e) {
              developer.log('❌ Error parsing article: $e');
              developer.log('Article data: $a');
              rethrow;
            }
          }).toList();

          return articles;
        }
      } on DioException catch (e) {
        finalError = e;
        developer.log('❌ DioException: ${e.type} - ${e.message}');
        developer.log('Response: ${e.response?.data}');

        // Errors that are worth retrying
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          if (attempt < retries) {
            developer.log('🔄 Retrying...');
            await Future.delayed(retryDelay);
            continue;
          }
        }

        // Handle specific status codes
        if (e.response?.statusCode == 403) {
          developer.log('🚫 Forbidden - Quota limit reached');
          Get.snackbar(
            'ممنوع',
            'تم تجاوز الحد المسموح به اليومي',
          );
          break;
        }

        if (e.response?.statusCode == 429) {
          developer.log('⏱️ Too many requests');
          Get.snackbar(
            'عدد طلبات كثير',
            'يرجى الانتظار قليلاً ثم المحاولة مجدداً',
          );
          break;
        }

        if (e.response?.statusCode == 503) {
          developer.log('🔧 Service unavailable');
          Get.snackbar(
            'الخدمة غير متاحة',
            'السيرفر قيد الصيانة',
          );
          break;
        }
      } catch (e) {
        developer.log('❌ Unexpected error: $e');
      }
    }

    // بعد كل المحاولات ولسه فشل
    if (finalError != null) {
      developer.log('❌ All retries failed');
      Get.snackbar(
        "خطأ في الاتصال",
        "تحقق من الاتصال بالإنترنت",
      );
    }

    return null;
  }

  Future<Article?> extractArticleBody({
    required String articleUrl,
    required Article article,
  }) async {
    try {
      final url = 'https://api.diffbot.com/v3/article?url=$articleUrl&naturalLanguage=summary&token=$key';

      developer.log('🔗 Extracting article from: $articleUrl');

      final result = await dio.get(url);

      if (result.statusCode == 200) {
        developer.log('✅ Article extracted successfully');

        final objects = result.data["objects"] as List;
        if (objects.isEmpty) {
          developer.log('⚠️ No extracted data found');
          return null;
        }

        final extractedData = objects[0];
        article.content = extractedData["text"] ?? "";
        article.summary = extractedData["naturalLanguage"]?["summary"] ?? "";

        return article;
      }
    } catch (e) {
      developer.log('❌ Extraction error: $e');
    }

    return null;
  }

  Future<bool> connected() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}