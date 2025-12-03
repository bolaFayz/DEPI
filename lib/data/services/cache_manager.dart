import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/database_service.dart';
import 'package:mega_news_app/data/services/news_service.dart';

class CacheManager {
  final DatabaseService _dbService = DatabaseService.instance;
  final NewsService _newsService = NewsService();

  static const Duration cacheExpiry = Duration(hours: 6);
  static const int maxRetries = 2;

  // TOP HEADLINES
  Future<List<Article>?> getTopHeadlines({
    required String country,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final hasInternet = await _newsService.isConnected();

      final cachedArticles = await _dbService.getTopHeadlinesPaginated(
        country: country,
        page: page,
        limit: 10,
      );

      if (!hasInternet) {
        if (cachedArticles.isEmpty) {
          _showOfflineMessage();
        }
        return cachedArticles;
      }

      if (forceRefresh) {
        if (page == 1) {
          await _dbService.clearCacheByCountry(country);
        }
        return await _fetchAndCache(country, page, 'headlines');
      }

      if (page == 1 && cachedArticles.isNotEmpty) {
        final isFresh = await _dbService.isCacheFresh(
          country: country,
          maxAge: cacheExpiry,
        );

        if (isFresh) {
          _updateInBackground(() => _fetchAndCache(country, 1, 'headlines'));
          return cachedArticles;
        }
      }

      if (page > 1 && cachedArticles.length >= 10) {
        _updateInBackground(() => _fetchAndCache(country, page, 'headlines'));
        return cachedArticles;
      }

      final freshArticles = await _fetchAndCache(country, page, 'headlines');
      return freshArticles ?? cachedArticles;
    } catch (e) {
      final fallback = await _dbService.getTopHeadlinesPaginated(
        country: country,
        page: page,
        limit: 10,
      );
      return fallback;
    }
  }

  // ============================================
  // CATEGORY
  // ============================================

  Future<List<Article>?> getArticlesByCategory({
    required String category,
    required String country,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final hasInternet = await _newsService.isConnected();

      final cachedArticles = await _dbService.getArticlesByCategoryPaginated(
        category: category,
        country: country,
        page: page,
        limit: 10,
      );

      if (!hasInternet) {
        if (cachedArticles.isEmpty) {
          _showOfflineMessage();
        }
        return cachedArticles;
      }

      if (forceRefresh) {
        if (page == 1) {
          await _dbService.clearCacheByCategory(category);
        }
        return await _fetchAndCache(
          country,
          page,
          'category',
          category: category,
        );
      }

      if (cachedArticles.isNotEmpty) {
        if (page == 1) {
          _updateInBackground(
            () => _fetchAndCache(country, 1, 'category', category: category),
          );
        }
        return cachedArticles;
      }

      final fresh = await _fetchAndCache(
        country,
        page,
        'category',
        category: category,
      );
      return fresh ?? cachedArticles;
    } catch (e) {
      final fallback = await _dbService.getArticlesByCategoryPaginated(
        category: category,
        country: country,
        page: page,
        limit: 10,
      );
      return fallback;
    }
  }

  // ============================================
  // SEARCH
  // ============================================

  Future<List<Article>?> searchArticles({
    required String query,
    required String country,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final hasInternet = await _newsService.isConnected();

      final cachedResults = await _dbService.searchArticlesPaginated(
        query: query,
        country: country,
        page: page,
        limit: 30,
      );

      if (!hasInternet) {
        if (cachedResults.isEmpty) {
          _showOfflineMessage();
        }
        return cachedResults;
      }

      if (cachedResults.isNotEmpty && !forceRefresh) {
        if (page == 1) {
          _updateInBackground(
            () => _fetchAndCache(country, 1, 'search', query: query),
          );
        }
        return cachedResults;
      }

      final fresh = await _fetchAndCache(country, page, 'search', query: query);
      return fresh ?? cachedResults;
    } catch (e) {
      return await _dbService.searchArticlesPaginated(
        query: query,
        country: country,
        page: page,
        limit: 30,
      );
    }
  }

  // ============================================
  // UNIFIED FETCH & CACHE
  // ============================================

  Future<List<Article>?> _fetchAndCache(
    String country,
    int page,
    String type, {
    String? category,
    String? query,
  }) async {
    List<Article>? articles;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (type == 'headlines') {
          articles = await _newsService.showTopHeadlinesNews(
            country: country,
            page: page,
          );
        } else if (type == 'category' && category != null) {
          articles = await _newsService.showNewsByCategory(
            category: category,
            country: country,
            page: page,
          );
        } else if (type == 'search' && query != null) {
          articles = await _newsService.showNews(
            search: query,
            country: country,
            page: page,
          );
        }

        if (articles != null) break;

        if (attempt < maxRetries - 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        if (attempt == maxRetries - 1) {
          return null;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (articles != null && articles.isNotEmpty) {
      await _dbService.saveArticles(
        articles,
        category: category,
        country: country,
      );
    }

    return articles;
  }

  // BACKGROUND UPDATE
  void _updateInBackground(Future<List<Article>?> Function() updateFn) {
    Future.delayed(Duration.zero, () async {
      await updateFn();
    });
  }

  void _showOfflineMessage() {
    Get.snackbar(
      'لا يوجد اتصال بالإنترنت',
      'لا توجد بيانات محفوظة',
      icon: const Icon(Icons.wifi_off, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.orange[700],
      colorText: Colors.white,
    );
  }

  Future<void> cleanOldCache() async {
    await _dbService.cleanOldCache(daysOld: 30);
  }

  void cancelRequests() {
    _newsService.cancelRequest();
  }
}
