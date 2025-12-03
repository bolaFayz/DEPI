import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/database_service.dart';

class BookmarksController extends GetxController {
  final dbService = DatabaseService.instance;
  final bookmarkedArticles = <Article>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    try {
      isLoading.value = true;
      final articles = await dbService.getBookmarkedArticles();
      bookmarkedArticles.assignAll(articles);
    } catch (e) {
      Get.snackbar(
        'خطأ'.tr,
        'فشل تحميل المفضلة',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeBookmark(String articleId) async {
    try {
      await dbService.toggleBookmark(articleId, false);
      bookmarkedArticles.removeWhere((article) => article.id == articleId);

      Get.snackbar(
        'تم الإزالة'.tr,
        'تمت إزالة الخبر من المفضلة',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.grey[700],
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        isDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ'.tr,
        'فشل إزالة الخبر',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}