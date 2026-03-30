import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/request_model.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../services/merit_service.dart';

class RequestCard extends StatefulWidget {
  final RequestModel request;
  final VoidCallback? onClaim;

  const RequestCard({
    super.key,
    required this.request,
    this.onClaim,
  });

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  int _meritPoints = 0;
  int _reportCount = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profile = await FirestoreService.instance.getUserProfile(widget.request.requesterId);
    if (!mounted) return;
    setState(() {
      _meritPoints = (profile?['meritPoints'] as int?) ?? 0;
      _reportCount = (profile?['reportCount'] as int?) ?? 0;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Requester profile row ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.navy.withValues(alpha: 0.12),
                  backgroundImage: (request.requesterAvatarUrl != null && request.requesterAvatarUrl!.isNotEmpty)
                      ? NetworkImage(request.requesterAvatarUrl!)
                      : null,
                  child: (request.requesterAvatarUrl == null || request.requesterAvatarUrl!.isEmpty)
                      ? Text(
                          request.requesterName.isNotEmpty
                              ? request.requesterName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              request.requesterName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_loaded) ...[
                            const SizedBox(width: 6),
                            _buildMeritBadge(),
                            if (_reportCount >= 3) ...[
                              const SizedBox(width: 4),
                              _buildDangerBadge(),
                            ],
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _timeAgo(request.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildUrgencyBadge(request.urgency),
                if (FirebaseAuth.instance.currentUser?.uid != request.requesterId)
                  _buildReportMenu(context),
              ],
            ),
          ),
          // ── Body ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                // ── Category chip + Status + Claim button ──
                Row(
                  children: [
                    _buildCategoryChip(request.category),
                    const SizedBox(width: 8),
                    _buildStatusTag(request.status),
                    const Spacer(),
                    if (widget.onClaim != null && request.status == 'OPEN')
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: widget.onClaim,
                          icon: const Icon(Icons.volunteer_activism, size: 16),
                          label: const Text('Claim'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeritBadge() {
    final badge = MeritService.getBadge(_meritPoints);
    final emoji = MeritService.getBadgeEmoji(badge);
    return Tooltip(
      message: '$badge · $_meritPoints pts',
      child: Text(emoji, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildDangerBadge() {
    return Tooltip(
      message: 'This user has been reported multiple times',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.error),
            SizedBox(width: 3),
            Text(
              'Caution',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildUrgencyBadge(String urgency) {
    final isUrgent = urgency.toLowerCase() == 'urgent' || urgency.toLowerCase() == 'critical';
    final color = isUrgent ? AppColors.error : AppColors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.warning_amber_rounded : Icons.schedule,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            urgency,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getCategoryIcon(category), size: 13, color: AppColors.navy),
          const SizedBox(width: 4),
          Text(
            category,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'OPEN':
        color = AppColors.teal;
        icon = Icons.fiber_manual_record;
        break;
      case 'CLAIMED':
        color = const Color(0xFFDD6B20);
        icon = Icons.pending_actions;
        break;
      case 'COMPLETED':
        color = AppColors.navy;
        icon = Icons.check_circle_outline;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.info_outline;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'medical':
        return Icons.local_hospital;
      case 'food':
        return Icons.restaurant;
      case 'emergency':
        return Icons.emergency;
      default:
        return Icons.category;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildReportMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      tooltip: 'More options',
      onSelected: (value) {
        if (value == 'report') {
          _showReportDialog(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text('Report User', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    String selectedReason = 'Inappropriate Content';
    final TextEditingController otherReasonController = TextEditingController();
    final reasons = [
      'Inappropriate Content',
      'Spam or Scam',
      'Harassment',
      'Fake Account',
      'Other',
    ];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Report User',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Report User', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please select a reason for reporting this user. False reports may result in account suspension.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedReason = val);
                      },
                    ),
                    if (selectedReason == 'Other') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: otherReasonController,
                        decoration: InputDecoration(
                          hintText: 'Please specify the reason...',
                          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String finalReason = selectedReason;
                    if (selectedReason == 'Other') {
                      if (otherReasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please specify a reason.'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      finalReason = 'Other: ${otherReasonController.text.trim()}';
                    }
                    Navigator.pop(ctx);
                    await _submitReport(context, finalReason);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _submitReport(BuildContext context, String reason) async {
    try {
      await FirestoreService.instance.reportUser(
        reportedUserId: widget.request.requesterId,
        reason: reason,
        requestId: widget.request.id,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report submitted successfully. We will review it shortly.'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
