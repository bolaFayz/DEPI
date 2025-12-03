import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mega_news_app/core/localization/locale_controller.dart';
import 'package:mega_news_app/core/localization/app_transaltions.dart';
import 'package:mega_news_app/core/theme/app_theme.dart';
import 'package:mega_news_app/data/services/cache_manager.dart';
import 'package:mega_news_app/data/services/database_service.dart';
import 'package:mega_news_app/presentation/routes/app_routes.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize GetStorage for local storage
    await GetStorage.init();

    // Initialize Arabic date formatting
    await initializeDateFormatting('ar', null);

    // Initialize database
    await _initializeDatabase();

    // Clean old cache on startup
    await _cleanOldCache();

    // Log startup statistics
    await _logStartupStats();

  } catch (e, stackTrace) {
    //developer.log('Stack trace: $stackTrace', name: 'MAIN');
  }

  // Run the app
  runApp(const MyApp());
}


/// Initialize the local database
Future<void> _initializeDatabase() async {
  try {
    await DatabaseService.instance.init();
  } catch (e) {
    rethrow;
  }
}

/// Clean old cached articles
Future<void> _cleanOldCache() async {
  try {

    final cacheManager = CacheManager();
    await cacheManager.cleanOldCache();
  } catch (e) {
    //developer.log('⚠️ Cache cleaning failed: $e', name: 'CACHE');
    // Don't throw - this is not critical
  }
}

/// Log startup statistics
Future<void> _logStartupStats() async {
  try {
    final dbService = DatabaseService.instance;

    // Get article counts
    final totalArticles = await dbService.getArticlesCount();
    final bookmarkedArticles = await dbService.getBookmarkedCount();
  } catch (e) {
    //developer.log('⚠️ Stats logging failed: $e', name: 'STATS');
  }
}

/// ============================================
/// APP WIDGET
/// ============================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize locale controller
    final localeController = Get.put(LocaleController(), permanent: true);

    return GetMaterialApp(
      // ============================================
      // APP CONFIGURATION
      // ============================================

      title: 'Mega News',
      debugShowCheckedModeBanner: false,

      // ============================================
      // THEME
      // ============================================

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // TODO: Add dark theme if needed

      // ============================================
      // LOCALIZATION
      // ============================================

      locale: Locale(localeController.appLang),
      translations: AppTranslations(),
      fallbackLocale: const Locale('ar'),

      // ============================================
      // NAVIGATION
      // ============================================

      initialRoute: AppRoutes.mainWrapper,
      getPages: AppRoutes.routes,

      // ============================================
      // DEFAULT TRANSITIONS
      // ============================================

      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // ============================================
      // ERROR HANDLING
      // ============================================

      // Custom error widget (optional)
      builder: (context, child) {
        // You can add error boundary or other wrappers here
        return child ?? const SizedBox.shrink();
      },
      smartManagement: SmartManagement.full,

      enableLog: true,
      logWriterCallback: (text, {isError = false}) {
      },
    );
  }
}