import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class CacheHelper {
  static const _cacheKey = "cachedArticles";

  static Future<void> saveCache(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = articles.map((a) => a.toJson()).toList();
    prefs.setString(_cacheKey, jsonEncode(jsonData));
  }

  static Future<List<Article>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);

    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map<Article>((a) => Article.fromJson(a)).toList();
  }
}
