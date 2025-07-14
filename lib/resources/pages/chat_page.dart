import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ChatPage extends NyStatefulWidget {
  static RouteView path = ("/chat", (_) => ChatPage());

  ChatPage({super.key}) : super(child: () => _ChatPageState());
}

class _ChatPageState extends NyPage<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];

  @override
  get init => () {
        // Initialize with sample messages
        messages = [
          ChatMessage(
            text: "Kevin what songs are hot now?",
            isMe: false,
            timestamp: "12:34",
          ),
          ChatMessage(
            text: "You know I dont like music man.",
            isMe: true,
            timestamp: "12:35",
          ),
          ChatMessage(
            text:
                "I'd rather listen to a podcast, watch football, watch a movie, play football, or listen to  podcasts...",
            isMe: true,
            timestamp: "12:37",
          ),
          ChatMessage(
            text: "Check this playlist out bro.",
            isMe: false,
            timestamp: "12:38",
          ),
          ChatMessage(
            text:
                "Alright Fam, I'll go watch Anime now.... Madara is whooping some real Hokage butt right now 😂😂",
            isMe: true,
            timestamp: "12:52",
          ),
          ChatMessage(
            text:
                "I knew  you'll love it for sure, I've got to go study now Kevin. I will hit you up later about the party..TTYL 🤙",
            isMe: false,
            timestamp: "12:50",
          ),
          ChatMessage(
            text:
                "Alright Fam, I'll go watch Anime now.... Madara is whooping some real Hokage butt right now 😂😂",
            isMe: true,
            timestamp: "12:52",
          ),
        ];
      };

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(ChatMessage(
          text: _messageController.text.trim(),
          isMe: true,
          timestamp: _getCurrentTime(),
        ));
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMe ? Colors.black87 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              message.timestamp,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.grey.shade600),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Support Chat",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Online",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(messages[index]);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String timestamp;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}
