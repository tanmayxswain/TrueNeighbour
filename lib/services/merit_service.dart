/// Pure badge calculation logic. Points are now stored in Firestore.
class MeritService {
  MeritService._();

  /// Points awarded when a request is successfully completed (to each party).
  static const int completeReward = 25;

  // ── Badge system (pure functions) ──

  static String getBadge(int points) {
    if (points >= 500) return 'Legend';
    if (points >= 150) return 'Champion';
    if (points >= 50) return 'Helper';
    return 'Starter';
  }

  static String getNextBadge(int points) {
    if (points >= 500) return 'Legend (Max)';
    if (points >= 150) return 'Legend';
    if (points >= 50) return 'Champion';
    return 'Helper';
  }

  static int getNextBadgeThreshold(int points) {
    if (points >= 500) return 500;
    if (points >= 150) return 500;
    if (points >= 50) return 150;
    return 50;
  }

  static double getProgress(int points) {
    final thresholds = [0, 50, 150, 500];
    for (int i = 1; i < thresholds.length; i++) {
      if (points < thresholds[i]) {
        final prev = thresholds[i - 1];
        final next = thresholds[i];
        return (points - prev) / (next - prev);
      }
    }
    return 1.0;
  }

  static String getBadgeEmoji(String badge) {
    switch (badge) {
      case 'Helper':
        return '🤝';
      case 'Champion':
        return '🏆';
      case 'Legend':
        return '⭐';
      default:
        return '🌱';
    }
  }

  static const List<Map<String, dynamic>> badgeTiers = [
    {'name': 'Starter', 'threshold': 0, 'icon': '🌱'},
    {'name': 'Helper', 'threshold': 50, 'icon': '🤝'},
    {'name': 'Champion', 'threshold': 150, 'icon': '🏆'},
    {'name': 'Legend', 'threshold': 500, 'icon': '⭐'},
  ];
}
