import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LegalPage extends NyStatefulWidget {
  static RouteView path = ("/legal", (_) => LegalPage());

  LegalPage({super.key}) : super(child: () => _LegalPageState());
}

class _LegalPageState extends NyPage<LegalPage> {
  @override
  get init => () {};

  Widget _buildLegalOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black87,
              size: 24,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _openPrivacyPolicy() {
    _showLegalDocument(
      title: "Privacy Policy",
      content: _getPrivacyPolicyContent(),
    );
  }

  void _openTermsAndConditions() {
    _showLegalDocument(
      title: "Terms and Conditions",
      content: _getTermsAndConditionsContent(),
    );
  }

  void _showLegalDocument({required String title, required String content}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LegalDocumentPage(
          title: title,
          content: content,
        ),
      ),
    );
  }

  String _getPrivacyPolicyContent() {
    return """
1. INFORMATION WE COLLECT

We collect information you provide directly to us, such as when you create an account, make a booking, or contact us for support.

Personal Information:
• Name and contact information
• Payment information
• Booking preferences and history
• Communication preferences

Automatically Collected Information:
• Device information and identifiers
• Usage data and analytics
• Location information (with permission)
• Cookies and similar technologies

2. HOW WE USE YOUR INFORMATION

We use the information we collect to:
• Provide and maintain our services
• Process bookings and payments
• Send you updates and promotional materials
• Improve our services and user experience
• Comply with legal obligations

3. INFORMATION SHARING

We do not sell your personal information. We may share your information in the following circumstances:
• With service providers who assist us in operating our business
• When required by law or to protect our rights
• In connection with a business transaction
• With your consent

4. DATA SECURITY

We implement appropriate security measures to protect your information against unauthorized access, alteration, disclosure, or destruction.

5. YOUR RIGHTS

You have the right to:
• Access and update your information
• Delete your account and data
• Opt out of marketing communications
• Request data portability

6. CONTACT US

If you have questions about this Privacy Policy, please contact us at privacy@company.com.

Last updated: January 2025
""";
  }

  String _getTermsAndConditionsContent() {
    return """
1. ACCEPTANCE OF TERMS

By accessing and using our services, you accept and agree to be bound by the terms and provision of this agreement.

2. BOOKING AND PAYMENT

Deposit Requirements:
• A 60% deposit is required to secure your booking
• Deposits are non-refundable
• Remaining balance is due upon service completion

Cancellation Policy:
• Cancellations must be made 24 hours in advance
• No-shows will forfeit the full deposit
• Refunds are processed within 5-7 business days

3. SERVICE AVAILABILITY

• Services are subject to availability
• We reserve the right to reschedule appointments with 24-hour notice
• Weather conditions may affect service delivery

4. USER RESPONSIBILITIES

You agree to:
• Provide accurate information
• Arrive on time for appointments
• Follow health and safety guidelines
• Treat our staff with respect

5. LIMITATION OF LIABILITY

Our liability is limited to the amount paid for services. We are not responsible for indirect or consequential damages.

6. INTELLECTUAL PROPERTY

All content on our platform is protected by copyright and other intellectual property laws.

7. MODIFICATIONS

We reserve the right to modify these terms at any time. Changes will be effective immediately upon posting.

8. GOVERNING LAW

These terms are governed by the laws of the jurisdiction in which our services are provided.

9. CONTACT INFORMATION

For questions about these terms, contact us at legal@company.com.

Last updated: January 2025
""";
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Legal",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildLegalOption(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: _openPrivacyPolicy,
            ),
            _buildLegalOption(
              icon: Icons.description_outlined,
              title: "Terms and Conditions",
              onTap: _openTermsAndConditions,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalDocumentPage extends StatelessWidget {
  final String title;
  final String content;

  const _LegalDocumentPage({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
