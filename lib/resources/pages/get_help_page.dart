import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class GetHelpPage extends NyStatefulWidget {
  static RouteView path = ("/get-help", (_) => GetHelpPage());

  GetHelpPage({super.key}) : super(child: () => _GetHelpPageState());
}

class _GetHelpPageState extends NyPage<GetHelpPage> {
  @override
  get init => () {};

  Widget _buildHelpOption({
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

  void _openChat() {
    // Navigate to chat page
    routeTo('/chat');
  }

  void _openEmail() {
    // Open email client or navigate to email page
  }

  void _openTwitter() {
    // Open Twitter/X app or web
  }

  void _openInstagram() {
    // Open Instagram app or web
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
          "Get Help",
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
            _buildHelpOption(
              icon: Icons.chat_bubble_outline,
              title: "Chat",
              onTap: _openChat,
            ),
            _buildHelpOption(
              icon: Icons.email_outlined,
              title: "Email",
              onTap: _openEmail,
            ),
            _buildHelpOption(
              icon: Icons.close, // X icon for Twitter/X
              title: "X (Twitter)",
              onTap: _openTwitter,
            ),
            _buildHelpOption(
              icon: Icons.camera_alt_outlined,
              title: "Instagram",
              onTap: _openInstagram,
            ),
          ],
        ),
      ),
    );
  }
}
