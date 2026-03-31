import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // ── Tappable Profile Header ──
            StreamBuilder<Map<String, dynamic>?>(
              stream: FirestoreService.instance.streamUserProfile(),
              builder: (context, snapshot) {
                final data = snapshot.data;
                final userName = data?['name'] ?? user?.displayName ?? 'User Name';
                
                return InkWell(
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.navy),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navyDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'View Profile',
                                    style: TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.teal),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
            const Divider(color: AppColors.border, thickness: 1.5, height: 1),

            const Padding(
              padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Menu', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ),
            ),

            _buildMenuItem(
              icon: Icons.list_alt,
              title: 'My Requests',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-requests');
              },
            ),
            _buildMenuItem(
              icon: Icons.volunteer_activism,
              title: 'My Claims',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-claims');
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              title: 'History',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/history');
              },
            ),
            _buildMenuItem(
              icon: Icons.emoji_events_outlined,
              title: 'Merit & Badges',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/merit');
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),

            const Spacer(),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.navyDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
