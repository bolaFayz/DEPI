import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mega_news_app/presentation/modules/news%20details/news_details_page.dart';
import 'package:mega_news_app/presentation/modules/news%20details/news_details_binding.dart';

import '../modules/navigation/main_navigation_binding.dart';
import '../modules/navigation/main_navigation_page.dart';


class AppRoutes {
  static const String mainWrapper = '/main_wrapper';
  static const String newsDetails = '/news_details';
  static const String home = '/home';
  static const String timeline = '/timeline';
  static const String bookmarks = '/bookmarks';
  static const String settings = '/settings';
  static final routes = [

    GetPage(
      name: mainWrapper,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: newsDetails,
      page: () => const NewsDetailsPage(),
      binding: NewsDetailsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),

      // animation
      curve: Curves.easeInOut,
      preventDuplicates: true,
      fullscreenDialog: false,
    ),
    // GetPage(
    //   name: newsDetails,
    //   page: () => const NewsDetailsPage(),
    //   binding: NewsDetailsBinding(),
    // ),
  ];

  static void toNewsDetails(article) {
    Get.toNamed(
      newsDetails,
      arguments: article,
      preventDuplicates: true,
    );
  }
}