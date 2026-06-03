class Restaurant {
  final String id;
  final String name;
  final String category;
  final String location;
  final String priceRange;
  final String imageEmoji; // Using emoji as placeholder image
  final String description;
  final List<String> tags;

  // Multi-dimensional Elo scores (personalized per user)
  double overallElo;
  double dateElo;
  double soloElo;
  double valueElo;
  double ambianceElo;

  // Verdict: 'like', 'neutral', 'dislike', null (not visited)
  String? verdict;
  bool visited;

  // Comparison stats
  int wins;
  int losses;
  int draws;

  Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.priceRange,
    required this.imageEmoji,
    required this.description,
    required this.tags,
    this.overallElo = 1500,
    this.dateElo = 1500,
    this.soloElo = 1500,
    this.valueElo = 1500,
    this.ambianceElo = 1500,
    this.verdict,
    this.visited = false,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'overallElo': overallElo,
        'dateElo': dateElo,
        'soloElo': soloElo,
        'valueElo': valueElo,
        'ambianceElo': ambianceElo,
        'verdict': verdict,
        'visited': visited,
        'wins': wins,
        'losses': losses,
        'draws': draws,
      };

  void applyState(Map<String, dynamic> json) {
    overallElo = (json['overallElo'] ?? 1500).toDouble();
    dateElo = (json['dateElo'] ?? 1500).toDouble();
    soloElo = (json['soloElo'] ?? 1500).toDouble();
    valueElo = (json['valueElo'] ?? 1500).toDouble();
    ambianceElo = (json['ambianceElo'] ?? 1500).toDouble();
    verdict = json['verdict'];
    visited = json['visited'] ?? false;
    wins = json['wins'] ?? 0;
    losses = json['losses'] ?? 0;
    draws = json['draws'] ?? 0;
  }
}
