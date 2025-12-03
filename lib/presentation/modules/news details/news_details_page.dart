import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'news_details_controller.dart';

class NewsDetailsPage extends GetView<NewsDetailsController> {
  const NewsDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final article = controller.article;
    final date = DateFormat('dd/MM/yyyy hh:mm', 'ar').format(article.publishedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الخبر'.tr),
        centerTitle: true,
        actions: [
          // IconButton(
          //   onPressed: () {
          //
          //   },
          //   icon: const Icon(Icons.share),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (article.image.isNotEmpty)
              Hero(
                tag: 'article_${article.id}',
                child: CachedNetworkImage(
                  imageUrl: article.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,

                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),

                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 80,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'تعذر تحميل الصورة',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'الوصف'.tr,
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

                  Obx(() {
                    if (controller.isExtracting.value) {
                      return Center(
                        child: Column(
                          children: [
                            SpinKitFadingCircle(
                              color: Theme.of(context).primaryColor,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'جاري استخراج الملخص...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (controller.showSummary.value &&
                        controller.extractedSummary.value != null) {
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
        // Read Full Article
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.openArticleInBrowser(),
            icon: const Icon(Icons.open_in_browser),
            label: Text('اقرأ المقالة كاملة'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),


        Expanded(
          child: Obx(() {
            final isExtracting = controller.isExtracting.value;

            return ElevatedButton.icon(
              onPressed: isExtracting
                  ? null
                  : () => controller.extractOrShowSummary(),
              icon: isExtracting
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
              label: Text(
                isExtracting ? 'جاري الاستخراج...' : 'احصل على ملخص'.tr,
              ),
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

  Widget _buildExtractedSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الملخص الذكي'.tr,
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