import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/localization/locale_controller.dart';
import 'package:mega_news_app/presentation/modules/settings/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات'.tr), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🌐 اللغة
          _buildLanguageCard(context),

          const SizedBox(height: 12),

          // 🌍 الدولة الافتراضية
          _buildCountryCard(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// ============================================
  /// LANGUAGE CARD - ✅ FIXED
  /// ============================================

  Widget _buildLanguageCard(BuildContext context) {
    // ✅ FIX 1: استخدام GetBuilder بدلاً من Obx للتأكد من وجود LocaleController
    return GetBuilder<LocaleController>(
      init: LocaleController(), // ✅ سيتم إنشاؤه تلقائياً إذا لم يكن موجوداً
      builder: (localeController) {
        return _buildSettingCard(
          context: context,
          icon: Icons.language,
          iconColor: Colors.blue,
          title: 'اللغة'.tr,
          subtitle: 'تغيير لغة التطبيق'.tr,
          onTap: () => _showLanguageDialog(context, localeController),
          trailing: Text(
            localeController.isArabic ? 'العربية' : 'English',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  /// ============================================
  /// COUNTRY CARD
  /// ============================================

  Widget _buildCountryCard(BuildContext context) {
    return _buildSettingCard(
      context: context,
      icon: Icons.public,
      iconColor: Colors.green,
      title: 'الدولة الافتراضية'.tr,
      subtitle: 'اختر الدولة لعرض أخبارها'.tr,
      onTap: () => _showCountryDialog(context),
      trailing: Obx(
            () => Text(
          controller.getCountryName(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// ============================================
  /// SETTING CARD WIDGET
  /// ============================================

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing:
        trailing ??
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ),
    );
  }

  /// ============================================
  /// LANGUAGE DIALOG - ✅ FIXED
  /// ============================================

  void _showLanguageDialog(
      BuildContext context,
      LocaleController localeController,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر اللغة'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arabic Option - ✅ FIX 2: استخدام GetBuilder بدلاً من Obx داخل Dialog
            GetBuilder<LocaleController>(
              builder: (controller) => RadioListTile<String>(
                title: const Text('العربية'),
                value: 'ar',
                groupValue: controller.currentLanguage,
                onChanged: (value) {
                  if (value != null) {
                    controller.changeLanguage(value);
                    Get.back();
                    Get.snackbar(
                      'تم التغيير'.tr,
                      'تم تغيير اللغة بنجاح',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green[600],
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                    );
                  }
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ),

            // English Option
            GetBuilder<LocaleController>(
              builder: (controller) => RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: controller.currentLanguage,
                onChanged: (value) {
                  if (value != null) {
                    controller.changeLanguage(value);
                    Get.back();
                    Get.snackbar(
                      'Changed',
                      'Language changed successfully',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green[600],
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                    );
                  }
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// COUNTRY DIALOG - ✅ FIXED
  /// ============================================

  void _showCountryDialog(BuildContext context) {
    // ✅ FIX 3: حفظ القيمة الحالية قبل فتح الـ Dialog
    final currentCountry = controller.selectedCountry.value;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('اختر الدولة'.tr),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(dialogContext).size.height * 0.5,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.countryList.length,
            itemBuilder: (context, index) {
              final country = controller.countryList[index];

              // ✅ FIX 4: استخدام GetBuilder بدلاً من Obx
              return GetBuilder<SettingsController>(
                id: 'country_selection', // ✅ استخدام ID محدد للتحديث
                builder: (ctrl) {
                  final isSelected = ctrl.selectedCountry.value == country['code'];

                  return RadioListTile<String>(
                    title: Text(country['name'] as String),
                    value: country['code'] as String,
                    groupValue: ctrl.selectedCountry.value,
                    onChanged: (value) {
                      if (value != null) {
                        ctrl.changeCountry(value);
                        Get.back();
                      }
                    },
                    activeColor: Theme.of(dialogContext).primaryColor,
                    selected: isSelected,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}