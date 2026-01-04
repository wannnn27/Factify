import 'package:flutter/material.dart';
import '../discussion/discussion_section.dart';

class ArticleDetailWidget extends StatefulWidget {
  final Map<String, dynamic> article;
  const ArticleDetailWidget({super.key, required this.article});

  @override
  State<ArticleDetailWidget> createState() => _ArticleDetailWidgetState();
}

class _ArticleDetailWidgetState extends State<ArticleDetailWidget> {
  bool isBookmarked = false;

  void _showDiscussion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: DiscussionSection(
          contentId: 'article_${widget.article['title']}',
          contentTitle: widget.article['title'],
        ),
      ),
    );
  }

  void _showQuizDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Quiz Pemahaman',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda sudah memahami materi ini?',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              '✓ Fitur quiz akan segera hadir!',
              style: TextStyle(
                color: Color(0xFF4ECDC4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? const Color(0xFF4ECDC4) : Colors.white,
            ),
            onPressed: () {
              setState(() => isBookmarked = !isBookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBookmarked
                        ? 'Artikel disimpan'
                        : 'Artikel dihapus dari simpanan',
                  ),
                  backgroundColor: const Color(0xFF4ECDC4),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.forum_outlined,
              color: Color(0xFF4ECDC4),
            ),
            onPressed: _showDiscussion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Header
            if (widget.article['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      widget.article['imageUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: widget.article['color'].withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            widget.article['icon'] ?? Icons.article,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Author & Date in image
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.article['color'],
                                  widget.article['color'].withOpacity(0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person, size: 16, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.article['author'] ?? 'Tim Factify',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (widget.article['publishDate'] != null)
                            Text(
                              widget.article['publishDate'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.article['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.article['icon'],
                  color: widget.article['color'],
                  size: 48,
                ),
              ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.article['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            if (widget.article.containsKey('subtitle'))
              Text(
                widget.article['subtitle'],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 12),

            // Meta Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.article['category'],
                    style: const TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  widget.article['readTime'],
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Objective
            if (widget.article.containsKey('objective'))
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.article['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.article['color'].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: widget.article['color'],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tujuan Pembelajaran',
                            style: TextStyle(
                              color: widget.article['color'],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.article['objective'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.article.containsKey('objective'))
              const SizedBox(height: 24),

            // Sections
            ...widget.article['sections'].map<Widget>((section) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildSection(section),
              );
            }).toList(),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showQuizDialog,
                    icon: const Icon(Icons.quiz),
                    label: const Text('Uji Pemahaman'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showDiscussion,
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('Diskusi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4ECDC4),
                      side: const BorderSide(color: Color(0xFF4ECDC4)),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    if (section.containsKey('content')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section['title'] != 'Pendahuluan' &&
              section['title'] != 'Refleksi & Takeaway')
            Text(
              section['title'],
              style: const TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            section['content'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      );
    } else if (section.containsKey('points')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section['title'],
            style: const TextStyle(
              color: Color(0xFF4ECDC4),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...section['points'].map<Widget>((point) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ECDC4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}