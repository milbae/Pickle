import 'dart:math';
import '../models/restaurant.dart';

/// Elo Rating Service - 식당 쌍 비교를 위한 Elo 시스템
///
/// 작동 원리:
/// - 모든 식당은 기본 1500점에서 시작
/// - 비교 시 예상 승률 계산 → 결과에 따라 점수 변동
/// - 강한 식당(높은 Elo)이 약한 식당을 이기면 점수 변동 적음
/// - 약한 식당이 강한 식당을 이기면 점수 변동 큼
/// → 자연스럽게 분산된 점수대로 정착 (상향평준화 방지!)
class EloService {
  /// K-factor: 점수 변동 폭. 비교 횟수가 적을수록 큼 (학습 가속)
  static double _getKFactor(int totalComparisons) {
    if (totalComparisons < 10) return 64; // 초기 빠른 학습
    if (totalComparisons < 30) return 32; // 표준
    return 16; // 안정화
  }

  /// 두 식당의 예상 승률 계산
  static double _expectedScore(double ratingA, double ratingB) {
    return 1.0 / (1.0 + pow(10, (ratingB - ratingA) / 400));
  }

  /// 비교 결과에 따라 Elo 업데이트
  ///
  /// [winner]: 'A', 'B', 또는 'DRAW' (모르겠어요)
  /// [dimension]: 'overall', 'date', 'solo', 'value', 'ambiance'
  static void updateElo({
    required Restaurant restaurantA,
    required Restaurant restaurantB,
    required String winner,
    String dimension = 'overall',
  }) {
    final totalComparisons = restaurantA.wins +
        restaurantA.losses +
        restaurantA.draws +
        restaurantB.wins +
        restaurantB.losses +
        restaurantB.draws;
    final k = _getKFactor(totalComparisons);

    final eloA = _getEloByDimension(restaurantA, dimension);
    final eloB = _getEloByDimension(restaurantB, dimension);

    final expectedA = _expectedScore(eloA, eloB);
    final expectedB = 1 - expectedA;

    double actualA, actualB;
    if (winner == 'A') {
      actualA = 1.0;
      actualB = 0.0;
      restaurantA.wins++;
      restaurantB.losses++;
    } else if (winner == 'B') {
      actualA = 0.0;
      actualB = 1.0;
      restaurantA.losses++;
      restaurantB.wins++;
    } else {
      actualA = 0.5;
      actualB = 0.5;
      restaurantA.draws++;
      restaurantB.draws++;
    }

    final newEloA = eloA + k * (actualA - expectedA);
    final newEloB = eloB + k * (actualB - expectedB);

    _setEloByDimension(restaurantA, dimension, newEloA);
    _setEloByDimension(restaurantB, dimension, newEloB);
  }

  static double _getEloByDimension(Restaurant r, String dim) {
    switch (dim) {
      case 'date':
        return r.dateElo;
      case 'solo':
        return r.soloElo;
      case 'value':
        return r.valueElo;
      case 'ambiance':
        return r.ambianceElo;
      default:
        return r.overallElo;
    }
  }

  static void _setEloByDimension(Restaurant r, String dim, double value) {
    switch (dim) {
      case 'date':
        r.dateElo = value;
        break;
      case 'solo':
        r.soloElo = value;
        break;
      case 'value':
        r.valueElo = value;
        break;
      case 'ambiance':
        r.ambianceElo = value;
        break;
      default:
        r.overallElo = value;
    }
  }

  /// 초기 호불호 평가에 따른 Elo 부스트
  /// - 추천(like): +50
  /// - 잘 모르겠음(neutral): 0
  /// - 비추(dislike): -50
  static void applyInitialVerdict(Restaurant r, String verdict) {
    r.verdict = verdict;
    r.visited = true;
    if (verdict == 'like') {
      r.overallElo += 50;
    } else if (verdict == 'dislike') {
      r.overallElo -= 50;
    }
  }
}
