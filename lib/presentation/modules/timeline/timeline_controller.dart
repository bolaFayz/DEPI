import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/cache_manager.dart';
import 'package:mega_news_app/data/services/extraction_service.dart';
import 'package:mega_news_app/data/services/database_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TimelineArticle {
  final Article article;
  bool hasSummary;
  bool isExtracting;
  String? extractedSummary;
  String? extractError;

  TimelineArticle({
    required this.article,
    this.hasSummary = false,
    this.isExtracting = false,
    this.extractedSummary,
    this.extractError,
  });

  bool get showSummary =>
      hasSummary && extractedSummary != null && extractedSummary!.isNotEmpty;
  bool get canExtract => !hasSummary && !isExtracting && extractError == null;
  String get displayText => extractedSummary ?? article.description;

  int get estimatedReadTimeMinutes {
    if (extractedSummary == null) return 1;
    final words = extractedSummary!.split(' ').length;
    return (words / 180).ceil().clamp(1, 10);
  }
}

class TimelineDay {
  final DateTime date;
  final List<TimelineArticle> articles;

  TimelineDay({
    required this.date,
    required this.articles,
  });

  int get totalArticles => articles.length;
  int get articlesWithSummary => articles.where((a) => a.hasSummary).length;
  int get extractionProgress => totalArticles > 0
      ? (articlesWithSummary / totalArticles * 100).round()
      : 0;

  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays == 2) {
      return 'منذ يومين';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String get fullDate {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class TimelineData {
  final String searchQuery;
  final List<TimelineDay> days;

  TimelineData({
    required this.searchQuery,
    required this.days,
  });

  int get totalArticles => days.fold(0, (sum, day) => sum + day.totalArticles);
  int get totalDays => days.length;
  int get articlesWithSummary =>
      days.fold(0, (sum, day) => sum + day.articlesWithSummary);

  int get overallProgress => totalArticles > 0
      ? (articlesWithSummary / totalArticles * 100).round()
      : 0;

  DateTime? get earliestDate => days.isEmpty ? null : days.last.date;
  DateTime? get latestDate => days.isEmpty ? null : days.first.date;

  bool get isEmpty => days.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class TimelineController extends GetxController {
  final cacheManager = CacheManager();
  final extractionService = ExtractionService();
  final dbService = DatabaseService.instance;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedCountry = 'eg'.obs;

  final timelineData = Rxn<TimelineData>();
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  int currentPage = 1;
  bool hasMoreData = true;
  final maxPages = 5;

  final isExtractingBatch = false.obs;
  final extractionQueue = <TimelineArticle>[].obs;

  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _loadDefaultCountry();
  }

  @override
  void onClose() {
    _isDisposed = true;
    searchController.dispose();
    cacheManager.cancelRequests();
    extractionService.cancelRequest();
    super.onClose();
  }

  void _loadDefaultCountry() {
    try {
      final storage = Get.find<dynamic>();
      final saved = storage.read('defaultCountry');
      if (saved != null) {
        selectedCountry.value = saved;
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> searchTimeline(String query) async {
    if (_isDisposed) return;

    if (query.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'الرجاء إدخال كلمة بحث',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      searchQuery.value = query.trim();
      currentPage = 1;
      hasMoreData = true;

      final articles = await cacheManager.searchArticles(
        query: query.trim(),
        country: selectedCountry.value,
        page: 1,
      );

      if (_isDisposed) return;

      if (articles != null && articles.isNotEmpty) {
        final timeline = await _buildTimeline(query.trim(), articles);

        if (!_isDisposed) {
          timelineData.value = timeline;
        }
      } else {
        if (!_isDisposed) {
          timelineData.value = null;

          Get.snackbar(
            'لا توجد نتائج',
            'لم نجد أخبار عن "$query"',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        Get.snackbar(
          'خطأ',
          'فشل البحث: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreArticles() async {
    if (_isDisposed || isLoadingMore.value || !hasMoreData || currentPage >= maxPages) {
      return;
    }

    if (searchQuery.value.isEmpty) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final moreArticles = await cacheManager.searchArticles(
        query: searchQuery.value,
        country: selectedCountry.value,
        page: currentPage,
      );

      if (_isDisposed) return;

      if (moreArticles != null && moreArticles.isNotEmpty) {
        await _mergeArticlesIntoTimeline(moreArticles);
      } else {
        hasMoreData = false;
      }
    } catch (e) {
      // Ignore
    } finally {
      if (!_isDisposed) {
        isLoadingMore.value = false;
      }
    }
  }

  Future<TimelineData> _buildTimeline(String query, List<Article> articles) async {
    if (_isDisposed) {
      return TimelineData(searchQuery: query, days: []);
    }

    try {
      articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      final Map<String, List<Article>> grouped = {};

      for (var article in articles) {
        final dateKey = _getDateKey(article.publishedAt);
        grouped[dateKey] = grouped[dateKey] ?? [];
        grouped[dateKey]!.add(article);
      }

      final days = <TimelineDay>[];

      for (var entry in grouped.entries) {
        if (_isDisposed) break;

        final date = DateTime.parse(entry.key);
        final dayArticles = <TimelineArticle>[];

        for (var article in entry.value) {
          if (_isDisposed) break;

          try {
            final fullArticle = await dbService.articleDao.getArticleById(article.id);

            if (_isDisposed) break;

            if (fullArticle != null &&
                fullArticle.summary != null &&
                fullArticle.summary!.isNotEmpty) {
              dayArticles.add(TimelineArticle(
                article: article,
                hasSummary: true,
                extractedSummary: fullArticle.summary,
              ));
            } else {
              dayArticles.add(TimelineArticle(
                article: article,
                hasSummary: false,
                extractedSummary: null,
              ));
            }
          } catch (e) {
            if (!_isDisposed) {
              dayArticles.add(TimelineArticle(
                article: article,
                hasSummary: false,
                extractedSummary: null,
              ));
            }
          }
        }

        if (!_isDisposed && dayArticles.isNotEmpty) {
          days.add(TimelineDay(date: date, articles: dayArticles));
        }
      }

      days.sort((a, b) => b.date.compareTo(a.date));

      return TimelineData(searchQuery: query, days: days);
    } catch (e) {
      return TimelineData(searchQuery: query, days: []);
    }
  }

  Future<void> _mergeArticlesIntoTimeline(List<Article> newArticles) async {
    if (_isDisposed || timelineData.value == null) return;

    try {
      final currentTimeline = timelineData.value!;
      final allArticles = <Article>[];

      for (var day in currentTimeline.days) {
        allArticles.addAll(day.articles.map((ta) => ta.article));
      }

      for (var article in newArticles) {
        if (!allArticles.any((a) => a.id == article.id)) {
          allArticles.add(article);
        }
      }

      final updatedTimeline = await _buildTimeline(
        currentTimeline.searchQuery,
        allArticles,
      );

      if (!_isDisposed) {
        timelineData.value = updatedTimeline;
      }
    } catch (e) {
      // Ignore
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ✅ FIXED: استخراج الملخص - نفس طريقة news_details_controller
  Future<void> extractSummary(TimelineArticle article) async {
    if (_isDisposed || article.isExtracting) return;

    try {
      // ✅ Check internet first
      final hasInternet = await _checkInternet();

      if (_isDisposed) return;

      if (!hasInternet) {
        Get.snackbar(
          'لا يوجد اتصال',
          'يجب الاتصال بالإنترنت لاستخراج الملخص',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange[700],
          colorText: Colors.white,
          icon: const Icon(Icons.wifi_off, color: Colors.white),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      article.isExtracting = true;
      article.extractError = null;
      update();

      // ✅ Check cache first using getArticleById
      final fullArticle = await dbService.articleDao.getArticleById(article.article.id);

      if (_isDisposed) return;

      if (fullArticle != null &&
          fullArticle.summary != null &&
          fullArticle.summary!.isNotEmpty) {
        article.extractedSummary = fullArticle.summary;
        article.hasSummary = true;
        article.isExtracting = false;
        update();

        if (!_isDisposed) {
          Get.snackbar(
            'تم التحميل',
            'الملخص محفوظ مسبقاً',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green[600],
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
        return;
      }

      // ✅ Extract from web with retry logic
      Article? extracted;
      int retries = 0;
      const maxRetries = 2;

      while (retries <= maxRetries && extracted == null && !_isDisposed) {
        try {
          extracted = await extractionService.extractArticleBody(
            articleUrl: article.article.url,
            article: article.article,
          );

          if (_isDisposed) return;

          if (extracted != null) break;

        } catch (e) {
          if (_isDisposed) return;

          retries++;

          if (retries <= maxRetries && !_isDisposed) {
            await Future.delayed(Duration(seconds: 2 * retries));
          }
        }
      }

      if (_isDisposed) return;

      if (extracted?.summary != null && extracted!.summary!.isNotEmpty) {
        article.extractedSummary = extracted.summary;
        article.hasSummary = true;

        // ✅ Save to cache
        await _saveSummaryToCache(
          article.article.id,
          extracted.summary!,
          extracted.content.isNotEmpty ? extracted.content : 'لا يوجد محتوى إضافي',
        );

        if (!_isDisposed) {
          Get.snackbar(
            'تم الاستخراج بنجاح',
            'تم استخراج الملخص وحفظه',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green[600],
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      } else {
        article.extractError = 'فشل الاستخراج';

        if (!_isDisposed) {
          Get.snackbar(
            'فشل الاستخراج',
            'لم نتمكن من استخراج ملخص لهذه المقالة. حاول مرة أخرى لاحقاً',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red[600],
            colorText: Colors.white,
            icon: const Icon(Icons.error_outline, color: Colors.white),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        article.extractError = e.toString();

        Get.snackbar(
          'خطأ في الاستخراج',
          'حدث خطأ أثناء استخراج الملخص. حاول مرة أخرى',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } finally {
      if (!_isDisposed) {
        article.isExtracting = false;
        update();
      }
    }
  }

  Future<void> _saveSummaryToCache(String articleId, String summary, String content) async {
    if (_isDisposed) return;

    try {
      await dbService.articleDao.updateArticleSummary(
        articleId,
        summary,
        content,
      );
    } catch (e) {
      // Ignore - extraction still worked
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  Future<void> extractAllSummaries() async {
    if (_isDisposed || timelineData.value == null || isExtractingBatch.value) return;

    try {
      isExtractingBatch.value = true;

      final allArticles = <TimelineArticle>[];
      for (var day in timelineData.value!.days) {
        allArticles.addAll(day.articles);
      }

      final toExtract = allArticles
          .where((a) => !a.hasSummary && !a.isExtracting)
          .toList();

      if (toExtract.isEmpty) {
        Get.snackbar(
          'تم الاستخراج',
          'جميع الملخصات موجودة بالفعل',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      extractionQueue.assignAll(toExtract);

      Get.snackbar(
        'جاري الاستخراج',
        'سيتم استخراج ${toExtract.length} ملخص',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.blue[600],
        colorText: Colors.white,
      );

      // ✅ Extract in sequence
      for (var article in toExtract) {
        if (_isDisposed) break;

        await extractSummary(article);
        extractionQueue.remove(article);

        // Delay between extractions
        await Future.delayed(const Duration(seconds: 3));
      }

      if (!_isDisposed) {
        Get.snackbar(
          'تم الاستخراج',
          'تم استخراج جميع الملخصات بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
      }

    } catch (e) {
      // Ignore
    } finally {
      if (!_isDisposed) {
        isExtractingBatch.value = false;
        extractionQueue.clear();
      }
    }
  }

  void clearTimeline() {
    if (_isDisposed) return;

    searchQuery.value = '';
    searchController.clear();
    timelineData.value = null;
    currentPage = 1;
    hasMoreData = true;
  }
}