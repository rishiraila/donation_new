import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      color: const Color(0xFFFDF4F4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: sections
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('About Us', ['About Give', 'Blog', 'Careers', 'Contact us']),
                    _buildSection('Fundraiser Support', ['FAQs', 'Reach out']),
                    _buildSection('Start a Fundraiser for', ['NGO']),
                    _buildSection('Donate to', ['Social Causes', 'NGOs']),
                    const Spacer(),
                    _buildCurrencyAndSocial(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('About Us', ['About Give', 'Blog', 'Careers', 'Contact us']),
                    const SizedBox(height: 16),
                    _buildSection('Fundraiser Support', ['FAQs', 'Reach out']),
                    const SizedBox(height: 16),
                    _buildSection('Start a Fundraiser for', ['NGO']),
                    const SizedBox(height: 16),
                    _buildSection('Donate to', ['Social Causes', 'NGOs']),
                    const SizedBox(height: 24),
                    _buildCurrencyAndSocial(),
                  ],
                ),
          const SizedBox(height: 32),
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Disclaimer\nUse of children’s information including images, videos, testimonials, etc. in the Campaign is necessary for creating awareness about the charitable cause in order to bring traction to the said charitable cause and obtain donations which can then be used for charitable activities. Information is used and processed with valid consent. This statement is issued in compliance with the Consumer Protection Act, 2019, as amended from time to time.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(item,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyAndSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Currency selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('INR(₹)', style: TextStyle(fontWeight: FontWeight.w600)),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Social media icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(FontAwesomeIcons.facebookF, size: 18),
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.twitter, size: 18),
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.instagram, size: 18),
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.linkedinIn, size: 18),
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.youtube, size: 18),
          ],
        ),
      ],
    );
  }
}
