import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/restaurant.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final allRestaurants = StorageService.getAllRestaurants();
    // 추천 TOP 5: Elo 높은 순
    final topRecommended = List<Restaurant>.from(allRestaurants)
      ..sort((a, b) => b.overallElo.compareTo(a.overallElo));
    final top5 = topRecommended.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('FoodMatch',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35))),
                    Icon(Icons.notifications_outlined,
                        color: Colors.grey[700]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('안녕하세요, ${StorageService.getUserName()}님 👋',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 4),
                    const Text('오늘은 어떤 곳이 끌리나요?',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // TOP 5
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('🔥 오늘의 추천 TOP 5',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: top5.length,
                  itemBuilder: (context, i) {
                    final r = top5[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(restaurant: r),
                        ),
                      ).then((_) => setState(() {})),
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1EC),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              child: Center(
                                child: Text(r.imageEmoji,
                                    style: const TextStyle(fontSize: 60)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text(r.category,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.bolt,
                                          size: 12,
                                          color: Color(0xFFFF6B35)),
                                      Text(
                                          ' Elo ${r.overallElo.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFFF6B35),
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Mood Playlist
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('🎵 기분별 플레이리스트',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _moodCard('💼', '혼밥하기 좋은 곳',
                        const Color(0xFFFFE5D9)),
                    _moodCard('💕', '데이트 분위기',
                        const Color(0xFFFFD6E0)),
                    _moodCard(
                        '👨‍👩‍👧', '가족 모임', const Color(0xFFD9F1FF)),
                    _moodCard(
                        '🌧️', '비 오는 날', const Color(0xFFE3D9FF)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // All restaurants
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('🍽️ 전체 식당',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ...allRestaurants.map((r) => _restaurantTile(r)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moodCard(String emoji, String title, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _restaurantTile(Restaurant r) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(restaurant: r)),
      ).then((_) => setState(() {})),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(r.imageEmoji,
                      style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('${r.category} · ${r.location}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  if (r.visited)
                    Row(
                      children: [
                        Icon(
                          r.verdict == 'like'
                              ? Icons.thumb_up
                              : r.verdict == 'dislike'
                                  ? Icons.thumb_down
                                  : Icons.help_outline,
                          size: 12,
                          color: r.verdict == 'like'
                              ? Colors.green
                              : r.verdict == 'dislike'
                                  ? Colors.red
                                  : Colors.amber,
                        ),
                        Text(' Elo ${r.overallElo.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  else
                    const Text('미방문',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
