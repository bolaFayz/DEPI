import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleController extends GetxController {
  final storage = GetStorage();

  late String appLang;

  @override
  void onInit() {
    super.onInit();
    appLang = storage.read('appLang') ?? 'ar';
  }

  void changeLanguage(String lang) {
    appLang = lang;
    storage.write('appLang', lang);
    Get.updateLocale(Locale(lang));
    update();
  }

  String get currentLanguage => appLang;
  bool get isArabic => appLang == 'ar';
  bool get isEnglish => appLang == 'en';
}