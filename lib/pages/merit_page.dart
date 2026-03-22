import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/merit_service.dart';
import '../theme/app_theme.dart';

class MeritPage extends StatelessWidget {
  const MeritPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merit & Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<int>(
        future: FirestoreService.instance.getMyMeritPoints(),
        builder: (context, meritSnap) {
          final myPoints = meritSnap.data ?? 0;
          final myBadge = MeritService.getBadge(myPoints);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Your Stats ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.navy, AppColors.navy.withValues(alpha: 0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text('Your Merit', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('$myPoints', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${MeritService.getBadgeEmoji(myBadge)} $myBadge', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: MeritService.getProgress(myPoints),
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$myPoints / ${MeritService.getNextBadgeThreshold(myPoints)} to ${MeritService.getNextBadge(myPoints)}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Badge Tiers ──
                const Text('Badge Tiers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyDark)),
                const SizedBox(height: 12),
                Row(
                  children: MeritService.badgeTiers.map((tier) {
                    final isActive = myPoints >= (tier['threshold'] as int);
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.teal.withValues(alpha: 0.1) : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isActive ? AppColors.teal.withValues(alpha: 0.4) : AppColors.border, width: 1.5),
                        ),
                        child: Column(children: [
                          Text(tier['icon'] as String, style: TextStyle(fontSize: isActive ? 24 : 20)),
                          const SizedBox(height: 4),
                          Text(tier['name'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? AppColors.teal : AppColors.textSecondary)),
                          Text('${tier['threshold']}+', style: TextStyle(fontSize: 10, color: isActive ? AppColors.teal.withValues(alpha: 0.7) : AppColors.textSecondary.withValues(alpha: 0.6))),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // ── Leaderboard (StreamBuilder) ──
                const Text('Leaderboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyDark)),
                const SizedBox(height: 12),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService.instance.streamLeaderboard(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final leaderboard = snap.data ?? [];
                    if (leaderboard.isEmpty) {
                      return const Center(child: Text('No users yet.', style: TextStyle(color: AppColors.textSecondary)));
                    }
                    return Column(
                      children: leaderboard.asMap().entries.map((entry) {
                        final rank = entry.key + 1;
                        final person = entry.value;
                        final isYou = person['uid'] == currentUid;
                        final pts = person['meritPoints'] as int;
                        final badge = MeritService.getBadge(pts);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isYou ? AppColors.teal.withValues(alpha: 0.08) : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: isYou ? Border.all(color: AppColors.teal, width: 1.5) : Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: rank <= 3 ? 20 : 14, fontWeight: FontWeight.w700, color: AppColors.navyDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    isYou ? 'You' : (person['name'] as String),
                                    style: TextStyle(fontSize: 14, fontWeight: isYou ? FontWeight.w700 : FontWeight.w500, color: isYou ? AppColors.teal : AppColors.navyDark),
                                  ),
                                  Text('${MeritService.getBadgeEmoji(badge)} $badge', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ]),
                              ),
                              Text('$pts pts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isYou ? AppColors.teal : AppColors.navy)),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
