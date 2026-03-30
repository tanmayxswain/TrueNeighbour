import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/merit_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _taglineController;
  bool _editing = false;
  bool _loading = true;
  int _meritPoints = 0;
  final _fs = FirestoreService.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _taglineController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Ensure profile exists first
    await _fs.ensureUserProfile();
    final data = await _fs.getUserProfile();
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _nameController.text = data?['name'] ?? user?.displayName ?? 'Your Name';
      _taglineController.text = data?['tagline'] ?? 'Helping neighbours, one step at a time';
      _meritPoints = (data?['meritPoints'] as int?) ?? 0;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    if (_editing) {
      await _fs.updateUserProfile(
        name: _nameController.text.trim(),
        tagline: _taglineController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated ✓'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    setState(() => _editing = !_editing);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phone = user?.phoneNumber ?? 'Not set';
    final badge = MeritService.getBadge(_meritPoints);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.check : Icons.edit_outlined, size: 22),
            tooltip: _editing ? 'Save' : 'Edit',
            onPressed: _toggleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.history, size: 22),
            tooltip: 'History',
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Avatar ──
            Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                  child: Text(
                    _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
                ),
                if (_editing)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.teal, shape: BoxShape.circle, border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _editing
                ? TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.navyDark),
                    decoration: InputDecoration(hintText: 'Your name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    onChanged: (_) => setState(() {}),
                  )
                : Text(_nameController.text, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.navyDark)),
            const SizedBox(height: 8),
            _editing
                ? TextField(
                    controller: _taglineController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textSecondary),
                    decoration: InputDecoration(hintText: 'Your tagline', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  )
                : Text(_taglineController.text, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(phone, style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textSecondary)),
            const SizedBox(height: 32),

            // ── Merit Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.navy, AppColors.navy.withValues(alpha: 0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(MeritService.getBadgeEmoji(badge), style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(badge, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('$_meritPoints merit points', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                    ]),
                  ]),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: MeritService.getProgress(_meritPoints),
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Next: ${MeritService.getNextBadge(_meritPoints)} (${MeritService.getNextBadgeThreshold(_meritPoints)} pts)',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/merit'),
                icon: const Icon(Icons.emoji_events_outlined),
                label: const Text('View Leaderboard & Badges'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.navy), foregroundColor: AppColors.navy),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.error),
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
