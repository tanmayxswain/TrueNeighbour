import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Current user for profile section
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User Name';

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header Profile Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Section',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, size: 36, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, thickness: 1.5, height: 1),
            // Menu Items
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            _buildMenuItem(
              icon: Icons.assignment_outlined,
              title: 'My Claims',
              onTap: () {},
            ),
            const Divider(color: AppColors.border, indent: 20, endIndent: 20, height: 1),
            _buildMenuItem(
              icon: Icons.history,
              title: 'History',
              onTap: () {},
            ),
            const Divider(color: AppColors.border, indent: 20, endIndent: 20, height: 1),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {},
            ),
            const Divider(color: AppColors.border, indent: 20, endIndent: 20, height: 1),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Log Out',
              color: AppColors.error,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.navyDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }
}
