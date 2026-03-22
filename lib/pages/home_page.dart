import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/request_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/request_card.dart';
import '../theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  String selectedUrgency = 'All';
  final _fs = FirestoreService.instance;

  final List<String> categories = ['All', 'Medical', 'Food', 'General', 'Emergency'];
  final List<String> urgencies = ['All', 'Normal', 'Urgent', 'Critical'];

  @override
  void initState() {
    super.initState();
    // Ensure user profile exists in Firestore
    _fs.ensureUserProfile();
  }

  Future<void> _claimRequest(RequestModel request) async {
    final hasActive = await _fs.hasActiveClaim();
    if (!mounted) return;
    if (hasActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You already have an active claim. Complete it first!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    // Prevent claiming your own request
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (request.requesterId == uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You cannot claim your own request.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    await _fs.claimRequest(request.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claimed "${request.title}" ✅'),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueNeighbour'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── Filter Bar ──
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.background,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
                        items: categories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(children: [
                            Icon(cat == 'All' ? Icons.apps : _getCatIcon(cat), size: 16, color: AppColors.navy),
                            const SizedBox(width: 8),
                            Text(cat, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          ]),
                        )).toList(),
                        selectedItemBuilder: (context) => categories.map((cat) => Row(children: [
                          const Icon(Icons.folder_outlined, size: 16, color: AppColors.navy),
                          const SizedBox(width: 6),
                          Text(cat == 'All' ? 'Category' : cat, style: TextStyle(
                            fontSize: 13,
                            color: cat == 'All' ? AppColors.textSecondary : AppColors.textPrimary,
                            fontWeight: cat == 'All' ? FontWeight.w400 : FontWeight.w600,
                          )),
                        ])).toList(),
                        onChanged: (val) { if (val != null) setState(() => selectedCategory = val); },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.background,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUrgency,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
                        items: urgencies.map((urg) => DropdownMenuItem(
                          value: urg,
                          child: Row(children: [
                            Icon(urg == 'All' ? Icons.apps : (urg == 'Normal' ? Icons.schedule : Icons.warning_amber_rounded),
                              size: 16, color: urg == 'Normal' || urg == 'All' ? AppColors.teal : AppColors.error),
                            const SizedBox(width: 8),
                            Text(urg, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          ]),
                        )).toList(),
                        selectedItemBuilder: (context) => urgencies.map((urg) => Row(children: [
                          const Icon(Icons.bolt, size: 16, color: AppColors.navy),
                          const SizedBox(width: 6),
                          Text(urg == 'All' ? 'Urgency' : urg, style: TextStyle(
                            fontSize: 13,
                            color: urg == 'All' ? AppColors.textSecondary : AppColors.textPrimary,
                            fontWeight: urg == 'All' ? FontWeight.w400 : FontWeight.w600,
                          )),
                        ])).toList(),
                        onChanged: (val) { if (val != null) setState(() => selectedUrgency = val); },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Feed (StreamBuilder) ──
          Expanded(
            child: StreamBuilder<List<RequestModel>>(
              stream: _fs.streamOpenRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
                }
                final allRequests = snapshot.data ?? [];
                final filtered = allRequests.where((req) {
                  final matchCat = selectedCategory == 'All' || req.category == selectedCategory;
                  final matchUrg = selectedUrgency == 'All' || req.urgency == selectedUrgency;
                  return matchCat && matchUrg;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.inbox_rounded, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      const Text('No requests found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      const SizedBox(height: 6),
                      const Text('Be the first to post a need!', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ]),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final request = filtered[index];
                    return RequestCard(
                      request: request,
                      onClaim: request.status == 'OPEN' ? () => _claimRequest(request) : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 64, width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.teal.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/post-need'),
          backgroundColor: AppColors.teal,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  IconData _getCatIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'medical': return Icons.local_hospital;
      case 'food': return Icons.restaurant;
      case 'emergency': return Icons.emergency;
      default: return Icons.category;
    }
  }
}
