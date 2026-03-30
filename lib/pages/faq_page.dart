import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: "What is TrueNeighbour?",
            answer: "TrueNeighbour is a community-driven app that helps connect people in local neighborhoods who need help with those who are willing to assist.",
          ),
          _buildFAQItem(
            question: "How do I claim a request?",
            answer: "Simply tap the 'Claim' button on an open request from the home feed. Note that you can only have one active claim at a time, and you cannot claim your own request.",
          ),
          _buildFAQItem(
            question: "Is the app free to use?",
            answer: "Yes! TrueNeighbour is completely free for all community members.",
          ),
          _buildFAQItem(
            question: "How is my data protected?",
            answer: "We use industry-standard encryption and do not sell your personal data. Only verified users in your local area can see your public requests.",
          ),
          _buildFAQItem(
            question: "Who can see my phone number?",
            answer: "Your phone number is only used for authentication and account verification. It is not publicly visible on your profile.",
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
