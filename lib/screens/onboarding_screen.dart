import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../data/sample_restaurants.dart';
import '../services/elo_service.dart';
import '../services/storage_service.dart';
import 'main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final CardSwiperController _controller = CardSwiperController();
  final restaurants = SampleRestaurants.getAll();
  int _currentIndex = 0;

  Future<void> _finishOnboarding() async {
    await StorageService.setOnboarded(true);
    await StorageService.saveRestaurants();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Progress bar
              Row(
                children: [
                  Text(
                    '${_currentIndex + 1}/${restaurants.length}',
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / restaurants.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFFF6B35)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '당신의 미식 DNA를 찾아드릴게요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '왼쪽=Pass, 오른쪽=Like, 위=잘 모르겠음',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Swipe cards
              Expanded(
                child: CardSwiper(
                  controller: _controller,
                  cardsCount: restaurants.length,
                  onSwipe: (prev, current, direction) {
                    final r = restaurants[prev];
                    if (direction == CardSwiperDirection.right) {
                      EloService.applyInitialVerdict(r, 'like');
                    } else if (direction == CardSwiperDirection.left) {
                      EloService.applyInitialVerdict(r, 'dislike');
                    } else {
                      EloService.applyInitialVerdict(r, 'neutral');
                    }
                    setState(() {
                      _currentIndex = current ?? restaurants.length;
                    });
                    if (current == null) {
                      _finishOnboarding();
                    }
                    return true;
                  },
                  numberOfCardsDisplayed: 3,
                  backCardOffset: const Offset(0, 30),
                  padding: EdgeInsets.zero,
                  allowedSwipeDirection:
                      const AllowedSwipeDirection.only(
                          left: true, right: true, up: true),
                  cardBuilder: (context, index, _, __) {
                    final r = restaurants[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFFF6B35).withOpacity(0.2),
                                    const Color(0xFFFF6B35).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  r.imageEmoji,
                                  style: const TextStyle(fontSize: 150),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.name,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  '${r.location} · ${r.category} · ${r.priceRange}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: r.tags
                                      .map((tag) => Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF1EC),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              tag,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFFF6B35),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.red,
                    onTap: () => _controller.swipe(CardSwiperDirection.left),
                  ),
                  _buildActionButton(
                    icon: Icons.help_outline,
                    color: Colors.amber,
                    onTap: () => _controller.swipe(CardSwiperDirection.top),
                  ),
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: Colors.green,
                    onTap: () => _controller.swipe(CardSwiperDirection.right),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _finishOnboarding,
                child: const Text('건너뛰기',
                    style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
