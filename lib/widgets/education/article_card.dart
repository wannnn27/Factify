import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = article['imageUrl'] != null && article['imageUrl'].toString().isNotEmpty;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D44),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            if (hasImage)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: article['imageUrl'],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheHeight: 240, // Limit memory cache size
                    memCacheWidth: 400,
                    fadeInDuration: const Duration(milliseconds: 200),
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: article['color'].withValues(alpha: 0.2),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 140,
                      color: article['color'].withValues(alpha: 0.3),
                      child: Center(
                        child: Icon(
                          article['icon'] ?? Icons.article,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: article['color'],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: article['color'].withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        article['category'] ?? 'Artikel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Read Time Badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            article['readTime'] ?? '5 menit',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  if (article['subtitle'] != null)
                    Text(
                      article['subtitle'],
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Author & Date Row
                  Row(
                    children: [
                      // Author avatar
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              article['color'],
                              article['color'].withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          article['author'] ?? 'Tim Factify',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (article['publishDate'] != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article['publishDate'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
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
}