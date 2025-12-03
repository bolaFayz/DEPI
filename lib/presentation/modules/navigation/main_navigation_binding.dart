import 'package:get/get.dart';
import 'package:mega_news_app/presentation/modules/home/home_controller.dart';
import 'package:mega_news_app/presentation/modules/timeline/timeline_controller.dart';
import 'package:mega_news_app/presentation/modules/bookmarks/bookmarks_controller.dart';
import 'package:mega_news_app/presentation/modules/settings/settings_controller.dart';

import 'main_navigation_controller.dart';



class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Register MainNavigationController
    Get.put(
      MainNavigationController(),
      permanent: true,
    );

    // Home Controller
    Get.put(
      HomeController(),
      permanent: true,
    );

    // Timeline Controller
    Get.put(
      TimelineController(),
      permanent: true,
    );

    // Bookmarks Controller
    Get.put(
      BookmarksController(),
      permanent: true,
    );

    // Settings Controller
    Get.put(
      SettingsController(),
      permanent: true,
    );
  }
}