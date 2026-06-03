import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/restaurant.dart';
import '../services/elo_service.dart';
import '../services/storage_service.dart';

class DetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  const DetailScreen({super.key, required this.restaurant});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Future<void> _setVerdict(String verdict) async {
    EloService.applyInitialVerdict(widget.restaurant, verdict);
    await StorageService.saveRestaurants();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verdict == 'like'
              ? '👍 추천으로 평가했어요!'
              : verdict == 'dislike'
                  ? '👎 비추로 평가했어요'
                  : '🤷 잘 모르겠음으로 평가했어요'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  int _getMyRank() {
    final ranked = StorageService.getRankedRestaurants();
    final idx = ranked.indexWhere((r) => r.id == widget.restaurant.id);
    return idx + 1;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final rank = _getMyRank();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B35),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF6B35).withOpacity(0.4),
                      const Color(0xFFFF6B35).withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(r.imageEmoji,
                      style: const TextStyle(fontSize: 140)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      '${r.location} · ${r.category} · ${r.priceRange}',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: r.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1EC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(t,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFF6B35))),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(r.description,
                      style: const TextStyle(
                          fontSize: 14, height: 1.5)),
                  const SizedBox(height: 24),

                  // My Elo Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B35),
                          Color(0xFFFF8A60),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('내 개인 Elo',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(r.overallElo.toStringAsFixed(0),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (rank > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('🏆 내 TOP #$rank',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Multi-dimensional Elo
                  const Text('차원별 Elo',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        tickCount: 4,
                        ticksTextStyle: const TextStyle(
                            color: Colors.transparent, fontSize: 1),
                        radarBorderData: const BorderSide(
                            color: Colors.transparent),
                        gridBorderData: BorderSide(
                            color: Colors.grey[300]!, width: 1),
                        tickBorderData: BorderSide(
                            color: Colors.grey[300]!, width: 1),
                        titleTextStyle: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                        getTitle: (idx, _) {
                          const titles = [
                            '전반',
                            '데이트',
                            '혼밥',
                            '가성비',
                            '분위기'
                          ];
                          return RadarChartTitle(text: titles[idx]);
                        },
                        dataSets: [
                          RadarDataSet(
                            fillColor: const Color(0xFFFF6B35)
                                .withOpacity(0.3),
                            borderColor: const Color(0xFFFF6B35),
                            borderWidth: 2,
                            entryRadius: 3,
                            dataEntries: [
                              RadarEntry(value: r.overallElo / 25),
                              RadarEntry(value: r.dateElo / 25),
                              RadarEntry(value: r.soloElo / 25),
                              RadarEntry(value: r.valueElo / 25),
                              RadarEntry(value: r.ambianceElo / 25),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _statCard('🏆 승', '${r.wins}'),
                      const SizedBox(width: 8),
                      _statCard('💔 패', '${r.losses}'),
                      const SizedBox(width: 8),
                      _statCard('🤝 무', '${r.draws}'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Verdict buttons
                  const Text('이 식당 어땠어요?',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _verdictBtn('👍 추천', 'like', Colors.green,
                            r.verdict == 'like'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _verdictBtn('🤷 모르겠음', 'neutral',
                            Colors.amber, r.verdict == 'neutral'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _verdictBtn('👎 비추', 'dislike',
                            Colors.red, r.verdict == 'dislike'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _verdictBtn(
      String label, String verdict, Color color, bool selected) {
    return ElevatedButton(
      onPressed: () => _setVerdict(verdict),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? color : Colors.white,
        foregroundColor: selected ? Colors.white : color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
