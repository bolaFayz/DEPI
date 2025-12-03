import 'package:mega_news_app/data/database/app_database.dart';
import 'package:mega_news_app/data/database/dao/article_dao.dart';
import 'package:mega_news_app/data/database/entities/article_entity.dart';
import 'package:mega_news_app/data/models/article.dart';

class DatabaseService {
  late final AppDatabase _database;
  late final ArticleDao _articleDao;

  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();
  static DatabaseService get instance => _instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static const Duration headlinesCacheExpiry = Duration(hours: 6);
  static const int maxCacheSize = 1000;

  Future<void> init() async {
    _database = await DatabaseHelper.database;
    _articleDao = _database.articleDao;
    _isInitialized = true;
    await _performStartupMaintenance();
  }

  Future<void> _performStartupMaintenance() async {
    await cleanOldCache(daysOld: 30);
    final count = await getArticlesCount();
    if (count > maxCacheSize) {
      await _trimCache();
    }
  }

  ArticleDao get articleDao {
    if (!_isInitialized) {
      throw Exception('Database not initialized!');
    }
    return _articleDao;
  }

  // ============================================
  // SAVE OPERATIONS
  // ============================================

  Future<void> saveArticles(
    List<Article> articles, {
    String? category,
    required String country,
  }) async {
    if (articles.isEmpty) return;
    final entities = articles.map((article) {
      final entity = ArticleEntity.fromArticle(article, category: category);
      return entity.copyWith(sourceCountry: country);
    }).toList();
    await _articleDao.insertArticles(entities);
    await _trimCacheIfNeeded();
  }

  Future<void> saveArticle(
    Article article, {
    String? category,
    required String country,
  }) async {
    final entity = ArticleEntity.fromArticle(article, category: category);
    final fixedEntity = entity.copyWith(sourceCountry: country);
    await _articleDao.insertArticle(fixedEntity);
  }

  // ============================================
  // LOAD OPERATIONS
  // ============================================

  Future<List<Article>> getTopHeadlines({
    required String country,
    int limit = 10,
  }) async {
    try {
      final entities = await _articleDao.getTopHeadlines(country, limit);
      return entities.map((e) => e.toArticle()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Article>> getTopHeadlinesPaginated({
    required String country,
    required int page,
    int limit = 10,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final entities = await _articleDao.getTopHeadlinesPaginated(
        country,
        limit,
        offset,
      );
      return entities.map((e) => e.toArticle()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Article>> getArticlesByCategory({
    required String category,
    required String country,
    int limit = 10,
  }) async {
    try {
      final entities = await _articleDao.getArticlesByCategory(
        category,
        country,
        limit,
      );
      return entities.map((e) => e.toArticle()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Article>> getArticlesByCategoryPaginated({
    required String category,
    required String country,
    required int page,
    int limit = 10,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final entities = await _articleDao.getArticlesByCategoryPaginated(
        category,
        country,
        limit,
        offset,
      );
      return entities.map((e) => e.toArticle()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Article>> searchArticles({
    required String query,
    required String country,
    int limit = 30,
  }) async {
    try {
      final searchQuery = '%$query%';
      final entities = await _articleDao.searchArticles(
        searchQuery,
        country,
        limit,
      );
      return entities.map((e) => e.toArticle()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Article>> searchArticlesPaginated({
    required String query,
    required String country,
    required int page,
    int limit = 30,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final searchQuery = '%$query%';
      final entities = await _articleDao.searchArticlesPaginated(
        searchQuery,
        country,
        limit,
        offset,
      );
      return entities.map((e) => e.toArticle()).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // BOOKMARKS
  // ============================================

  Future<List<Article>> getBookmarkedArticles() async {
    try {
      final entities = await _articleDao.getBookmarkedArticles();
      return entities.map((e) => e.toArticle()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> toggleBookmark(String articleId, bool isBookmarked) async {
    await _articleDao.updateBookmarkStatus(articleId, isBookmarked ? 1 : 0);
  }

  Future<bool> isArticleBookmarked(String articleId) async {
    try {
      final status = await _articleDao.getBookmarkStatus(articleId);
      return status == 1;
    } catch (e) {
      return false;
    }
  }

  // CACHE VALIDATION
  Future<bool> isCacheFresh({
    required String country,
    Duration maxAge = headlinesCacheExpiry,
  }) async {
    try {
      final timestamp = await _articleDao.getNewestCacheTimestamp(country);
      if (timestamp == null) return false;

      final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(cacheDate);
      return age < maxAge;
    } catch (e) {
      return false;
    }
  }
  // ============================================
  // CACHE MANAGEMENT
  // ============================================

  Future<void> cleanOldCache({int daysOld = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    final keepRecent = DateTime.now().subtract(const Duration(hours: 2));

    await _articleDao.deleteOldCache(
      cutoff.millisecondsSinceEpoch,
      keepRecent.millisecondsSinceEpoch,
    );
  }

  Future<void> clearAllCache() async {
    await _articleDao.clearCache();
  }

  Future<void> clearCacheByCountry(String country) async {
    await _articleDao.deleteByCountry(country);
  }

  Future<void> clearCacheByCategory(String category) async {
    await _articleDao.deleteByCategory(category);
  }

  Future<void> _trimCacheIfNeeded() async {
    final count = await getArticlesCount();
    if (count > maxCacheSize) {
      await _trimCache();
    }
  }

  Future<void> _trimCache() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final keepRecent = DateTime.now().subtract(const Duration(hours: 1));

    await _articleDao.deleteOldCache(
      cutoff.millisecondsSinceEpoch,
      keepRecent.millisecondsSinceEpoch,
    );
  }

  Future<int> getArticlesCount() async {
    try {
      return await _articleDao.getArticlesCount() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getBookmarkedCount() async {
    try {
      return await _articleDao.getBookmarkedCount() ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
