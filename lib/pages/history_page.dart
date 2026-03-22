import "package:flutter/material.dart";
import '../models/request_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filter = 'All'; // All, Completed, Not Completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Filter row ──
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['All', 'Completed', 'Not Completed'].map((f) {
                final isActive = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: isActive,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.teal.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.teal,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.teal : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isActive ? AppColors.teal : AppColors.border, width: 1.5),
                    ),
                    backgroundColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          // ── List (StreamBuilder) ──
          Expanded(
            child: StreamBuilder<List<RequestModel>>(
              stream: FirestoreService.instance.streamMyHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allHistory = snapshot.data ?? [];
                final filtered = allHistory.where((r) {
                  if (_filter == 'Completed') return r.status == 'COMPLETED';
                  if (_filter == 'Not Completed') return r.status != 'COMPLETED';
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.history, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const Text('No history yet', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      const Text('Claim and complete requests to build\nyour history.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ]),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildHistoryCard(filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(RequestModel item) {
    final isCompleted = item.status == 'COMPLETED';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isCompleted ? AppColors.teal.withValues(alpha: 0.3) : AppColors.border, width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.teal.withValues(alpha: 0.12) : AppColors.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isCompleted ? Icons.check_circle : Icons.hourglass_top, color: isCompleted ? AppColors.teal : AppColors.navy, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(4)),
                  child: Text(item.category, style: const TextStyle(fontSize: 10, color: AppColors.navy, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text(_formatDate(item.claimedAt ?? item.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: isCompleted ? AppColors.teal : const Color(0xFFDD6B20), borderRadius: BorderRadius.circular(6)),
            child: Text(isCompleted ? 'Done' : 'Active', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}
