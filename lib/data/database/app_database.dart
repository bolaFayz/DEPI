import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:mega_news_app/data/database/entities/article_entity.dart';
import 'package:mega_news_app/data/database/dao/article_dao.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [ArticleEntity])
abstract class AppDatabase extends FloorDatabase {
  ArticleDao get articleDao;
}

class DatabaseHelper {
  static AppDatabase? _database;
  static const String _databaseName = 'mega_news.db';
  DatabaseHelper._();
  static Future<AppDatabase> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }
  /// Initialize the database
  static Future<AppDatabase> _initDatabase() async {
    return await $FloorAppDatabase
        .databaseBuilder(_databaseName)
        .addMigrations([])  // Add migrations here in future versions
        .build();
  }
}