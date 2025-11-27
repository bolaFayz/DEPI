import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/theme/app_theme.dart';
import 'package:mega_news_app/presentation/modules/home/home_binding.dart';
import 'package:mega_news_app/presentation/modules/home/home_page.dart';
import 'package:mega_news_app/presentation/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.home,
      getPages: [
        GetPage(
          name: AppRoute.home,
          page: () => const HomePage(),
          binding: HomeBinding(),
        ),
        // GetPage(
        //   name: AppRoute.login,
        //   page: () => const LoginPage(),
        //   binding: LoginBinding(),
        // ),
      ],
    );
  }
}