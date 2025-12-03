import 'package:floor/floor.dart';
import 'package:mega_news_app/data/models/article.dart';

@Entity(tableName: 'articles')
class ArticleEntity {
  @primaryKey
  final String id;
  final String title;
  final String description;
  final String content;
  final String url;
  final String image;
  final int publishedAt;
  final String lang;
  final String? summary;

  // Source data
  final String sourceId;
  final String sourceName;
  final String sourceUrl;
  final String sourceCountry;

  // Cache metadata
  final int cachedAt;
  final String? category;
  final int isBookmarked;

  ArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.image,
    required this.publishedAt,
    required this.lang,
    this.summary,
    required this.sourceId,
    required this.sourceName,
    required this.sourceUrl,
    required this.sourceCountry,
    required this.cachedAt,
    this.category,
    this.isBookmarked = 0,
  });

  factory ArticleEntity.fromArticle(
      Article article, {
        String? category,
        bool isBookmarked = false,
      }) {
    return ArticleEntity(
      id: article.id,
      title: article.title,
      description: article.description,
      content: article.content,
      url: article.url,
      image: article.image,
      publishedAt: article.publishedAt.millisecondsSinceEpoch,
      lang: article.lang,
      summary: article.summary,
      sourceId: article.source.id,
      sourceName: article.source.name,
      sourceUrl: article.source.url,
      sourceCountry: article.source.country,
      cachedAt: DateTime.now().millisecondsSinceEpoch,
      category: category,
      isBookmarked: isBookmarked ? 1 : 0,
    );
  }

  Article toArticle() {
    return Article(
      id: id,
      title: title,
      description: description,
      content: content,
      url: url,
      image: image,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(publishedAt),
      lang: lang,
      source: Source(
        id: sourceId,
        name: sourceName,
        url: sourceUrl,
        country: sourceCountry,
      ),
      summary: summary,
    );
  }

  ArticleEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? image,
    int? publishedAt,
    String? lang,
    String? summary,
    String? sourceId,
    String? sourceName,
    String? sourceUrl,
    String? sourceCountry,
    int? cachedAt,
    String? category,
    int? isBookmarked,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      image: image ?? this.image,
      publishedAt: publishedAt ?? this.publishedAt,
      lang: lang ?? this.lang,
      summary: summary ?? this.summary,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceCountry: sourceCountry ?? this.sourceCountry,
      cachedAt: cachedAt ?? this.cachedAt,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}




