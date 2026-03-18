import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../theme/app_theme.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onClaim;

  const RequestCard({
    super.key,
    required this.request,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.navy.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.textSecondary, size: 28),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: request.status == 'OPEN' ? AppColors.teal : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Status Tag:\n${request.status}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Claim Button
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: onClaim,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'CLAIM\nBUTTON',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Extra meta row for category and urgency
                Row(
                  children: [
                    Expanded(child: _buildMetaChip(request.category, Icons.category, AppColors.navy)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMetaChip(request.urgency, Icons.priority_high, _getUrgencyColor(request.urgency))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgent':
      case 'critical':
        return AppColors.error;
      case 'normal':
      case 'general':
      default:
        return AppColors.teal;
    }
  }
}
