import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              'Terms of Service',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Welcome to TrueNeighbour. By using our application, you agree to comply with and be bound by the following terms and conditions of use.",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: "1. Acceptance of Terms",
              content: "By accessing or using the TrueNeighbour app, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you may not use our service.",
            ),
            _buildSection(
              title: "2. User Conduct",
              content: "You agree to use TrueNeighbour strictly for its intended purpose: to connect and support your local community. Harassment, spam, false requests, or illegal activities will result in immediate account termination.",
            ),
            _buildSection(
              title: "3. User Content",
              content: "You are solely responsible for all content (requests, profiles, etc.) that you post. TrueNeighbour reserves the right to remove any content that violates these terms or community guidelines.",
            ),
            _buildSection(
              title: "4. Liability and Safety",
              content: "TrueNeighbour provides a platform for neighbors to connect. We do not verify the background of every user. Always exercise caution, use public meeting spots when exchanging physical items, and prioritize your personal safety when coordinating with someone from the app. TrueNeighbour is not liable for any incidents that occur offline.",
            ),
            _buildSection(
              title: "5. Modifications",
              content: "We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes your acceptance of the new terms.",
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
