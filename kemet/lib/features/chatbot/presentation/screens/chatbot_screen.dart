import 'package:flutter/material.dart';
import 'package:kemet/features/chatbot/presentation/widgets/chatbot_backdrop.dart';
import 'package:kemet/features/chatbot/presentation/widgets/chatbot_overlay_panel.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChatbotBackdrop(
        onDismiss: () => Navigator.of(context).maybePop(),
        child: ChatbotOverlayPanel(
          onClose: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

