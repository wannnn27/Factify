// lib/screens/tabs/education_screen.dart
import 'package:flutter/material.dart';
import '../../data/education_data.dart';
import '../../widgets/education/video_card.dart';
import '../../widgets/education/article_card.dart';
import '../../widgets/education/video_player_widget.dart';
import '../../widgets/education/article_detail_widget.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredVideos = [];
  List<Map<String, dynamic>> filteredArticles = [];

  @override
  void initState() {
    super.initState();
    filteredVideos = EducationData.videos;
    filteredArticles = EducationData.articles;
    _searchController.addListener(_filterContent);
  }

  void _filterContent() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredVideos = EducationData.videos.where((video) {
        final matchesQuery = query.isEmpty ||
            video['title'].toString().toLowerCase().contains(query) ||
            video['description'].toString().toLowerCase().contains(query);
        final matchesCategory = selectedCategory == 'Semua' || 
            video['category'] == selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();

      filteredArticles = EducationData.articles.where((article) {
        final matchesQuery = query.isEmpty ||
            article['title'].toString().toLowerCase().contains(query) ||
            (article['subtitle']?.toString().toLowerCase().contains(query) ?? false) ||
            (article['objective']?.toString().toLowerCase().contains(query) ?? false);
        final matchesCategory = selectedCategory == 'Semua' || 
            article['category'] == selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ruang Edukasi',
                          style: TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.stars,
                                color: Color(0xFF4ECDC4),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${filteredVideos.length + filteredArticles.length} Materi',
                                style: const TextStyle(
                                  color: Color(0xFF4ECDC4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari topik seperti "phishing"...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: EducationData.categories.length,
                        itemBuilder: (context, index) {
                          final category = EducationData.categories[index];
                          final isSelected = selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedCategory = category;
                                    _filterContent();
                                  });
                                }
                              },
                              backgroundColor: const Color(0xFF2D2D44),
                              selectedColor: const Color(0xFF4ECDC4),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              side: BorderSide.none,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Video Section
            if (filteredVideos.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Video Pembelajaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${filteredVideos.length} video',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredVideos.length,
                          itemBuilder: (context, index) {
                            return VideoCard(
                              video: filteredVideos[index],
                              onTap: () => _openVideoPlayer(filteredVideos[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Article Section
            if (filteredArticles.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Artikel & Panduan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${filteredArticles.length} artikel',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...filteredArticles.map(
                        (article) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ArticleCard(
                            article: article,
                            onTap: () => _openArticleDetail(article),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Empty State
            if (filteredVideos.isEmpty && filteredArticles.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada hasil ditemukan',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Coba kata kunci atau kategori lain',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  void _openVideoPlayer(Map<String, dynamic> video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerWidget(video: video),
      ),
    );
  }

  void _openArticleDetail(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailWidget(article: article),
      ),
    );
  }
}