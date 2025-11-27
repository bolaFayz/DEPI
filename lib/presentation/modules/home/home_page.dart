import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/presentation/modules/home/home_controller.dart';
import 'package:intl/intl.dart';

import '../../../data/models/article.dart';
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
            _buildSearchAndCategoriesSection(context),

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

                final newsList = controller.currentNewsList;

                if (newsList.isEmpty) {
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
                              ? 'لا توجد أخبار'
                              : 'لا توجد نتائج للبحث',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return controller.showTimeline.value
                    ? _buildTimelineView(newsList)
                    : _buildCardListView(newsList);
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Search Bar and Categories Section
  Widget _buildSearchAndCategoriesSection(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: _buildSearchBar(context),
        ),

        // Categories List (appears when search is focused)
        Obx(() {
          if (!controller.showCategories.value) {
            return const SizedBox.shrink();
          }

          return _buildCategoriesList(context);
        }),
      ],
    );
  }

  /// Search Bar Widget
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      onChanged: (value) {
        if (value.isEmpty) {
          controller.searchQuery.value = '';
          controller.searchResults.clear();
          controller.showTimeline.value = false;
        }
      },
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          controller.searchNews(value);
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
            return GestureDetector(
              onTap: () {
                controller.searchQuery.value = '';
                controller.searchResults.clear();
              },
              child: Icon(
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

  /// Normal Card List View
  Widget _buildCardListView(List<Article> articles) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: articles.length + (controller.isLoadingMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index == articles.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SpinKitWaveSpinner(
              trackColor: Colors.grey[300]!,
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        }

        final article = articles[index];

        // Load more when reaching near the end
        if (index == articles.length - 3) {
          controller.loadMoreResults();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: NewsCard(article: article),
        );
      },
    );
  }

  /// Timeline View
  Widget _buildTimelineView(List<Article> articles) {
    // Sort articles by date (newest first)
    final sorted = articles
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final article = sorted[index];
        final date = DateFormat('dd/MM/yyyy', 'ar').format(article.publishedAt);

        // Show date header if different from previous
        bool showDateHeader = index == 0 ||
            DateFormat('dd/MM/yyyy')
                .format(sorted[index - 1].publishedAt) !=
                DateFormat('dd/MM/yyyy').format(article.publishedAt);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
            // Timeline item
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline dot
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index != sorted.length - 1)
                      Container(
                        width: 2,
                        height: 80,
                        color: Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Timeline card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: NewsCard(article: article),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}