import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class FaqsPage extends NyStatefulWidget {
  static RouteView path = ("/faqs", (_) => FaqsPage());

  FaqsPage({super.key}) : super(child: () => _FAQsPageState());
}

class _FAQsPageState extends NyPage<FaqsPage> {
  List<FAQ> faqs = [];

  @override
  get init => () {
        faqs = [
          FAQ(
            question: "How many percent do I deposit?",
            answer:
                "To secure your booking or transaction, a deposit of 50% is required. This deposit is non-refundable, meaning that once it is paid, it cannot be returned. This policy helps us ensure that your reservation is confirmed and that we can allocate the necessary resources for your service.\n\nAfter the services are rendered, you will be expected to pay the remaining 50% to complete the transaction. This balance is due upon completion of the service or at the time specified in your agreement. We appreciate your understanding and cooperation in this matter, as it allows us to provide you with the best possible experience.",
          ),
          FAQ(
            question: "Is my deposit refundable if i don't show?",
            answer:
                "No, deposits are non-refundable if you don't show up for your appointment. This policy helps us ensure that your reservation is confirmed and that we can allocate the necessary resources for your service.",
          ),
          FAQ(
            question: "Are UK and UAE prices the same?",
            answer:
                "No, prices may vary between UK and UAE locations due to different operating costs, local market conditions, and currency differences. Please check the specific pricing for your selected location.",
          ),
          FAQ(
            question: "How many days in advance can I book?",
            answer:
                "You can book our services up to 30 days in advance. We recommend booking at least 3-5 days ahead to ensure availability for your preferred date and time.",
          ),
          FAQ(
            question: "Can I lock my hair",
            answer:
                "Yes, we offer hair locking services. Our experienced stylists can help you achieve and maintain healthy locs. Please specify this service when booking your appointment.",
          ),
        ];
      };

  void _showFAQDetails(FAQ faq) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFAQDetailsBottomSheet(faq),
    );
  }

  Widget _buildFAQDetailsBottomSheet(FAQ faq) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "FAQs",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faq.question,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    faq.answer,
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
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return InkWell(
      onTap: () => _showFAQDetails(faq),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_outline,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                faq.question,
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
          "FAQs",
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
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return _buildFAQItem(faqs[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}
