import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'detail_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    final ranked = StorageService.getRankedRestaurants();
    final comparisonCount = StorageService.getComparisonCount();
    final visitedCount = ranked.length;

    // Level calculation
    int level = 1;
    String levelName = '미식 새내기';
    if (comparisonCount >= 100) {
      level = 5;
      levelName = '미식 전문가';
    } else if (comparisonCount >= 50) {
      level = 4;
      levelName = '미식 애호가';
    } else if (comparisonCount >= 20) {
      level = 3;
      levelName = '미식 탐험가';
    } else if (comparisonCount >= 5) {
      level = 2;
      levelName = '미식 견습생';
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFFF6B35),
                    child: Text(
                      StorageService.getUserName()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(StorageService.getUserName(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Lv.$level $levelName',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF6B35),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _statTile('비교', '$comparisonCount회'),
                  _statTile('방문', '$visitedCount곳'),
                  _statTile('정확도',
                      '${(70 + (comparisonCount / 10).clamp(0, 25)).toStringAsFixed(0)}%'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Wrapped banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF3D8C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('🎁 2026 미식 리포트',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('나만의 1년 식당 여정',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward,
                          color: Color(0xFFFF6B35)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Leaderboard
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('🏆 내가 사랑한 식당 TOP 10',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            if (ranked.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text('아직 평가한 식당이 없어요\n홈에서 식당을 탐색해보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54)),
                ),
              )
            else
              ...ranked.take(10).toList().asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(restaurant: r),
                    ),
                  ).then((_) => setState(() {})),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: i < 3
                            ? const Color(0xFFFF6B35)
                            : Colors.grey[200]!,
                        width: i < 3 ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text('#${i + 1}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: i < 3
                                      ? const Color(0xFFFF6B35)
                                      : Colors.black54)),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: Text(r.imageEmoji,
                                  style:
                                      const TextStyle(fontSize: 28))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              Text(r.category,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Elo ${r.overallElo.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF6B35))),
                            Text('${r.wins}승 ${r.losses}패',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
