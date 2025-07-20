import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tawk/flutter_tawk.dart';

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

  void _openChat() async {
    // Open Tawk.to chat with user identification
    try {
      // You can get user data here if needed for chat identification
      // final user = await AuthService.getCurrentUser();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                "Chat Support",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Tawk(
              directChatLink:
                  'https://tawk.to/chat/YOUR_TAWK_TO_WIDGET_ID/default',
              placeholder: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF985F5F)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Loading chat...",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onLoad: () {
                print("Welcome to BeautySpa By Shea Support");
              },
              onLinkTap: (url) {
                print("");
                // Handle any link taps if needed
              },
            ),
          ),
        ),
      );
    } catch (e) {
      print("Error opening chat: $e");
      showToast(
        title: "Error",
        description: "Failed to open chat. Please try again.",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  void _openEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@thehairspaclinic.com',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      showToast(
        title: "Error",
        description: "Could not open email app.",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  // void _openTwitter() {
  //   // Open Twitter/X app or web
  // }

  void _openInstagram() async {
    const url =
        'https://www.instagram.com/thehairspaclinic?igsh=em5lOWx0MGE4OW9w';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      showToast(
        title: "Error",
        description: "Could not open Instagram.",
        style: ToastNotificationStyleType.danger,
      );
    }
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
            // _buildHelpOption(
            //   icon: Icons.close, // X icon for Twitter/X
            //   title: "X (Twitter)",
            //   onTap: _openTwitter,
            // ),
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
