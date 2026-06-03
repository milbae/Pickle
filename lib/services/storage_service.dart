import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import '../data/sample_restaurants.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static List<Restaurant> _restaurants = [];

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadRestaurants();
  }

  static void _loadRestaurants() {
    _restaurants = SampleRestaurants.getAll();
    final savedState = _prefs.getString('restaurant_states');
    if (savedState != null) {
      try {
        final Map<String, dynamic> states = jsonDecode(savedState);
        for (final r in _restaurants) {
          if (states.containsKey(r.id)) {
            r.applyState(states[r.id]);
          }
        }
      } catch (_) {}
    }
  }

  static Future<void> saveRestaurants() async {
    final Map<String, dynamic> states = {};
    for (final r in _restaurants) {
      states[r.id] = r.toJson();
    }
    await _prefs.setString('restaurant_states', jsonEncode(states));
  }

  static List<Restaurant> getAllRestaurants() => _restaurants;

  static List<Restaurant> getVisitedRestaurants() =>
      _restaurants.where((r) => r.visited).toList();

  static List<Restaurant> getRankedRestaurants() {
    final visited = getVisitedRestaurants();
    visited.sort((a, b) => b.overallElo.compareTo(a.overallElo));
    return visited;
  }

  static bool isOnboarded() => _prefs.getBool('onboarded') ?? false;

  static Future<void> setOnboarded(bool value) async {
    await _prefs.setBool('onboarded', value);
  }

  static String getUserName() => _prefs.getString('user_name') ?? '민지';

  static Future<void> setUserName(String name) async {
    await _prefs.setString('user_name', name);
  }

  static int getComparisonCount() => _prefs.getInt('comparison_count') ?? 0;

  static Future<void> incrementComparisonCount() async {
    await _prefs.setInt('comparison_count', getComparisonCount() + 1);
  }
}
