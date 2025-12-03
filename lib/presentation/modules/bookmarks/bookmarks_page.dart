import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/presentation/modules/bookmarks/bookmarks_controller.dart';
import 'package:mega_news_app/presentation/shared_widgets/news_card.dart';

class BookmarksPage extends GetView<BookmarksController> {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأخبار المفضلة'.tr),
        centerTitle: true,
        actions: [
          Obx(() {
            final count = controller.bookmarkedArticles.length;
            if (count > 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SpinKitFadingCircle(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        }

        final articles = controller.bookmarkedArticles;

        if (articles.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadBookmarks(),
          color: Theme.of(context).primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key(article.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.white, size: 32),
                        SizedBox(height: 4),
                        Text(
                          'حذف',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteConfirmation(context, article.title);
                  },
                  onDismissed: (direction) {
                    controller.removeBookmark(article.id);
                  },
                  child: NewsCard(article: article),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// Empty State
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد أخبار مفضلة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابحث عن أخبار واضغط على أيقونة القلب لحفظها',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Delete Confirmation Dialog
  Future<bool?> _showDeleteConfirmation(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إزالة من المفضلة'.tr),
        content: Text('هل تريد إزالة هذا الخبر من المفضلة؟\n\n"$title"'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('حذف'.tr),
          ),
        ],
      ),
    );
  }
}