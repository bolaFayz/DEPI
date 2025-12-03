// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ArticleDao? _articleDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `articles` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `content` TEXT NOT NULL, `url` TEXT NOT NULL, `image` TEXT NOT NULL, `publishedAt` INTEGER NOT NULL, `lang` TEXT NOT NULL, `summary` TEXT, `sourceId` TEXT NOT NULL, `sourceName` TEXT NOT NULL, `sourceUrl` TEXT NOT NULL, `sourceCountry` TEXT NOT NULL, `cachedAt` INTEGER NOT NULL, `category` TEXT, `isBookmarked` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArticleDao get articleDao {
    return _articleDaoInstance ??= _$ArticleDao(database, changeListener);
  }
}

class _$ArticleDao extends ArticleDao {
  _$ArticleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _articleEntityInsertionAdapter = InsertionAdapter(
            database,
            'articles',
            (ArticleEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'content': item.content,
                  'url': item.url,
                  'image': item.image,
                  'publishedAt': item.publishedAt,
                  'lang': item.lang,
                  'summary': item.summary,
                  'sourceId': item.sourceId,
                  'sourceName': item.sourceName,
                  'sourceUrl': item.sourceUrl,
                  'sourceCountry': item.sourceCountry,
                  'cachedAt': item.cachedAt,
                  'category': item.category,
                  'isBookmarked': item.isBookmarked
                }),
        _articleEntityUpdateAdapter = UpdateAdapter(
            database,
            'articles',
            ['id'],
            (ArticleEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'content': item.content,
                  'url': item.url,
                  'image': item.image,
                  'publishedAt': item.publishedAt,
                  'lang': item.lang,
                  'summary': item.summary,
                  'sourceId': item.sourceId,
                  'sourceName': item.sourceName,
                  'sourceUrl': item.sourceUrl,
                  'sourceCountry': item.sourceCountry,
                  'cachedAt': item.cachedAt,
                  'category': item.category,
                  'isBookmarked': item.isBookmarked
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ArticleEntity> _articleEntityInsertionAdapter;

  final UpdateAdapter<ArticleEntity> _articleEntityUpdateAdapter;

  @override
  Future<List<ArticleEntity>> getTopHeadlines(
    String country,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE sourceCountry = ?1      AND (category IS NULL OR category = \'\')     ORDER BY publishedAt DESC      LIMIT ?2',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [country, limit]);
  }

  @override
  Future<List<ArticleEntity>> getTopHeadlinesPaginated(
    String country,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE sourceCountry = ?1      AND (category IS NULL OR category = \'\')     ORDER BY publishedAt DESC      LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [country, limit, offset]);
  }

  @override
  Future<List<ArticleEntity>> getArticlesByCategory(
    String category,
    String country,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE category = ?1      AND sourceCountry = ?2      ORDER BY publishedAt DESC      LIMIT ?3',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [category, country, limit]);
  }

  @override
  Future<List<ArticleEntity>> getArticlesByCategoryPaginated(
    String category,
    String country,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE category = ?1      AND sourceCountry = ?2      ORDER BY publishedAt DESC      LIMIT ?3 OFFSET ?4',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [category, country, limit, offset]);
  }

  @override
  Future<List<ArticleEntity>> searchArticles(
    String query,
    String country,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE sourceCountry = ?2     AND (       title LIKE ?1        OR description LIKE ?1        OR sourceName LIKE ?1     )     ORDER BY        CASE          WHEN title LIKE ?1 THEN 1         WHEN description LIKE ?1 THEN 2         ELSE 3       END,       publishedAt DESC     LIMIT ?3',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [query, country, limit]);
  }

  @override
  Future<List<ArticleEntity>> searchArticlesPaginated(
    String query,
    String country,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE sourceCountry = ?2     AND (       title LIKE ?1        OR description LIKE ?1        OR sourceName LIKE ?1     )     ORDER BY        CASE          WHEN title LIKE ?1 THEN 1         WHEN description LIKE ?1 THEN 2         ELSE 3       END,       publishedAt DESC     LIMIT ?3 OFFSET ?4',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [query, country, limit, offset]);
  }

  @override
  Future<void> updateArticleSummary(
    String articleId,
    String summary,
    String content,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE articles      SET summary = ?2,         content = ?3     WHERE id = ?1',
        arguments: [articleId, summary, content]);
  }

  @override
  Future<String?> getArticleSummary(String articleId) async {
    return _queryAdapter.query(
        'SELECT summary FROM articles      WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as String,
        arguments: [articleId]);
  }

  @override
  Future<ArticleEntity?> getArticleById(String articleId) async {
    return _queryAdapter.query(
        'SELECT * FROM articles      WHERE id = ?1      LIMIT 1',
        mapper: (Map<String, Object?> row) => ArticleEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            description: row['description'] as String,
            content: row['content'] as String,
            url: row['url'] as String,
            image: row['image'] as String,
            publishedAt: row['publishedAt'] as int,
            lang: row['lang'] as String,
            summary: row['summary'] as String?,
            sourceId: row['sourceId'] as String,
            sourceName: row['sourceName'] as String,
            sourceUrl: row['sourceUrl'] as String,
            sourceCountry: row['sourceCountry'] as String,
            cachedAt: row['cachedAt'] as int,
            category: row['category'] as String?,
            isBookmarked: row['isBookmarked'] as int),
        arguments: [articleId]);
  }

  @override
  Future<List<ArticleEntity>> getBookmarkedArticles() async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE isBookmarked = 1      ORDER BY publishedAt DESC',
        mapper: (Map<String, Object?> row) => ArticleEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            description: row['description'] as String,
            content: row['content'] as String,
            url: row['url'] as String,
            image: row['image'] as String,
            publishedAt: row['publishedAt'] as int,
            lang: row['lang'] as String,
            summary: row['summary'] as String?,
            sourceId: row['sourceId'] as String,
            sourceName: row['sourceName'] as String,
            sourceUrl: row['sourceUrl'] as String,
            sourceCountry: row['sourceCountry'] as String,
            cachedAt: row['cachedAt'] as int,
            category: row['category'] as String?,
            isBookmarked: row['isBookmarked'] as int));
  }

  @override
  Future<void> updateBookmarkStatus(
    String articleId,
    int isBookmarked,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE articles      SET isBookmarked = ?2      WHERE id = ?1',
        arguments: [articleId, isBookmarked]);
  }

  @override
  Future<int?> getBookmarkStatus(String articleId) async {
    return _queryAdapter.query(
        'SELECT isBookmarked FROM articles WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [articleId]);
  }

  @override
  Future<void> deleteOldCache(
    int timestamp,
    int keepRecentAfter,
  ) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM articles      WHERE cachedAt < ?1      AND isBookmarked = 0     AND cachedAt < ?2',
        arguments: [timestamp, keepRecentAfter]);
  }

  @override
  Future<void> clearCache() async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM articles WHERE isBookmarked = 0');
  }

  @override
  Future<void> deleteAllArticles() async {
    await _queryAdapter.queryNoReturn('DELETE FROM articles');
  }

  @override
  Future<void> deleteByCountry(String country) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM articles      WHERE sourceCountry = ?1      AND isBookmarked = 0',
        arguments: [country]);
  }

  @override
  Future<void> deleteByCategory(String category) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM articles      WHERE category = ?1      AND isBookmarked = 0',
        arguments: [category]);
  }

  @override
  Future<int?> getArticlesCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM articles',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getBookmarkedCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM articles WHERE isBookmarked = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> articleExists(String articleId) async {
    return _queryAdapter.query('SELECT COUNT(*) FROM articles WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [articleId]);
  }

  @override
  Future<int?> getNewestCacheTimestamp(String country) async {
    return _queryAdapter.query(
        'SELECT MAX(cachedAt)      FROM articles      WHERE sourceCountry = ?1     AND (category IS NULL OR category = \'\')',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [country]);
  }

  @override
  Future<int?> getOldestCacheTimestamp() async {
    return _queryAdapter.query(
        'SELECT MIN(cachedAt)      FROM articles      WHERE isBookmarked = 0',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getCacheSizeByCountry(String country) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM articles WHERE sourceCountry = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [country]);
  }

  @override
  Future<int?> getCacheSizeByCategory(String category) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM articles WHERE category = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [category]);
  }

  @override
  Future<List<ArticleEntity>> getArticlesBySource(
    String sourceName,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE sourceName = ?1      ORDER BY publishedAt DESC      LIMIT ?2',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [sourceName, limit]);
  }

  @override
  Future<List<ArticleEntity>> getArticlesAfterDate(
    int timestamp,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE publishedAt > ?1      ORDER BY publishedAt DESC      LIMIT ?2',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [timestamp, limit]);
  }

  @override
  Future<List<ArticleEntity>> getArticlesInDateRange(
    int startTimestamp,
    int endTimestamp,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM articles      WHERE publishedAt BETWEEN ?1 AND ?2      ORDER BY publishedAt DESC',
        mapper: (Map<String, Object?> row) => ArticleEntity(id: row['id'] as String, title: row['title'] as String, description: row['description'] as String, content: row['content'] as String, url: row['url'] as String, image: row['image'] as String, publishedAt: row['publishedAt'] as int, lang: row['lang'] as String, summary: row['summary'] as String?, sourceId: row['sourceId'] as String, sourceName: row['sourceName'] as String, sourceUrl: row['sourceUrl'] as String, sourceCountry: row['sourceCountry'] as String, cachedAt: row['cachedAt'] as int, category: row['category'] as String?, isBookmarked: row['isBookmarked'] as int),
        arguments: [startTimestamp, endTimestamp]);
  }

  @override
  Future<List<String>> getAllSourceNames() async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT sourceName FROM articles ORDER BY sourceName',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<List<String>> getAllCountries() async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT sourceCountry FROM articles ORDER BY sourceCountry',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> insertArticles(List<ArticleEntity> articles) async {
    await _articleEntityInsertionAdapter.insertList(
        articles, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertArticle(ArticleEntity article) async {
    await _articleEntityInsertionAdapter.insert(
        article, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateArticle(ArticleEntity article) async {
    await _articleEntityUpdateAdapter.update(article, OnConflictStrategy.abort);
  }
}
