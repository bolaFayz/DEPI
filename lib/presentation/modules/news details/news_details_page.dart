import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'news_details_controller.dart';

class NewsDetailsPage extends GetView<NewsDetailsController> {
  const NewsDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final article = controller.article;
    final date = DateFormat('dd/MM/yyyy hh:mm', 'ar').format(article.publishedAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الخبر'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Share functionality (optional)
              Get.snackbar('مشاركة', 'قريباً...');
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            if (article.image.isNotEmpty)
              Hero(
                tag: 'article_${article.id}',
                child: Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: Image.network(
                    article.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 80,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Source and Date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.source.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 16),

                  // Description from GNews
                  Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 24),

                  // Extracted Content Section
                  Obx(() {
                    if (controller.isExtracting.value) {
                      return Center(
                        child: SpinKitFadingCircle(
                          color: Theme.of(context).primaryColor,
                          size: 40,
                        ),
                      );
                    }

                    if (controller.hasExtracted.value) {
                      return _buildExtractedSummary(context);
                    }

                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Read Full Article Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.openArticleInBrowser(),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('اقرأ المقالة كاملة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Get Summary Button
        Expanded(
          child: Obx(() {
            return ElevatedButton.icon(
              onPressed: controller.isExtracting.value
                  ? null
                  : () => controller.extractArticleContent(),
              icon: controller.isExtracting.value
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
                  : const Icon(Icons.summarize),
              label: const Text('احصل على ملخص'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Extracted Summary Section (بدون المحتوى الكامل)
  Widget _buildExtractedSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Header
        Text(
          'الملخص الذكي',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),

        // Summary Container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Obx(() {
            return Text(
              controller.extractedSummary.value ?? 'جاري التحميل...',
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            );
          }),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}