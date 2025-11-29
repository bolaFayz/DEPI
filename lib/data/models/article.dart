import 'package:meta/meta.dart';
import 'dart:convert';

Article articleFromJson(String str) => Article.fromJson(json.decode(str));

String articleToJson(Article data) => json.encode(data.toJson());

class Article {
  final String id;
  final String title;
  final String description;
  String content;
  final String url;
  final String image;
  final DateTime publishedAt;
  final String lang;
  final Source source;
  String? summary;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.image,
    required this.publishedAt,
    required this.lang,
    required this.source,
    this.summary,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: _getString(json, 'id'),
      title: _getString(json, 'title'),
      description: _getString(json, 'description'),
      content: _getString(json, 'content'),
      url: _getString(json, 'url'),
      image: _getString(json, 'image'),
      publishedAt: _getDateTime(json, 'publishedAt'),
      lang: _getString(json, 'lang'),
      source: Source.fromJson(json["source"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "content": content,
    "url": url,
    "image": image,
    "publishedAt": publishedAt.toIso8601String(),
    "lang": lang,
    "source": source.toJson(),
    "summary": summary,
  };

  /// Helper function to safely get string values
  static String _getString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value is! String) {
      return '';
    }
    return value;
  }

  /// Helper function to safely get DateTime values
  static DateTime _getDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value is! String) {
      return DateTime.now();
    }
    return DateTime.tryParse(value) ?? DateTime.now();
  }
}

class Source {
  final String id;
  final String name;
  final String url;
  final String country;

  Source({
    required this.id,
    required this.name,
    required this.url,
    required this.country,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: Article._getString(json, 'id'),
      name: Article._getString(json, 'name'),
      url: Article._getString(json, 'url'),
      country: Article._getString(json, 'country').isEmpty
          ? 'Unknown'
          : Article._getString(json, 'country'),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "url": url,
    "country": country,
  };
}