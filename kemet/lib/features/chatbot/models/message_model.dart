import 'package:flutter/foundation.dart';

enum MessageType {
  text,
  image,
}

@immutable
class MessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final bool isTyping;
  final bool isError;
  final MessageType type;
  final String? localFilePath;

  const MessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.isTyping = false,
    this.isError = false,
    this.type = MessageType.text,
    this.localFilePath,
  });
}


