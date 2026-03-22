import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/request_card.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  final _fs = FirestoreService.instance;

  void _confirmCompletion(RequestModel request) async {
    try {
      await _fs.confirmCompletion(request.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completion confirmed! Points awarded.', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.teal),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _deleteRequest(String requestId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this open request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _fs.deleteRequest(requestId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _editRequest(RequestModel request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditRequestSheet(request: request),
    );
  }

  Widget _buildActionButtons(RequestModel request) {
    if (request.status == 'OPEN') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => _editRequest(request),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
            style: TextButton.styleFrom(iconColor: AppColors.navy, foregroundColor: AppColors.navy),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _deleteRequest(request.id),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
            style: TextButton.styleFrom(iconColor: AppColors.error, foregroundColor: AppColors.error),
          ),
        ],
      );
    } else if (request.status == 'CLAIMED') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.handshake_rounded, color: AppColors.navy, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Claimed by ${request.claimedByName}. Wait for them to help you.', style: const TextStyle(fontSize: 13, color: AppColors.navy)),
            ),
          ],
        ),
      );
    } else if (request.status == 'PENDING_CONFIRMATION') {
      if (request.requesterConfirmed) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_empty, color: AppColors.teal, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text('Waiting for helper to confirm...', style: TextStyle(fontSize: 13, color: AppColors.teal)),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _confirmCompletion(request),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirm Completion'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<RequestModel>>(
          stream: _fs.streamMyActiveRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
            }
            final requests = snapshot.data ?? [];
            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.speaker_notes_off_outlined, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    const Text('No active requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.navy)),
                    const SizedBox(height: 4),
                    const Text('Your ongoing requests will appear here.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      RequestCard(request: req),
                      const SizedBox(height: 8),
                      _buildActionButtons(req),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EditRequestSheet extends StatefulWidget {
  final RequestModel request;
  const _EditRequestSheet({required this.request});

  @override
  State<_EditRequestSheet> createState() => _EditRequestSheetState();
}

class _EditRequestSheetState extends State<_EditRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _category;
  late String _urgency;
  bool _isLoading = false;

  final List<String> _categories = ['Food', 'Medical', 'General', 'Emergency'];
  final List<String> _urgencies = ['Normal', 'Urgent', 'Critical'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.request.title);
    _descController = TextEditingController(text: widget.request.description);
    _category = _categories.contains(widget.request.category) ? widget.request.category : 'General';
    _urgency = _urgencies.contains(widget.request.urgency) ? widget.request.urgency : 'Normal';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirestoreService.instance.editRequest(
        requestId: widget.request.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        urgency: _urgency,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)))).toList(),
          onChanged: (val) { if (val != null) onChanged(val); },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(28, 24, 28, 24 + bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navyDark)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe your need' : null,
              decoration: const InputDecoration(hintText: 'Description', alignLabelWithHint: true),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown(_category, _categories, (val) => setState(() => _category = val))),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown(_urgency, _urgencies, (val) => setState(() => _urgency = val))),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)) : const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
