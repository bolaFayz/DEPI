import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/extraction_service.dart';
import 'package:mega_news_app/data/services/news_service.dart';

class HomeController extends GetxController {
  final newsService = NewsService();
  final extractionService = ExtractionService();

  // Observable variables
  final displayedArticles = <Article>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final selectedCategory = 'general'.obs;
  final searchQuery = ''.obs;
  final showCategories = false.obs;

  // Pagination - tracking what page we're on (Max 10 pages = 100 articles)
  int currentPage = 1;
  final maxPages = 10; // 10 * 10 = 100 articles max
  bool hasMoreData = true;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchTopHeadlines();
  }

  /// Fetch top headlines from API
  Future<void> fetchTopHeadlines() async {
    try {
      isLoading.value = true;
      currentPage = 1;
      hasMoreData = true;

      final news = await newsService.showTopHeadlinesNews(page: 1);

      if (news != null && news.isNotEmpty) {
        displayedArticles.assignAll(news);
        developer.log('✅ Loaded ${news.length} top headlines');
      } else {
        Get.snackbar('خطأ', 'فشل تحميل الأخبار');
        displayedArticles.clear();
      }
    } catch (e) {
      developer.log('❌ Error fetching headlines: $e');
      Get.snackbar('خطأ', 'حدث خطأ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search for news by query
  Future<void> searchNews(String query) async {
    try {
      if (query.trim().isEmpty) {
        clearSearch();
        return;
      }

      isLoading.value = true;
      searchQuery.value = query.trim();
      currentPage = 1;
      hasMoreData = true;

      final results = await newsService.showNews(
        search: query.trim(),
        page: 1,
      );

      if (results != null && results.isNotEmpty) {
        displayedArticles.assignAll(results);
        developer.log('✅ Found ${results.length} search results for: $query');
      } else {
        Get.snackbar('لا توجد نتائج', 'لم نجد أخبار عن "$query"');
        displayedArticles.clear();
      }
    } catch (e) {
      developer.log('❌ Error searching news: $e');
      Get.snackbar('خطأ', 'فشل البحث: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear search and return to headlines
  void clearSearch() {
    searchQuery.value = '';
    selectedCategory.value = 'general';
    currentPage = 1;
    hasMoreData = true;
    displayedArticles.clear();
    fetchTopHeadlines();
  }

  /// Filter news by category
  Future<void> filterByCategory(String category) async {
    try {
      // إذا كان نفس الـ Category، متعملش حاجة
      if (selectedCategory.value == category && searchQuery.value.isEmpty) {
        return;
      }

      isLoading.value = true;
      selectedCategory.value = category;
      searchQuery.value = ''; // Clear search
      currentPage = 1;
      hasMoreData = true;

      List<Article>? news;

      if (category == 'general') {
        // لو اختار "الكل" ارجع للـ Top Headlines
        news = await newsService.showTopHeadlinesNews(page: 1);
      } else {
        // لو اختار category معينة
        news = await newsService.showNewsByCategory(
          category: category,
          page: 1,
        );
      }

      if (news != null && news.isNotEmpty) {
        displayedArticles.assignAll(news);
        developer.log('✅ Loaded ${news.length} articles for category: $category');
      } else {
        Get.snackbar('لا توجد أخبار', 'لا توجد أخبار في هذه الفئة حاليًا');
        displayedArticles.clear();
      }
    } catch (e) {
      developer.log('❌ Error filtering by category: $e');
      Get.snackbar('خطأ', 'حدث خطأ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more results - called when scrolling to bottom
  Future<void> loadMoreResults() async {
    // لو بالفعل في loading أو مفيش بيانات أخرى، متعملش حاجة
    if (isLoadingMore.value || !hasMoreData || currentPage >= maxPages) {
      return;
    }

    try {
      isLoadingMore.value = true;
      currentPage++; // زود الـ page قبل الطلب

      developer.log('📄 Loading more results... Page: $currentPage');

      List<Article>? moreNews;

      if (searchQuery.value.isNotEmpty) {
        // Load more search results
        moreNews = await newsService.showNews(
          search: searchQuery.value,
          page: currentPage,
        );
      } else if (selectedCategory.value != 'general') {
        // Load more from category
        moreNews = await newsService.showNewsByCategory(
          category: selectedCategory.value,
          page: currentPage,
        );
      } else {
        // Load more top headlines
        moreNews = await newsService.showTopHeadlinesNews(
          page: currentPage,
        );
      }

      if (moreNews != null && moreNews.isNotEmpty) {
        // تأكد إنك مش بتضيف نفس الأخبار
        final uniqueNews = moreNews.where((newArticle) {
          return !displayedArticles.any((existing) => existing.id == newArticle.id);
        }).toList();

        if (uniqueNews.isNotEmpty) {
          displayedArticles.addAll(uniqueNews);
          developer.log('✅ Added ${uniqueNews.length} new articles (Total: ${displayedArticles.length})');
        } else {
          // لو مفيش أخبار جديدة، يبقى خلصت
          hasMoreData = false;
          developer.log('⚠️ No unique articles found');
        }
      } else {
        // لو الـ API رجع null أو قائمة فاضية
        hasMoreData = false;
        developer.log('⚠️ No more articles available from API');
      }

      // إذا وصلنا للـ max pages
      if (currentPage >= maxPages) {
        hasMoreData = false;
        developer.log('🛑 Reached maximum pages limit (${maxPages})');
      }
    } catch (e) {
      developer.log('❌ Error loading more results: $e');
      Get.snackbar('خطأ', 'فشل تحميل المزيد: $e');
    } finally {
      isLoadingMore.value = false;
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
      developer.log('❌ Error extracting article: $e');
      Get.snackbar('خطأ', 'فشل استخراج المحتوى: $e');
      return null;
    }
  }

  @override
  void onClose() {
    newsService.cancelRequest();
    extractionService.cancelRequest();
    super.onClose();
  }
}