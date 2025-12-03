import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mega_news_app/data/models/article.dart';
import 'package:mega_news_app/data/services/database_service.dart';
import 'package:mega_news_app/presentation/routes/app_routes.dart';

class BookmarkNotifier extends GetxController {
  final _bookmarkChanges = <String, bool>{}.obs;

  void notifyBookmarkChanged(String articleId, bool isBookmarked) {
    _bookmarkChanges[articleId] = isBookmarked;
  }

  bool? getBookmarkStatus(String articleId) {
    return _bookmarkChanges[articleId];
  }

  void clearNotification(String articleId) {
    _bookmarkChanges.remove(articleId);
  }
}

class NewsCard extends StatefulWidget {
  final Article article;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with AutomaticKeepAliveClientMixin {
  final dbService = DatabaseService.instance;
  bool isBookmarked = false;
  bool isCheckingBookmark = true;
  late BookmarkNotifier _notifier;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _notifier = Get.put(BookmarkNotifier(), permanent: true);
    _checkBookmarkStatus();
    ever(_notifier._bookmarkChanges, (_) {
      _onBookmarkNotified();
    });
  }

  void _onBookmarkNotified() {
    if (!mounted) return;
    final notifiedStatus = _notifier.getBookmarkStatus(widget.article.id);
    if (notifiedStatus != null) {
      setState(() {
        isBookmarked = notifiedStatus;
        isCheckingBookmark = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _checkBookmarkStatus();
    }
  }

  Future<void> _checkBookmarkStatus() async {
    if (!mounted) return;

    try {
      final status = await dbService.isArticleBookmarked(widget.article.id);
      if (mounted) {
        setState(() {
          isBookmarked = status;
          isCheckingBookmark = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isCheckingBookmark = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (!mounted) return;

    try {
      final newStatus = !isBookmarked;

      setState(() {
        isBookmarked = newStatus;
      });

      await dbService.toggleBookmark(widget.article.id, newStatus);

      final verifyStatus = await dbService.isArticleBookmarked(widget.article.id);

      if (mounted) {
        setState(() {
          isBookmarked = verifyStatus;
        });

        _notifier.notifyBookmarkChanged(widget.article.id, verifyStatus);

        Get.snackbar(
          verifyStatus ? 'تمت الإضافة'.tr : 'تمت الإزالة'.tr,
          verifyStatus
              ? 'تمت إضافة الخبر للمفضلة'.tr
              : 'تمت إزالة الخبر من المفضلة'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: verifyStatus ? Colors.green[600] : Colors.grey[700],
          colorText: Colors.white,
          icon: Icon(
            verifyStatus ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isBookmarked = !isBookmarked;
        });

        Get.snackbar(
          'خطأ'.tr,
          'فشل تحديث المفضلة',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final timeAgo = _getTimeAgo(widget.article.publishedAt);

    return GestureDetector(
      onTap: widget.onTap ?? () => AppRoutes.toNewsDetails(widget.article),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'article_${widget.article.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: widget.article.image.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: widget.article.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تعذر تحميل الصورة',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      maxHeightDiskCache: 400,
                      maxWidthDiskCache: 800,
                      memCacheHeight: 200,
                      memCacheWidth: 400,
                    )
                        : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isCheckingBookmark ? null : _toggleBookmark,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: isCheckingBookmark
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                            : Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: isBookmarked
                              ? Colors.orange
                              : Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    widget.article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.article.source.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'قبل ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'قبل ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} أيام';
    } else {
      return DateFormat('dd/MM/yyyy', 'ar').format(dateTime);
    }
  }
}