import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/presentation/modules/home/home_controller.dart';
import '../../shared widgets/custom_card.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar + Categories
            _buildSearchSection(context),

            // Categories List
            Obx(() {
              if (controller.showCategories.value) {
                return _buildCategoriesList(context);
              }
              return const SizedBox.shrink();
            }),

            // Main News List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: Theme.of(context).primaryColor,
                      size: 50,
                    ),
                  );
                }

                final articles = controller.displayedArticles;

                if (articles.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildNewsList(context, articles);
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Search Bar Section
  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          if (value.isEmpty) {
            controller.clearSearch();
          }
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            controller.searchNews(value);
            controller.showCategories.value = false;
          }
        },
        onTap: () {
          controller.showCategories.value = true;
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن أخبار...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                onPressed: () {
                  controller.clearSearch();
                },
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  /// Categories Horizontal List
  Widget _buildCategoriesList(BuildContext context) {
    final categories = [
      {'name': 'الكل', 'value': 'general'},
      {'name': 'عالمي', 'value': 'world'},
      {'name': 'أعمال', 'value': 'business'},
      {'name': 'تكنولوجيا', 'value': 'technology'},
      {'name': 'ترفيه', 'value': 'entertainment'},
      {'name': 'رياضة', 'value': 'sports'},
      {'name': 'علوم', 'value': 'science'},
      {'name': 'صحة', 'value': 'health'},
    ];

    return Container(
      height: 50,
      color: Colors.grey[50],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Obx(() {
            final isSelected =
                controller.selectedCategory.value == category['value'];
            return GestureDetector(
              onTap: () {
                controller.filterByCategory(category['value'] as String);
                controller.showCategories.value = false;
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  /// Empty State Widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isEmpty
                ? 'لا توجد أخبار متاحة'
                : 'لا توجد نتائج للبحث',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (controller.searchQuery.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => controller.clearSearch(),
              child: const Text('العودة للأخبار الرئيسية'),
            ),
          ],
        ],
      ),
    );
  }

  /// News List with Pagination
  Widget _buildNewsList(BuildContext context, List articles) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Detect when near bottom
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          if (!controller.isLoadingMore.value && controller.hasMoreData) {
            controller.loadMoreResults();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: articles.length + 1, // +1 for loading indicator
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == articles.length) {
            return Obx(() {
              if (controller.isLoadingMore.value) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: SpinKitWaveSpinner(
                      trackColor: Colors.grey[300]!,
                      color: Theme.of(context).primaryColor,
                      size: 40,
                    ),
                  ),
                );
              }
              // No more data indicator
              if (!controller.hasMoreData && articles.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'لا توجد أخبار أخرى',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            });
          }

          final article = articles[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: NewsCard(article: article),
          );
        },
      ),
    );
  }
}