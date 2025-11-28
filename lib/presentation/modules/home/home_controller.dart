import 'package:get/get.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/extraction_service.dart';
import 'package:mega_news_app/data/services/news_service.dart';

class HomeController extends GetxController {
  final newsService = NewsService();
  final extractionService = ExtractionService();

  // Observable variables
  RxList<Article> topHeadlines = <Article>[].obs;
  RxList<Article> searchResults = <Article>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxString selectedCategory = 'general'.obs;
  RxString searchQuery = ''.obs;
  RxBool showTimeline = false.obs;
  RxBool showCategories = false.obs;

  // Pagination
  int currentPage = 0;
  static const int pageSize = 10;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchTopHeadlines();
  }

  /// Fetch top headlines from API
  Future<void> fetchTopHeadlines() async {
    try {
      isLoading.value = true;
      currentPage = 0;

      final news = await newsService.showTopHeadlinesNews();

      if (news != null) {
        topHeadlines.assignAll(news);
        showTimeline.value = false;
      } else {
        Get.snackbar('خطأ', 'فشل تحميل الأخبار');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search for news by query
  Future<void> searchNews(String query) async {
    try {
      if (query.isEmpty) {
        searchResults.clear();
        searchQuery.value = '';
        showTimeline.value = false;
        return;
      }

      isLoading.value = true;
      searchQuery.value = query;
      currentPage = 0;

      final results = await newsService.showNews(search: query);

      if (results != null) {
        searchResults.assignAll(results);
        // Detect if should show as timeline (simplified logic)
        showTimeline.value = _shouldShowTimeline(query);
      } else {
        Get.snackbar('لا توجد نتائج', 'لم نجد أخبار عن "$query"');
        searchResults.clear();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل البحث: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter news by category
  Future<void> filterByCategory(String category) async {
    try {
      isLoading.value = true;
      selectedCategory.value = category;
      currentPage = 0;

      final news = await newsService.showNewsByCategory(category: category);

      if (news != null) {
        searchResults.assignAll(news);
        showTimeline.value = false;
      } else {
        Get.snackbar('خطأ', 'فشل تحميل الأخبار من هذه الفئة');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more results for pagination
  Future<void> loadMoreResults() async {
    if (isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      List<Article>? moreNews;

      if (searchQuery.value.isNotEmpty) {
        // Load more search results
        moreNews = await newsService.showNews(search: searchQuery.value);
      } else if (selectedCategory.value != 'general') {
        // Load more from category
        moreNews = await newsService.showNewsByCategory(
          category: selectedCategory.value,
        );
      } else {
        // Load more top headlines
        moreNews = await newsService.showTopHeadlinesNews();
      }

      if (moreNews != null && moreNews.isNotEmpty) {
        searchQuery.value.isEmpty
            ? topHeadlines.addAll(moreNews)
            : searchResults.addAll(moreNews);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المزيد: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Extract article body using Diffbot
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

  /// Simple timeline detection logic
  bool _shouldShowTimeline(String query) {
    // إذا كان البحث قصير (اسم شخص أو حدث) → timeline
    final words = query.trim().split(' ');
    return words.length <= 2 && query.length < 20;
  }

  /// Get current news list based on context
  List<Article> get currentNewsList {
    return searchQuery.value.isEmpty ? topHeadlines : searchResults;
  }

  @override
  void onClose() {
    newsService.cancelRequest();
    extractionService.cancelRequest();
    super.onClose();
  }
}