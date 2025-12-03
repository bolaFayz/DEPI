import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/extraction_service.dart';
import 'package:mega_news_app/data/services/database_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class NewsDetailsController extends GetxController {
  final extractionService = ExtractionService();
  final dbService = DatabaseService.instance;

  late final article = Get.arguments as Article;

  final isExtracting = false.obs;
  final extractedSummary = Rxn<String>();
  final extractedContent = Rxn<String>();
  final showSummary = false.obs;
  final hasCachedSummary = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeDateFormatting('ar', null);

    await _checkCachedSummary();
  }

  Future<void> _checkCachedSummary() async {
    try {
      final fullArticle = await dbService.articleDao.getArticleById(article.id);

      if (fullArticle != null &&
          fullArticle.summary != null &&
          fullArticle.summary!.isNotEmpty) {
        extractedSummary.value = fullArticle.summary;
        extractedContent.value = fullArticle.content;
        hasCachedSummary.value = true;
        showSummary.value = false;
      } else {
        hasCachedSummary.value = false;
      }
    } catch (e) {
      hasCachedSummary.value = false;
    }
  }

  Future<void> extractOrShowSummary() async {
    if (showSummary.value) {
      Get.snackbar(
        'الملخص معروض',
        'الملخص معروض بالفعل أسفل الوصف',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue[600],
        colorText: Colors.white,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (hasCachedSummary.value && extractedSummary.value != null) {
      showSummary.value = true;

      Get.snackbar(
        'تم عرض الملخص',
        'الملخص المحفوظ معروض الآن',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final hasInternet = await _checkInternet();

    if (!hasInternet) {
      Get.snackbar(
        'لا يوجد اتصال',
        'يجب الاتصال بالإنترنت لاستخراج الملخص',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange[700],
        colorText: Colors.white,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    await _extractFromWeb();
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  Future<void> _extractFromWeb() async {
    try {
      isExtracting.value = true;

      Article? extracted;
      int retries = 0;
      const maxRetries = 2;

      while (retries <= maxRetries && extracted == null) {
        try {
          extracted = await extractionService.extractArticleBody(
            articleUrl: article.url,
            article: article,
          );

          if (extracted != null) break;
        } catch (e) {
          retries++;

          if (retries <= maxRetries) {
            await Future.delayed(Duration(seconds: 2 * retries));
          }
        }
      }

      if (extracted != null &&
          extracted.summary != null &&
          extracted.summary!.isNotEmpty) {
        extractedSummary.value = extracted.summary;
        extractedContent.value = extracted.content.isNotEmpty
            ? extracted.content
            : 'لا يوجد محتوى إضافي';
        hasCachedSummary.value = true;
        showSummary.value = true;

        await _saveSummaryToCache(extracted.summary!, extracted.content);

        Get.snackbar(
          'تم الاستخراج بنجاح',
          'تم استخراج الملخص وحفظه',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        Get.snackbar(
          'فشل الاستخراج',
          'لم نتمكن من استخراج ملخص لهذه المقالة. حاول مرة أخرى لاحقاً',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ في الاستخراج',
        'حدث خطأ أثناء استخراج الملخص. حاول مرة أخرى',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isExtracting.value = false;
    }
  }

  Future<void> _saveSummaryToCache(String summary, String content) async {
    await dbService.articleDao.updateArticleSummary(
      article.id,
      summary,
      content,
    );
  }

  Future<void> openArticleInBrowser() async {
    try {
      if (!await launchUrl(Uri.parse(article.url))) {
        Get.snackbar('خطأ', 'لم يتم فتح الرابط');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل فتح الرابط');
    }
  }

  @override
  void onClose() {
    extractionService.cancelRequest();
    showSummary.value = false;
    super.onClose();
  }
}
