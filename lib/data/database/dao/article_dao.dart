import 'package:floor/floor.dart';
import 'package:mega_news_app/data/database/entities/article_entity.dart';

@dao
abstract class ArticleDao {

  // TOP HEADLINES
  @Query('''
    SELECT * FROM articles 
    WHERE sourceCountry = :country 
    AND (category IS NULL OR category = '')
    ORDER BY publishedAt DESC 
    LIMIT :limit
  ''')
  Future<List<ArticleEntity>> getTopHeadlines(String country, int limit);

  @Query('''
    SELECT * FROM articles 
    WHERE sourceCountry = :country 
    AND (category IS NULL OR category = '')
    ORDER BY publishedAt DESC 
    LIMIT :limit OFFSET :offset
  ''')
  Future<List<ArticleEntity>> getTopHeadlinesPaginated(
      String country,
      int limit,
      int offset,
      );

  // CATEGORY
  @Query('''
    SELECT * FROM articles 
    WHERE category = :category 
    AND sourceCountry = :country 
    ORDER BY publishedAt DESC 
    LIMIT :limit
  ''')
  Future<List<ArticleEntity>> getArticlesByCategory(
      String category,
      String country,
      int limit,
      );

  @Query('''
    SELECT * FROM articles 
    WHERE category = :category 
    AND sourceCountry = :country 
    ORDER BY publishedAt DESC 
    LIMIT :limit OFFSET :offset
  ''')
  Future<List<ArticleEntity>> getArticlesByCategoryPaginated(
      String category,
      String country,
      int limit,
      int offset,
      );

  //SEARCH
  @Query('''
    SELECT * FROM articles 
    WHERE sourceCountry = :country
    AND (
      title LIKE :query 
      OR description LIKE :query 
      OR sourceName LIKE :query
    )
    ORDER BY 
      CASE 
        WHEN title LIKE :query THEN 1
        WHEN description LIKE :query THEN 2
        ELSE 3
      END,
      publishedAt DESC
    LIMIT :limit
  ''')
  Future<List<ArticleEntity>> searchArticles(
      String query,
      String country,
      int limit,
      );

  @Query('''
    SELECT * FROM articles 
    WHERE sourceCountry = :country
    AND (
      title LIKE :query 
      OR description LIKE :query 
      OR sourceName LIKE :query
    )
    ORDER BY 
      CASE 
        WHEN title LIKE :query THEN 1
        WHEN description LIKE :query THEN 2
        ELSE 3
      END,
      publishedAt DESC
    LIMIT :limit OFFSET :offset
  ''')
  Future<List<ArticleEntity>> searchArticlesPaginated(
      String query,
      String country,
      int limit,
      int offset,
      );

  // ============================================
  // INSERT/UPDATE
  // ============================================

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticles(List<ArticleEntity> articles);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticle(ArticleEntity article);

  @update
  Future<void> updateArticle(ArticleEntity article);

  // ============================================
  // SUMMARY & CONTENT UPDATE
  // ============================================

  // Update summary and content after extraction
  @Query('''
    UPDATE articles 
    SET summary = :summary,
        content = :content
    WHERE id = :articleId
  ''')
  Future<void> updateArticleSummary(
      String articleId,
      String summary,
      String content,
      );

  // Check if article has summary
  @Query('''
    SELECT summary FROM articles 
    WHERE id = :articleId
  ''')
  Future<String?> getArticleSummary(String articleId);

  // Get article with full content
  @Query('''
    SELECT * FROM articles 
    WHERE id = :articleId 
    LIMIT 1
  ''')
  Future<ArticleEntity?> getArticleById(String articleId);

  // ============================================
  // BOOKMARKS
  // ============================================

  @Query('''
    SELECT * FROM articles 
    WHERE isBookmarked = 1 
    ORDER BY publishedAt DESC
  ''')
  Future<List<ArticleEntity>> getBookmarkedArticles();

  @Query('''
    UPDATE articles 
    SET isBookmarked = :isBookmarked 
    WHERE id = :articleId
  ''')
  Future<void> updateBookmarkStatus(String articleId, int isBookmarked);

  @Query('SELECT isBookmarked FROM articles WHERE id = :articleId')
  Future<int?> getBookmarkStatus(String articleId);

  // ============================================
  // CACHE MANAGEMENT
  // ============================================

  @Query('''
    DELETE FROM articles 
    WHERE cachedAt < :timestamp 
    AND isBookmarked = 0
    AND cachedAt < :keepRecentAfter
  ''')
  Future<void> deleteOldCache(int timestamp, int keepRecentAfter);

  @Query('DELETE FROM articles WHERE isBookmarked = 0')
  Future<void> clearCache();

  @Query('DELETE FROM articles')
  Future<void> deleteAllArticles();

  @Query('''
    DELETE FROM articles 
    WHERE sourceCountry = :country 
    AND isBookmarked = 0
  ''')
  Future<void> deleteByCountry(String country);

  @Query('''
    DELETE FROM articles 
    WHERE category = :category 
    AND isBookmarked = 0
  ''')
  Future<void> deleteByCategory(String category);

  // ============================================
  // STATISTICS
  // ============================================

  @Query('SELECT COUNT(*) FROM articles')
  Future<int?> getArticlesCount();

  @Query('SELECT COUNT(*) FROM articles WHERE isBookmarked = 1')
  Future<int?> getBookmarkedCount();

  @Query('SELECT COUNT(*) FROM articles WHERE id = :articleId')
  Future<int?> articleExists(String articleId);

  @Query('''
    SELECT MAX(cachedAt) 
    FROM articles 
    WHERE sourceCountry = :country
    AND (category IS NULL OR category = '')
  ''')
  Future<int?> getNewestCacheTimestamp(String country);

  @Query('''
    SELECT MIN(cachedAt) 
    FROM articles 
    WHERE isBookmarked = 0
  ''')
  Future<int?> getOldestCacheTimestamp();

  @Query('SELECT COUNT(*) FROM articles WHERE sourceCountry = :country')
  Future<int?> getCacheSizeByCountry(String country);

  @Query('SELECT COUNT(*) FROM articles WHERE category = :category')
  Future<int?> getCacheSizeByCategory(String category);
}