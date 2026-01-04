import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:factify/screens/tabs/home/tip_detail_screen.dart';

class AllTipsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tips;

  const AllTipsScreen({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Semua Tips Literasi Digital',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            final Color color = tip['color'] as Color;

            return AnimatedContainer(
              duration: Duration(milliseconds: 400 + index * 100),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TipDetailScreen(tip: tip)),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4), width: 1.5),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: tip['imageUrl'] as String,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: color.withOpacity(0.3),
                              child: const Center(child: CircularProgressIndicator(color: Colors.white54)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: color.withOpacity(0.3),
                              child: Icon(tip['icon'], color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['title'],
                                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                tip['shortDescription'],
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.6), size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}