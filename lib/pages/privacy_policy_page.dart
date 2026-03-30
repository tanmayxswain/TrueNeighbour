import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for TrueNeighbour',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "At TrueNeighbour, we believe that helping your community shouldn't come at the cost of your privacy. This policy outlines how we handle your information and our commitment to local data processing.",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: "1. Information We Collect",
              content: "To connect you with your neighbors, we collect minimal data:\n\n• Account Information: Name and contact details (phone) used for verification.\n\n• Request Data: Details of the help you offer or request (e.g., category, description).",
            ),
            _buildSection(
              title: "2. How Your Data is Shared",
              content: "• Community Feed: When you post a request, it is visible to other verified users in your local area.\n\n• No Third-Party Sales: We do not sell your personal data to advertisers or third parties.\n\n• Safety & Security: We may share information if required by law or to prevent immediate physical harm to a community member.",
            ),
            _buildSection(
              title: "3. Security",
              content: "We implement industry-standard encryption to protect your data during transit and at rest. However, as a community-driven tool, we encourage users to avoid sharing highly sensitive personal identifiers (like home addresses) in public request descriptions.",
            ),
            _buildSection(
              title: "4. Your Rights",
              content: "You have the right to:\n\n• Access, update, or delete your account at any time.",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
