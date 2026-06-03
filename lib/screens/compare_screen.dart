import 'dart:math';
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/elo_service.dart';
import '../services/storage_service.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Restaurant? _a;
  Restaurant? _b;
  String _dimension = 'overall';
  final Random _random = Random();

  final Map<String, String> _dimensionLabels = {
    'overall': '🍽️ 전반적',
    'date': '🍷 데이트',
    'solo': '🍱 혼밥',
    'value': '💸 가성비',
    'ambiance': '🎨 분위기',
  };

  @override
  void initState() {
    super.initState();
    _pickPair();
  }

  void _pickPair() {
    final visited = StorageService.getVisitedRestaurants();
    if (visited.length < 2) {
      setState(() {
        _a = null;
        _b = null;
      });
      return;
    }

    // 스마트 페어링: Elo 차이가 작은 식당끼리 우선 비교
    visited.shuffle(_random);
    Restaurant a = visited.first;
    Restaurant b = visited.firstWhere(
      (r) => r.id != a.id,
      orElse: () => visited[1],
    );

    // 더 좋은 매칭 찾기 (Elo 차이 < 200, 같은 카테고리 우선)
    for (int i = 0; i < visited.length; i++) {
      for (int j = i + 1; j < visited.length; j++) {
        final diff =
            (visited[i].overallElo - visited[j].overallElo).abs();
        if (diff < 200 && visited[i].category == visited[j].category) {
          a = visited[i];
          b = visited[j];
          break;
        }
      }
    }

    setState(() {
      _a = a;
      _b = b;
    });
  }

  Future<void> _vote(String winner) async {
    if (_a == null || _b == null) return;
    EloService.updateElo(
      restaurantA: _a!,
      restaurantB: _b!,
      winner: winner,
      dimension: _dimension,
    );
    await StorageService.saveRestaurants();
    await StorageService.incrementComparisonCount();

    // Feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            winner == 'A'
                ? '🎉 ${_a!.name} +${(_a!.overallElo).toStringAsFixed(0)}'
                : winner == 'B'
                    ? '🎉 ${_b!.name} +${(_b!.overallElo).toStringAsFixed(0)}'
                    : '🤝 무승부 처리됨',
          ),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
    _pickPair();
  }

  @override
  Widget build(BuildContext context) {
    if (_a == null || _b == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚔️',
                      style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  const Text('비교할 식당이 부족해요',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    '식당을 2곳 이상 방문하고 평가해야\n쌍 비교를 시작할 수 있어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() => _pickPair()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('⚔️ 오늘의 매치업',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('비교 ${StorageService.getComparisonCount()}회',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('어느 곳이 더 좋았나요?',
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 16),

              // Dimension chips
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _dimensionLabels.entries.map((e) {
                    final selected = _dimension == e.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _dimension = e.key),
                        selectedColor: const Color(0xFFFF6B35),
                        labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // VS Cards
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Expanded(child: _restaurantCard(_a!, 'A')),
                        const SizedBox(height: 16),
                        Expanded(child: _restaurantCard(_b!, 'B')),
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('VS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Vote buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _vote('A'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('⬆️ A',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _vote('DRAW'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('🤷 비슷'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _vote('B'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('⬇️ B',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _restaurantCard(Restaurant r, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child:
                  Text(r.imageEmoji, style: const TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(r.name,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${r.category} · ${r.location}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.bolt,
                        size: 14, color: Color(0xFFFF6B35)),
                    Text('Elo ${r.overallElo.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('${r.wins}승 ${r.losses}패',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
