import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class PostNeedPage extends StatefulWidget {
  const PostNeedPage({super.key});

  @override
  State<PostNeedPage> createState() => _PostNeedPageState();
}

class _PostNeedPageState extends State<PostNeedPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Food';
  String _selectedUrgency = 'Normal';
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _categories = ['Food', 'Medical', 'General', 'Emergency'];
  final List<String> _urgencies = ['Normal', 'Urgent', 'Critical'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _broadcast() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirestoreService.instance.createRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        urgency: _selectedUrgency,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your need has been broadcasted! 🎉'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueNeighbour'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Post a Need', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.navyDark)),
                  const SizedBox(height: 6),
                  const Text('Let your neighbours know how they can help.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 32),

                  const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                    decoration: const InputDecoration(hintText: 'What do you need help with?'),
                  ),
                  const SizedBox(height: 24),

                  const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe your need' : null,
                    decoration: const InputDecoration(hintText: 'Describe the situation', alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 24),

                  const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
                  const SizedBox(height: 8),
                  _buildDropdown(_selectedCategory, _categories, (val) => setState(() => _selectedCategory = val)),
                  const SizedBox(height: 24),

                  const Text('Urgency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
                  const SizedBox(height: 8),
                  _buildDropdown(_selectedUrgency, _urgencies, (val) => setState(() => _selectedUrgency = val)),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _broadcast,
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('BROADCAST'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}
