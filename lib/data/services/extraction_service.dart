import 'package:dio/dio.dart';
import '../models/article.dart';

class ExtractionService {
  final diffbotKey = '1e5c59e690cd0d8c3af63ba2bb42e009';

  late final Dio dio;
  CancelToken? _currentCancelToken;

  // ✅ CRITICAL: Prevent multiple error snackbars
  bool _isShowingError = false;

  ExtractionService() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
  }

  /// ✅ Cancel current request
  void cancelRequest() {
    if (_currentCancelToken != null && !_currentCancelToken!.isCancelled) {
      _currentCancelToken!.cancel('Request cancelled by user');
    }
    _currentCancelToken = null;
    _isShowingError = false; // Reset error flag
  }

  /// ✅ FIXED: Extract with proper error handling
  Future<Article?> extractArticleBody({
    required String articleUrl,
    required Article article,
  }) async {
    // Cancel any existing request first
    cancelRequest();

    // Create new cancel token
    _currentCancelToken = CancelToken();

    try {
      final encodedUrl = Uri.encodeComponent(articleUrl);
      final url =
          'https://api.diffbot.com/v3/article?url=$encodedUrl&naturalLanguage=summary&token=$diffbotKey';

      final result = await dio.get(
        url,
        cancelToken: _currentCancelToken,
      );

      // Check if cancelled
      if (_currentCancelToken?.isCancelled ?? false) {
        return null;
      }

      if (result.statusCode == 200) {
        final objects = result.data["objects"] as List?;
        if (objects == null || objects.isEmpty) {
          return null;
        }

        final extractedData = objects[0];
        final extractedText = extractedData["text"] ?? "";
        final extractedSummary = extractedData["naturalLanguage"]?["summary"] ?? "";

        if (extractedText.isEmpty || extractedSummary.isEmpty) {
          return null;
        }

        article.content = extractedText;
        article.summary = extractedSummary;

        return article;
      } else {
        return null;
      }
    } on DioException catch (e) {
      // ✅ CRITICAL: Don't show ANY snackbar if cancelled or already showing error
      if (e.type == DioExceptionType.cancel) {
        return null;
      }

      // ✅ Prevent multiple error messages
      if (_isShowingError) {
        return null;
      }

      // ✅ Only throw exception - let controller handle UI
      if (e.response?.statusCode == 403) {
        throw Exception('API_LIMIT_EXCEEDED');
      } else if (e.response?.statusCode == 429) {
        throw Exception('RATE_LIMIT');
      } else if (e.response?.statusCode == 400) {
        throw Exception('INVALID_REQUEST');
      }

      throw Exception('EXTRACTION_FAILED');

    } catch (e) {
      // Only throw if not cancelled
      if (!(_currentCancelToken?.isCancelled ?? false)) {
        throw Exception('EXTRACTION_ERROR');
      }
    }

    return null;
  }

  /// Dispose resources
  void dispose() {
    cancelRequest();
    dio.close();
  }
}