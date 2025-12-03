import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/data/services/database_service.dart';
import 'package:mega_news_app/presentation/modules/home/home_controller.dart';
import 'package:flutter/material.dart';

class SettingsController extends GetxController {
  final dbService = DatabaseService.instance;
  final storage = GetStorage();

  // Observable variables
  final selectedCountry = 'eg'.obs;
  final bookmarksCount = 0.obs;

  // Country list with flags
  final countryList = [
    {'code': 'eg', 'name': 'مصر 🇪🇬'},
    {'code': 'us', 'name': 'الولايات المتحدة 🇺🇸'},
    {'code': 'gb', 'name': 'المملكة المتحدة 🇬🇧'},
    {'code': 'au', 'name': 'أستراليا 🇦🇺'},
    {'code': 'ca', 'name': 'كندا 🇨🇦'},
    {'code': 'fr', 'name': 'فرنسا 🇫🇷'},
    {'code': 'de', 'name': 'ألمانيا 🇩🇪'},
    {'code': 'es', 'name': 'إسبانيا 🇪🇸'},
    {'code': 'it', 'name': 'إيطاليا 🇮🇹'},
    {'code': 'sa', 'name': 'السعودية 🇸🇦'},
    {'code': 'ae', 'name': 'الإمارات 🇦🇪'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _updateCounts();
  }

  /// Load saved settings
  void _loadSettings() {
    try {
      // Load saved country from storage
      selectedCountry.value = storage.read('defaultCountry') ?? 'eg';
    } catch (e) {
      selectedCountry.value = 'eg';
    }
  }

  /// Update bookmarks count
  Future<void> _updateCounts() async {
    try {
      bookmarksCount.value = await dbService.getBookmarkedCount();
    } catch (e) {
      bookmarksCount.value = 0;
    }
  }

  /// ✅ COMPLETE FIX: Change country and reload current category
  void changeCountry(String countryCode) {
    // Don't do anything if same country
    if (selectedCountry.value == countryCode) {
      return;
    }

    selectedCountry.value = countryCode;

    // Save to storage
    storage.write('defaultCountry', countryCode);

    // ✅ Update UI
    update(['country_selection']);

    // ✅ CRITICAL FIX: Sync with HomeController properly
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.selectedCountry.value = countryCode;

        homeController.currentPage = 1;
        homeController.hasMoreData = true;

        if (homeController.searchQuery.value.isNotEmpty) {
          // If searching, redo search with new country
          homeController.searchNews(homeController.searchQuery.value);
        } else if (homeController.selectedCategory.value == 'general') {
          // If in "All" category, reload headlines
          homeController.fetchTopHeadlines(forceRefresh: true);
        } else {
          homeController.filterByCategory(
            homeController.selectedCategory.value,
          );
        }
      } else {}
    } catch (e) {}

    // ✅ Show success message
    Get.snackbar(
      'تم التغيير'.tr,
      'جاري تحديث الأخبار...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Get country name
  String getCountryName() {
    final country = countryList.firstWhere(
      (c) => c['code'] == selectedCountry.value,
      orElse: () => {'code': 'eg', 'name': 'مصر 🇪🇬'},
    );
    return country['name'] as String;
  }

  /// Refresh counts (call when returning from bookmarks)
  Future<void> refreshCounts() async {
    await _updateCounts();
  }
}
