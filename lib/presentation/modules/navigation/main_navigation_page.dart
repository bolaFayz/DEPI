import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_navigation_controller.dart';

class MainNavigationPage extends GetView<MainNavigationController> {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: controller.pages,
        ),
      ),


      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: controller.navigationItems
                  .map((item) => _buildNavigationItem(context, item))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildNavigationItem(BuildContext context, NavigationItemData item) {
    final isActive = controller.isTabActive(item.index);
    final primaryColor = Theme.of(context).primaryColor;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.changeTab(item.index),
          borderRadius: BorderRadius.circular(12),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Icon with animated background
                _buildAnimatedIcon(
                  icon: item.icon,
                  isActive: isActive,
                  primaryColor: primaryColor,
                ),

                const SizedBox(height: 4),

                // ✅ Label
                _buildLabel(
                  label: item.label,
                  isActive: isActive,
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ============================================
  /// ANIMATED ICON
  /// ============================================

  Widget _buildAnimatedIcon({
    required IconData icon,
    required bool isActive,
    required Color primaryColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isActive ? primaryColor : Colors.grey[600],
        size: 24,
      ),
    );
  }

  /// ============================================
  /// LABEL
  /// ============================================

  Widget _buildLabel({
    required String label,
    required bool isActive,
    required Color primaryColor,
  }) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      style: TextStyle(
        fontSize: 10,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        color: isActive ? primaryColor : Colors.grey[600],
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
