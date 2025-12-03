import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/cache_manager.dart';
import 'package:mega_news_app/data/services/extraction_service.dart';

class HomeController extends GetxController {
  final cacheManager = CacheManager();
  final extractionService = ExtractionService();

  final searchController = TextEditingController();

  // Observable variables
  final displayedArticles = <Article>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final selectedCategory = 'general'.obs;
  final searchQuery = ''.obs;
  final showCategories = false.obs;
  final showAdvancedSearch = false.obs;
  final selectedCountry = 'eg'.obs;

  // ✅ NEW: Search Mode
  final isSearchMode = false.obs;

  // Pagination
  int currentPage = 1;
  final maxPages = 10;
  bool hasMoreData = true;

  // Country-Language mapping with flags
  final countryLanguageMap = {
    'eg': {'name': 'مصر 🇪🇬', 'lang': 'ar'},
    'us': {'name': 'الولايات المتحدة 🇺🇸', 'lang': 'en'},
    'gb': {'name': 'المملكة المتحدة 🇬🇧', 'lang': 'en'},
    'au': {'name': 'أستراليا 🇦🇺', 'lang': 'en'},
    'ca': {'name': 'كندا 🇨🇦', 'lang': 'en'},
    'fr': {'name': 'فرنسا 🇫🇷', 'lang': 'fr'},
    'de': {'name': 'ألمانيا 🇩🇪', 'lang': 'de'},
    'es': {'name': 'إسبانيا 🇪🇸', 'lang': 'es'},
    'it': {'name': 'إيطاليا 🇮🇹', 'lang': 'it'},
    'pt': {'name': 'البرتغال 🇵🇹', 'lang': 'pt'},
    'br': {'name': 'البرازيل 🇧🇷', 'lang': 'pt'},
    'nl': {'name': 'هولندا 🇳🇱', 'lang': 'nl'},
    'ru': {'name': 'روسيا 🇷🇺', 'lang': 'ru'},
    'tr': {'name': 'تركيا 🇹🇷', 'lang': 'tr'},
    'cn': {'name': 'الصين 🇨🇳', 'lang': 'zh'},
    'jp': {'name': 'اليابان 🇯🇵', 'lang': 'ja'},
    'in': {'name': 'الهند 🇮🇳', 'lang': 'hi'},
    'il': {'name': 'إسرائيل 🇮🇱', 'lang': 'he'},
    'gr': {'name': 'اليونان 🇬🇷', 'lang': 'el'},
    'no': {'name': 'النرويج 🇳🇴', 'lang': 'no'},
    'se': {'name': 'السويد 🇸🇪', 'lang': 'sv'},
    'ua': {'name': 'أوكرانيا 🇺🇦', 'lang': 'uk'},
    'ro': {'name': 'رومانيا 🇷🇴', 'lang': 'ro'},
    'id': {'name': 'إندونيسيا 🇮🇩', 'lang': 'id'},
  };

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchTopHeadlines();
  }

  @override
  void onClose() {
    searchController.dispose();
    cacheManager.cancelRequests();
    extractionService.cancelRequest();
    super.onClose();
  }

  // ============================================
  // ✅ SEARCH MODE METHODS
  // ============================================

  /// Enter search mode
  void enterSearchMode() {
    isSearchMode.value = true;
    searchController.clear();
    searchQuery.value = '';
  }

  /// Exit search mode and return to normal view
  void exitSearchMode() {
    isSearchMode.value = false;
    showAdvancedSearch.value = false;
    searchController.clear();
    searchQuery.value = '';
    selectedCategory.value = 'general';
    currentPage = 1;
    hasMoreData = true;
    displayedArticles.clear();
    fetchTopHeadlines();
  }

  // Clear search text only (keep search mode active)
  void clearSearchText() {
    searchController.clear();
    searchQuery.value = '';
  }

  // Toggle advanced search visibility
  void toggleAdvancedSearch() {
    showAdvancedSearch.value = !showAdvancedSearch.value;
  }

  // ============================================
  // DATA FETCHING
  // ============================================

  /// ✅ NEW: Apply Country Filter While Maintaining Category
  Future<void> applyCountryFilterWithCategory() async {
    try {
      currentPage = 1;
      hasMoreData = true;

      // ✅ CRITICAL FIX: Check current category and fetch accordingly
      if (selectedCategory.value == 'general') {
        // Fetch headlines
        await fetchTopHeadlines();
      } else {
        // Fetch category with new country
        await filterByCategory(selectedCategory.value);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تطبيق الفلتر');
    }
  }

  /// Change selected country
  void selectCountry(String countryCode) {
    selectedCountry.value = countryCode;
    currentPage = 1;
    hasMoreData = true;
    displayedArticles.clear();
    fetchTopHeadlines();
  }

  /// Fetch top headlines
  Future<void> fetchTopHeadlines({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      currentPage = 1;
      hasMoreData = true;

      final news = await cacheManager.getTopHeadlines(
        country: selectedCountry.value,
        page: 1,
        forceRefresh: forceRefresh,
      );

      if (news != null && news.isNotEmpty) {
        displayedArticles.assignAll(news);
      } else {
        Get.snackbar('خطأ'.tr, 'فشل تحميل الأخبار'.tr);
        displayedArticles.clear();
      }
    } catch (e) {
      Get.snackbar('خطأ'.tr, 'حدث خطأ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search for news
  Future<void> searchNews(String query) async {
    try {
      if (query.trim().isEmpty) {
        return;
      }

      isLoading.value = true;
      searchQuery.value = query.trim();
      currentPage = 1;
      hasMoreData = true;

      final results = await cacheManager.searchArticles(
        query: query.trim(),
        country: selectedCountry.value,
        page: 1,
      );

      if (results != null && results.isNotEmpty) {
        displayedArticles.assignAll(results);
      } else {
        Get.snackbar('لا توجد نتائج'.tr, 'لم نجد أخبار عن "$query"');
        displayedArticles.clear();
      }
    } catch (e) {
      Get.snackbar('خطأ'.tr, 'فشل البحث'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter news by category
  Future<void> filterByCategory(String category) async {
    try {
      if (selectedCategory.value == category && searchQuery.value.isEmpty) {
        return;
      }

      isLoading.value = true;
      selectedCategory.value = category;
      searchQuery.value = '';
      searchController.clear();
      currentPage = 1;
      hasMoreData = true;

      List<Article>? news;

      if (category == 'general') {
        news = await cacheManager.getTopHeadlines(
          country: selectedCountry.value,
          page: 1,
        );
      } else {
        news = await cacheManager.getArticlesByCategory(
          category: category,
          country: selectedCountry.value,
          page: 1,
        );
      }

      if (news != null && news.isNotEmpty) {
        displayedArticles.assignAll(news);
      } else {
        displayedArticles.clear();

        if (news == null) {
          Get.snackbar('خطأ'.tr, 'فشل تحميل الأخبار'.tr);
        } else {
          Get.snackbar(
            'لا توجد أخبار'.tr,
            'لا توجد أخبار في هذه الفئة حاليًا'.tr,
          );
        }
      }
    } catch (e) {
      Get.snackbar('خطأ'.tr, 'حدث خطأ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more results (pagination)
  Future<void> loadMoreResults() async {
    if (isLoadingMore.value || !hasMoreData || currentPage >= maxPages) {
      return;
    }

    try {
      isLoadingMore.value = true;
      currentPage++;
      List<Article>? moreNews;

      if (searchQuery.value.isNotEmpty) {
        moreNews = await cacheManager.searchArticles(
          query: searchQuery.value,
          country: selectedCountry.value,
          page: currentPage,
        );
      } else if (selectedCategory.value != 'general') {
        moreNews = await cacheManager.getArticlesByCategory(
          category: selectedCategory.value,
          country: selectedCountry.value,
          page: currentPage,
        );
      } else {
        moreNews = await cacheManager.getTopHeadlines(
          country: selectedCountry.value,
          page: currentPage,
        );
      }

      if (moreNews != null && moreNews.isNotEmpty) {
        final uniqueNews = moreNews.where((newArticle) {
          return !displayedArticles.any(
            (existing) => existing.id == newArticle.id,
          );
        }).toList();

        if (uniqueNews.isNotEmpty) {
          displayedArticles.addAll(uniqueNews);
        } else {
          hasMoreData = false;
        }
      } else {
        hasMoreData = false;
      }

      if (currentPage >= maxPages) {
        hasMoreData = false;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المزيد: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh current view (Pull-to-Refresh)
  Future<void> refreshCurrentView() async {
    if (searchQuery.value.isNotEmpty) {
      await searchNews(searchQuery.value);
    } else if (selectedCategory.value != 'general') {
      await filterByCategory(selectedCategory.value);
    } else {
      await fetchTopHeadlines(forceRefresh: true);
    }
  }

  /// Extract article body using ExtractionService
  Future<Article?> extractArticleBody(Article article) async {
    try {
      final extracted = await extractionService.extractArticleBody(
        articleUrl: article.url,
        article: article,
      );
      return extracted;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل استخراج المحتوى: $e');
      return null;
    }
  }
}
