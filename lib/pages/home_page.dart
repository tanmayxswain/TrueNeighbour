import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final displayName = user?.displayName ?? 'Neighbour';
    final phone = user?.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueNeighbour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () async {
              await _authService.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Success icon ──
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 56,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome, $displayName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '✅  You are authenticated!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'This is a placeholder home page.\nYour feed and community features\nwill appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
