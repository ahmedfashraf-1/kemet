import 'package:flutter/foundation.dart';

@immutable
class ChatbotApiResponse {
  final String response;
  final List<ChatbotHistoryEntry> history;

  const ChatbotApiResponse({
    required this.response,
    required this.history,
  });

  factory ChatbotApiResponse.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];
    final history = rawHistory is List
        ? rawHistory
            .whereType<Map>()
            .map(
              (item) => ChatbotHistoryEntry.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <ChatbotHistoryEntry>[];

    return ChatbotApiResponse(
      response: (json['response'] as String?)?.trim() ?? '',
      history: history,
    );
  }
}

@immutable
class ChatbotHistoryEntry {
  final String role;
  final String content;

  const ChatbotHistoryEntry({
    required this.role,
    required this.content,
  });

  factory ChatbotHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ChatbotHistoryEntry(
      role: (json['role'] as String?)?.trim() ?? '',
      content: (json['content'] as String?)?.trim() ?? '',
    );
  }
}

