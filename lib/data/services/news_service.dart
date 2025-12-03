import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/article.dart';

class NewsService {

  //key1
  final key = 'ac28a32e200403e9526a2d26525c8ebf';

  //key 2
  //final key = 'e7e0c67889c6cd6ad4fce7276a6e9b34';
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
    String country = 'eg',
  }) async {
    final cleanQuery = search.trim();
    final url =
        'https://gnews.io/api/v4/search?apikey=$key&country=$country&q=$cleanQuery&max=10&page=$page';
    return await _fetchNews(url);
  }

  /// Get top headlines with pagination
  Future<List<Article>?> showTopHeadlinesNews({
    int page = 1,
    String country = 'eg',
  }) async {
    final url =
        'https://gnews.io/api/v4/top-headlines?category=general&country=$country&max=10&page=$page&apikey=$key';

    return await _fetchNews(url);
  }

  /// Get news by category with pagination
  Future<List<Article>?> showNewsByCategory({
    required String category,
    int page = 1,
    String country = 'eg',
  }) async {
    final url =
        'https://gnews.io/api/v4/top-headlines?country=$country&category=$category&max=10&page=$page&apikey=$key';

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
        final result = await dio.get(url, cancelToken: cancel);

        if (result.statusCode == 200) {

          final data = result.data['articles'] as List?;

          if (data == null || data.isEmpty) {
            return [];
          }


          final articles = data.map<Article>((a) {
            try {
              return Article.fromJson(a);
            } catch (e) {
              rethrow;
            }
          }).toList();

          return articles;
        }
      } on DioException catch (e) {
        finalError = e;
        // Retry for connection issues
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          if (attempt < retries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }

        if (e.response?.statusCode == 400) {
          Get.snackbar(
            'خطأ في البحث',
            'الرجاء التحقق من كلمات البحث',
          );
          break;
        }
        if (e.response?.statusCode == 403) {
          Get.snackbar(
            'تجاوز الحد المسموح',
            'تم استهلاك عدد الطلبات اليومي للـ API',
            duration: const Duration(seconds: 4),
          );
          break;
        }

        if (e.response?.statusCode == 429) {
          Get.snackbar(
            'طلبات كثيرة',
            'الرجاء الانتظار قليلاً ثم المحاولة مرة أخرى',
          );
          break;
        }

      } catch (e) {
        Get.snackbar('حدث خطأ', 'خطأ غير متوقع');
      }
    }

    // All retries failed
    if (finalError != null) {
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