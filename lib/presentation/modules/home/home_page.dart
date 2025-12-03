import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/presentation/modules/home/home_controller.dart';
import 'package:mega_news_app/presentation/shared_widgets/news_card.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _buildSearchSection(context),

            Obx(() {
              if (controller.showAdvancedSearch.value) {
                return _buildAdvancedSearchSection(context);
              }
              return const SizedBox.shrink();
            }),

            _buildCategoriesList(context),

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

      // ✅ NO bottomNavigationBar here!
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.newspaper_rounded,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Mega News',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        controller.searchNews(value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن أخبار...'.tr,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey[500],
                      ),
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            onPressed: () {
                              controller.searchController.clear();
                              controller.searchQuery.value = '';
                              controller.selectedCategory.value = 'general';
                              controller.fetchTopHeadlines();
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => controller.toggleAdvancedSearch(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSearchSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'فلتر البحث'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => controller.toggleAdvancedSearch(),
                icon: const Icon(Icons.close_rounded, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'اختر الدولة'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),

          Obx(() {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedCountry.value,
                  isExpanded: true,
                  isDense: false,
                  icon: Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  borderRadius: BorderRadius.circular(8),
                  dropdownColor: Colors.white,
                  menuMaxHeight: 300,

                  items: controller.countryLanguageMap.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value['name'] as String,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),

                  onChanged: (String? newCountry) {
                    if (newCountry != null) {
                      controller.selectedCountry.value = newCountry;
                    }
                  },
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                controller.toggleAdvancedSearch();
                controller.applyCountryFilterWithCategory();
              },
              icon: const Icon(Icons.check_rounded, size: 20),
              label: Text('تطبيق الفلتر'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : [],
                ),
                child: Center(
                  child: Text(
                    (category['name'] as String).tr,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isEmpty
                ? 'لا توجد أخبار متاحة'.tr
                : 'لا توجد نتائج للبحث'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (controller.searchQuery.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                controller.searchController.clear();
                controller.searchQuery.value = '';
                controller.fetchTopHeadlines();
              },
              child: Text('العودة للأخبار الرئيسية'.tr),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, List articles) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshCurrentView(),
      color: Theme.of(context).primaryColor,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 200) {
            if (!controller.isLoadingMore.value && controller.hasMoreData) {
              controller.loadMoreResults();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: articles.length + 1,
          itemBuilder: (context, index) {
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
                if (!controller.hasMoreData && articles.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'لا توجد أخبار أخرى'.tr,
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
      ),
    );
  }
}