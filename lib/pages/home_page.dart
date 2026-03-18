import 'package:flutter/material.dart';
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
  // Mock Data
  final List<RequestModel> allRequests = [
    RequestModel(
      id: '1',
      title: 'Need help with groceries',
      description: 'I am unable to go out due to a broken leg. Need someone to pick up some essentials.',
      category: 'Food',
      urgency: 'Normal',
      status: 'OPEN',
      requesterName: 'Alice',
    ),
    RequestModel(
      id: '2',
      title: 'Emergency Medical Supplies',
      description: 'Require immediate help picking up prescribed medicine from the pharmacy.',
      category: 'Medical',
      urgency: 'Urgent',
      status: 'OPEN',
      requesterName: 'Bob',
    ),
    RequestModel(
      id: '3',
      title: 'Help moving a couch',
      description: 'Need one person to help me move a couch to the second floor.',
      category: 'General',
      urgency: 'Normal',
      status: 'OPEN',
      requesterName: 'Charlie',
    ),
  ];

  String selectedCategory = 'All';
  String selectedUrgency = 'All';

  final List<String> categories = ['All', 'Medical', 'Food', 'General', 'Emergency'];
  final List<String> urgencies = ['All', 'Normal', 'Urgent', 'Critical'];

  @override
  Widget build(BuildContext context) {
    // Filter requests
    final filteredRequests = allRequests.where((req) {
      final matchCategory = selectedCategory == 'All' || req.category == selectedCategory;
      final matchUrgency = selectedUrgency == 'All' || req.urgency == selectedUrgency;
      return matchCategory && matchUrgency;
    }).toList();

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
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Category Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.background,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            items: categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedCategory = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Urgency Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.background,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUrgency,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            items: urgencies.map((urg) {
                              return DropdownMenuItem(
                                value: urg,
                                child: Text(urg, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedUrgency = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          Container(height: 1, color: AppColors.border),
          // Feed
          Expanded(
            child: filteredRequests.isEmpty
                ? const Center(
                    child: Text(
                      'No requests match the current filters.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return RequestCard(
                        request: request,
                        onClaim: () {
                          // Claim action to be implemented
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Claiming ${request.title}...')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.teal.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to Post a Need page later
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post a Need coming soon!')),
            );
          },
          backgroundColor: AppColors.teal,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),
    );
  }
}
