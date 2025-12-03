import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/presentation/modules/home/home_page.dart';
import 'package:mega_news_app/presentation/modules/timeline/timeline_page.dart';
import 'package:mega_news_app/presentation/modules/bookmarks/bookmarks_controller.dart';
import 'package:mega_news_app/presentation/modules/bookmarks/bookmarks_page.dart';
import 'package:mega_news_app/presentation/modules/settings/settings_controller.dart';
import 'package:mega_news_app/presentation/modules/settings/settings_page.dart';

class MainNavigationController extends GetxController {
  final currentIndex = 0.obs;
  final isChangingTab = false.obs;
  final List<Widget> pages = const [
    HomePage(),
    TimelinePage(),
    BookmarksPage(),
    SettingsPage(),
  ];

  final List<NavigationItemData> navigationItems = [
    NavigationItemData(icon: Icons.home_rounded, label: 'الرئيسية', index: 0),
    NavigationItemData(
      icon: Icons.timeline_rounded,
      label: 'الخط الزمني',
      index: 1,
    ),
    NavigationItemData(
      icon: Icons.bookmark_rounded,
      label: 'المفضلة',
      index: 2,
    ),
    NavigationItemData(
      icon: Icons.settings_rounded,
      label: 'الإعدادات',
      index: 3,
    ),
  ];

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ============================================
  // TAB SWITCHING
  // ============================================

  /// Change current tab
  /// @param index: Tab index (0-3)
  void changeTab(int index) {
    // Don't rebuild if clicking the same tab
    if (currentIndex.value == index) {
      return;
    }

    // Update index
    currentIndex.value = index;

    // Perform tab-specific actions
    _onTabChanged(index);
  }

  /// Handle tab change events
  /// Refresh data or perform actions when switching to specific tabs
  void _onTabChanged(int index) {
    try {
      switch (index) {
        case 0: // Home
          // No action needed - data loads automatically
          break;

        case 1: // Timeline

          // No action needed - maintains search state
          break;

        case 2: // Bookmarks
          _refreshBookmarks();
          break;

        case 3: // Settings
          _refreshSettings();
          break;
      }
    } catch (e) {
      //developer.log('⚠️ Error handling tab change: $e');
    }
  }

  /// Refresh bookmarks data
  void _refreshBookmarks() {
    try {
      final bookmarksController = Get.find<BookmarksController>();
      bookmarksController.loadBookmarks();
    } catch (e) {
      //developer.log('⚠️ BookmarksController not found: $e');
    }
  }

  /// Refresh settings data
  void _refreshSettings() {
    try {
      final settingsController = Get.find<SettingsController>();
      settingsController.refreshCounts();
    } catch (e) {
      //developer.log('⚠️ SettingsController not found: $e');
    }
  }

  // ============================================
  // GETTERS
  // ============================================

  /// Get current page widget
  Widget get currentPage => pages[currentIndex.value];

  /// Get current tab name
  String get currentTabName => navigationItems[currentIndex.value].label;

  /// Check if specific tab is active
  bool isTabActive(int index) => currentIndex.value == index;

  // ============================================
  // ACTIONS
  // ============================================

  /// Navigate to specific tab programmatically
  void navigateToTab(int index) {
    if (index < 0 || index >= pages.length) {
      return;
    }
    changeTab(index);
  }

  /// Go to home tab
  void goToHome() => navigateToTab(0);

  /// Go to timeline tab
  void goToTimeline() => navigateToTab(1);

  /// Go to bookmarks tab
  void goToBookmarks() => navigateToTab(2);

  /// Go to settings tab
  void goToSettings() => navigateToTab(3);
}

// ============================================
// NAVIGATION ITEM DATA CLASS
// ============================================

class NavigationItemData {
  final IconData icon;
  final String label;
  final int index;

  NavigationItemData({
    required this.icon,
    required this.label,
    required this.index,
  });
}
