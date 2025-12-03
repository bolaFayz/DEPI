import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'timeline_controller.dart';

class TimelinePage extends GetView<TimelineController> {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState(context);
                }

                // ✅ FIX: استخدام timelineData.value?.days بدلاً من timelineGroups
                final timelineDays = controller.timelineData.value?.days ?? [];

                if (timelineDays.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildTimelineList(context, timelineDays);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'الخط الزمني',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: controller.searchController,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.searchTimeline(value);
                }
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن موضوع...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      onPressed: controller.clearTimeline,
                      icon: Icon(Icons.close_rounded, color: Colors.grey[600]),
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
        ],
      ),
    );
  }

  // ✅ FIX: تمرير timelineDays كـ parameter
  Widget _buildTimelineList(BuildContext context, List<dynamic> timelineDays) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timelineDays.length,
      itemBuilder: (context, groupIndex) {
        final group = timelineDays[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupIndex > 0) const SizedBox(height: 32),
            _buildDateHeader(context, group),
            const SizedBox(height: 16),
            Timeline.tileBuilder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              theme: TimelineThemeData(
                nodePosition: 0.05,
                color: Theme.of(context).primaryColor,
                indicatorTheme: IndicatorThemeData(
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                connectorTheme: ConnectorThemeData(
                  thickness: 2.5,
                  color: Colors.grey[300]!,
                ),
              ),
              builder: TimelineTileBuilder.connected(
                itemCount: group.articles.length, // ✅ FIX: استخدام articles بدلاً من items
                contentsAlign: ContentsAlign.basic,
                oppositeContentsBuilder: (context, index) {
                  final item = group.articles[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      _getTimeString(item.article.publishedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                indicatorBuilder: (context, index) {
                  return DotIndicator(
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  );
                },
                connectorBuilder: (context, index, type) {
                  return SolidLineConnector(
                    color: Colors.grey[300]!,
                    thickness: 2.5,
                  );
                },
                contentsBuilder: (context, index) {
                  final item = group.articles[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 16),
                    child: _buildArticleCard(context, item),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, group) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            // ✅ FIX: استخدام displayDate بدلاً من dateLabel
            '${group.displayDate} (${group.articles.length} أخبار)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, item) {
    return GetBuilder<TimelineController>(
      builder: (_) => GestureDetector(
        onTap: () => Get.toNamed('/news_details', arguments: item.article),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.article.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.hasSummary) _buildSummaryBadge(context),
                ],
              ),
              const SizedBox(height: 8),
              if (item.hasSummary)
                _buildSummarySection(context, item)
              else if (item.isExtracting)
                _buildExtractingState(context)
              else
                _buildDescriptionSection(context, item),
              if (!item.hasSummary && !item.isExtracting)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () => controller.extractSummary(item),
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text(
                      'احصل على ملخص',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: Colors.green[700]),
          const SizedBox(width: 4),
          Text(
            'ملخص',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, item) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text(
                'الملخص:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            // ✅ FIX: استخدام extractedSummary بدلاً من summary
            item.extractedSummary ?? item.article.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'جاري الاستخراج...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, item) {
    return Text(
      item.article.description,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: Colors.grey[700],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getTimeString(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: Theme.of(context).primaryColor,
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري البحث...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline_rounded,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'ابحث عن موضوع',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اكتشف تطور الأحداث عبر الزمن',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}