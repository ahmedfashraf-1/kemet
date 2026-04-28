import 'package:flutter/foundation.dart';

@immutable
class ChatbotImageResponse {
  final String imageAnalysis;
  final String response;

  const ChatbotImageResponse({
    required this.imageAnalysis,
    required this.response,
  });

  factory ChatbotImageResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawAnalysis = json['image_analysis'];
    final dynamic rawResponse = json['response'];

    return ChatbotImageResponse(
      imageAnalysis: (rawAnalysis?.toString() ?? '').trim(),
      response: (rawResponse?.toString() ?? '').trim(),
    );
  }
}
