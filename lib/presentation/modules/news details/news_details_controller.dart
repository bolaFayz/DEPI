import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/extraction_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';

class NewsDetailsController extends GetxController {
  final extractionService = ExtractionService();

  late final article = Get.arguments as Article;

  final isExtracting = false.obs;
  final extractedSummary = Rxn<String>();
  final extractedContent = Rxn<String>();
  final hasExtracted = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeDateFormatting('ar', null); // ✅ اضيفها هنا برضو
    developer.log('📄 Opening article: ${article.title}');
  }

  /// Extract article content from Diffbot
  Future<void> extractArticleContent() async {
    try {
      isExtracting.value = true;
      extractedSummary.value = null;
      extractedContent.value = null;

      developer.log('🔗 Starting extraction for: ${article.url}');

      final extracted = await extractionService.extractArticleBody(
        articleUrl: article.url,
        article: article,
      );

      developer.log('✅ Extraction result: $extracted');

      if (extracted != null && extracted.summary != null && extracted.summary!.isNotEmpty) {
        extractedSummary.value = extracted.summary;
        extractedContent.value = extracted.content.isNotEmpty
            ? extracted.content
            : 'لا يوجد محتوى إضافي';
        hasExtracted.value = true;

        developer.log('✅ Article extracted successfully');
      } else {
        developer.log('❌ Extraction failed or returned empty data');
        Get.snackbar(
          'خطأ',
          'عذراً، لم نتمكن من استخراج ملخص هذه المقالة. يرجى محاولة لاحقاً.',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red[400],
        );
      }
    } catch (e, stackTrace) {
      developer.log('❌ Extraction error: $e');
      developer.log('Stack trace: $stackTrace');

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء محاولة استخراج الملخص',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red[400],
      );
    } finally {
      isExtracting.value = false;
    }
  }

  /// Open article URL in browser
  Future<void> openArticleInBrowser() async {
    try {
      if (!await launchUrl(Uri.parse(article.url))) {
        Get.snackbar('خطأ', 'لم يتم فتح الرابط');
      }
    } catch (e) {
      developer.log('❌ Launch URL error: $e');
      Get.snackbar('خطأ', 'فشل فتح الرابط');
    }
  }

  @override
  void onClose() {
    extractionService.cancelRequest();
    super.onClose();
  }
}