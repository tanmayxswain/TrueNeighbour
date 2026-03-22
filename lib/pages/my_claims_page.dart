import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';
import '../widgets/request_card.dart';
import '../theme/app_theme.dart';

class MyClaimsPage extends StatefulWidget {
  const MyClaimsPage({super.key});

  @override
  State<MyClaimsPage> createState() => _MyClaimsPageState();
}

class _MyClaimsPageState extends State<MyClaimsPage> {
  final _fs = FirestoreService.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _markHelpDone(String requestId) async {
    await _fs.markHelpDone(requestId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Marked as done! Waiting for requester to confirm.'),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _confirmCompletion(String requestId) async {
    await _fs.confirmCompletion(requestId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Confirmed! ✅'),
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
        title: const Text('My Claims'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: _fs.streamMyClaims(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final claims = snapshot.data ?? [];
          if (claims.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.volunteer_activism, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text('No active claims', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
                const SizedBox(height: 8),
                const Text('Claim a request from the home feed\nto start helping.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final claim = claims[index];
              return Column(
                children: [
                  RequestCard(request: claim),
                  _buildActionButtons(claim),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(RequestModel claim) {
    if (claim.status == 'CLAIMED') {
      // Helper hasn't marked done yet
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _markHelpDone(claim.id),
            icon: const Icon(Icons.handshake_outlined),
            label: const Text('HELP DONE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }

    if (claim.status == 'PENDING_CONFIRMATION') {
      // Both sides need to confirm
      final isHelper = claim.claimedBy == _uid;
      final myConfirmed = isHelper ? claim.helperConfirmed : claim.requesterConfirmed;
      final otherConfirmed = isHelper ? claim.requesterConfirmed : claim.helperConfirmed;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Text('Confirmation Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _confirmBadge('You', myConfirmed)),
                const SizedBox(width: 8),
                Expanded(child: _confirmBadge(isHelper ? 'Requester' : 'Helper', otherConfirmed)),
              ],
            ),
            if (!myConfirmed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmCompletion(claim.id),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('CONFIRM SUCCESS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
            if (myConfirmed && !otherConfirmed)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Waiting for the other party…', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _confirmBadge(String label, bool confirmed) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: confirmed ? AppColors.teal.withValues(alpha: 0.12) : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: confirmed ? AppColors.teal : AppColors.border),
      ),
      child: Column(
        children: [
          Icon(confirmed ? Icons.check_circle : Icons.hourglass_empty, size: 22, color: confirmed ? AppColors.teal : AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: confirmed ? AppColors.teal : AppColors.textSecondary)),
          Text(confirmed ? 'Confirmed' : 'Pending', style: TextStyle(fontSize: 10, color: confirmed ? AppColors.teal : AppColors.textSecondary)),
        ],
      ),
    );
  }
}
