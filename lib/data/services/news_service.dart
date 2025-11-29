import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../models/article.dart';

class NewsService {
  final key = 'ac28a32e200403e9526a2d26525c8ebf';
  final dio = Dio(
    BaseOptions(connectTimeout: 10.seconds, receiveTimeout: 10.seconds),
  );

  final cancel = CancelToken();

  void cancelRequest() {
    cancel.cancel();
  }

  /// Search news with pagination support
  Future<List<Article>?> showNews({
    required String search,
    int page = 1,
  }) async {
    final cleanQuery = search.trim();
    final url =
        'https://gnews.io/api/v4/search?apikey=$key&lang=ar&q=$cleanQuery&max=10&page=$page';

    developer.log('🔍 Searching for: $cleanQuery (Page: $page)');
    return await _fetchNews(url);
  }

  /// Get top headlines with pagination
  Future<List<Article>?> showTopHeadlinesNews({int page = 1}) async {
    final url =
        'https://gnews.io/api/v4/top-headlines?category=general&country=eg&max=10&page=$page&apikey=$key';

    developer.log('📰 Fetching top headlines (Page: $page)');
    return await _fetchNews(url);
  }

  /// Get news by category with pagination
  Future<List<Article>?> showNewsByCategory({
    required String category,
    int page = 1,
  }) async {
    final url =
        'https://gnews.io/api/v4/top-headlines?lang=ar&country=eg&category=$category&max=10&page=$page&apikey=$key';

    developer.log('📂 Fetching category: $category (Page: $page)');
    return await _fetchNews(url);
  }

  /// Unified fetch method with retry logic
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
          developer.log('✅ Response received');

          final data = result.data['articles'] as List?;

          if (data == null || data.isEmpty) {
            developer.log('⚠️ No articles found');
            return [];
          }

          developer.log('📰 Found ${data.length} articles');

          final articles = data.map<Article>((a) {
            try {
              return Article.fromJson(a);
            } catch (e) {
              developer.log('❌ Error parsing article: $e');
              rethrow;
            }
          }).toList();

          return articles;
        }
      } on DioException catch (e) {
        finalError = e;
        developer.log('❌ DioException: ${e.type} - ${e.message}');

        // Retry for connection issues
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

        // Handle specific errors
        if (e.response?.statusCode == 403) {
          developer.log('🚫 API Quota exceeded');
          Get.snackbar(
            'تجاوز الحد المسموح',
            'تم استهلاك عدد الطلبات اليومي للـ API',
            duration: const Duration(seconds: 4),
          );
          break;
        }

        if (e.response?.statusCode == 429) {
          developer.log('⏱️ Too many requests');
          Get.snackbar(
            'طلبات كثيرة',
            'الرجاء الانتظار قليلاً ثم المحاولة مرة أخرى',
          );
          break;
        }

        if (e.response?.statusCode == 400) {
          developer.log('⚠️ Bad Request - Invalid query');
          Get.snackbar(
            'خطأ في البحث',
            'الرجاء التحقق من كلمات البحث',
          );
          break;
        }
      } catch (e) {
        developer.log('❌ Unexpected error: $e');
      }
    }

    // All retries failed
    if (finalError != null) {
      developer.log('❌ All retries failed');
      Get.snackbar(
        "خطأ في الاتصال",
        "تحقق من الاتصال بالإنترنت",
      );
    }

    return null;
  }

  /// Check internet connection
  Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}