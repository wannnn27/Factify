import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    final category = (widget.article['category'] as String?)?.toLowerCase() ?? '';
    switch (category) {
      case 'keamanan digital':
        return const Color(0xFF4ECDC4);
      case 'media literacy':
        return const Color(0xFFFFD93D);
      case 'digital ethics':
        return const Color(0xFF6C5CE7);
      case 'ai & technology':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF4ECDC4);
    }
  }

  void _shareArticle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Fitur berbagi artikel'),
          ],
        ),
        backgroundColor: _getCategoryColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(_isBookmarked ? 'Artikel disimpan' : 'Artikel dihapus dari simpanan'),
          ],
        ),
        backgroundColor: _getCategoryColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    // Safe access
    final title = widget.article['title'] as String? ?? 'Untitled';
    final description = widget.article['description'] as String? ?? '';
    final category = widget.article['category'] as String? ?? 'General';
    final content = widget.article['content'] as String? ?? 'No content available';
    final author = widget.article['author'] as String? ?? 'Unknown';
    final date = widget.article['date'] as String? ?? '';
    final readTime = widget.article['readTime'] as String? ?? '';
    final views = widget.article['views'] as String? ?? '';
    final imagePath = widget.article['image'] as String? ?? 'assets/images/placeholder.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0, // Lebih tinggi agar gambar lebih impactful
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fadeAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D44).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),
                actions: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _fadeAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D44).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: _isBookmarked ? categoryColor : Colors.white,
                            ),
                            onPressed: _toggleBookmark,
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _fadeAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D44).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: _shareArticle,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gambar utama - support both network and asset
                      imagePath.startsWith('http')
                          ? Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: categoryColor.withOpacity(0.4),
                                  child: const Center(
                                    child: Icon(Icons.article, color: Colors.white70, size: 80),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: categoryColor.withOpacity(0.4),
                                  child: const Center(
                                    child: Icon(Icons.article, color: Colors.white70, size: 80),
                                  ),
                                );
                              },
                            ),
                      // Overlay gradient agar konten atas terbaca
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              categoryColor.withOpacity(0.7),
                              categoryColor.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Gradient bawah untuk transisi mulus ke konten
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 140,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xFF0F0F1E),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Konten utama (tetap sama seperti kode aslimu)
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: categoryColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildMetaInfo(categoryColor, author, date, readTime, views),
                              const SizedBox(height: 24),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      categoryColor.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                content,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  height: 1.8,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildActionButtons(categoryColor),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi-fungsi pendukung (meta info, action buttons) tetap sama seperti kode aslimu
  Widget _buildMetaInfo(Color categoryColor, String author, String date, String readTime, String views) {
    // ... (copy paste dari kode asli kamu)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D2D44).withOpacity(0.4),
            const Color(0xFF2D2D44).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetaItem(icon: Icons.person_outline, text: author, color: categoryColor),
              ),
              if (date.isNotEmpty) ...[
                const SizedBox(width: 20),
                Expanded(
                  child: _buildMetaItem(icon: Icons.calendar_today, text: date, color: categoryColor),
                ),
              ],
            ],
          ),
          if (readTime.isNotEmpty || views.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (readTime.isNotEmpty)
                  Expanded(
                    child: _buildMetaItem(icon: Icons.access_time, text: readTime, color: categoryColor),
                  ),
                if (readTime.isNotEmpty && views.isNotEmpty) const SizedBox(width: 20),
                if (views.isNotEmpty)
                  Expanded(
                    child: _buildMetaItem(icon: Icons.visibility_outlined, text: views, color: categoryColor),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaItem({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color categoryColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareArticle,
            icon: const Icon(Icons.share, size: 20),
            label: const Text('Bagikan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: categoryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _toggleBookmark,
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, size: 20),
            label: Text(_isBookmarked ? 'Tersimpan' : 'Simpan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: categoryColor,
              side: BorderSide(color: categoryColor, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}