import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kemet/features/chatbot/models/chatbot_api_response.dart';
import 'package:kemet/features/chatbot/models/chatbot_media_response.dart';

class ChatbotApiException implements Exception {
  final String message;

  const ChatbotApiException(this.message);

  @override
  String toString() => 'ChatbotApiException: $message';
}

class ChatbotApiService {
  static const String _baseUrl = 'https://a7med8ashraf-kemet-bot.hf.space';
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;
  final bool _ownsClient;

  ChatbotApiService({http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  /// Get the current user ID from SharedPreferences
  Future<String> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      if (userId == null || userId.isEmpty) {
        throw const ChatbotApiException(
          'User not authenticated. Please sign in first.',
        );
      }
      return userId;
    } catch (e) {
      throw const ChatbotApiException(
        'Failed to retrieve user ID. Please sign in again.',
      );
    }
  }

  Future<ChatbotApiResponse> sendMessage({
    required String userId,
    required String message,
  }) async {
    final uri = Uri.parse('$_baseUrl/chat');

    try {
      final response = await _client
          .post(
            uri,
            headers: const <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'user_id': userId,
              'message': message,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ChatbotApiException(
          _extractErrorMessage(
            statusCode: response.statusCode,
            body: response.body,
            headers: response.headers,
          ),
        );
      }

      final Map<String, dynamic>? decoded = _tryDecodeMap(response.body);
      if (decoded == null) {
        throw const ChatbotApiException('Received non-JSON response from server.');
      }

      return ChatbotApiResponse.fromJson(decoded);
    } on TimeoutException {
      throw const ChatbotApiException(
        'The request timed out. Please try again in a moment.',
      );
    } on http.ClientException {
      throw const ChatbotApiException(
        'Unable to reach the chatbot server. Please try again.',
      );
    } on SocketException {
      throw const ChatbotApiException(
        'No internet connection. Please check your network and retry.',
      );
    } on ChatbotApiException {
      rethrow;
    } catch (_) {
      throw const ChatbotApiException(
        'Something went wrong while contacting the chatbot server.',
      );
    }
  }

  Future<ChatbotImageResponse> sendImage({
    required String userId,
    required String imagePath,
  }) async {
    return sendImageMessage(
      File(imagePath),
      userId: userId,
    );
  }

  // Production-ready multipart image upload with safe parsing and debug traces.
  Future<ChatbotImageResponse> sendImageMessage(
    File image, {
    required String userId,
  }) async {
    if (!image.existsSync()) {
      throw const ChatbotApiException('Selected image file was not found.');
    }

    final uri = Uri.parse('$_baseUrl/image');

    try {
      final http.MultipartRequest request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..fields['user_id'] = userId
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final http.StreamedResponse streamedResponse =
          await _client.send(request).timeout(_timeout);
      final http.Response response =
          await http.Response.fromStream(streamedResponse);

      _logImageDebug(response);

      if (response.statusCode != 200) {
        throw ChatbotApiException(
          _extractErrorMessage(
            statusCode: response.statusCode,
            body: response.body,
            headers: response.headers,
          ),
        );
      }

      final Map<String, dynamic>? decoded = _tryDecodeMap(response.body);
      if (decoded == null) {
        throw const ChatbotApiException(
          'Server returned invalid JSON for image upload.',
        );
      }

      final dynamic responseText = decoded['response'];
      if (responseText == null) {
        throw const ChatbotApiException(
          'Server response is missing the "response" field.',
        );
      }

      return ChatbotImageResponse.fromJson(decoded);
    } on TimeoutException {
      throw const ChatbotApiException(
        'Image upload timed out. Please try again.',
      );
    } on http.ClientException {
      throw const ChatbotApiException(
        'Unable to reach the chatbot server. Please try again.',
      );
    } on SocketException {
      throw const ChatbotApiException(
        'No internet connection. Please check your network and retry.',
      );
    } on ChatbotApiException {
      rethrow;
    } catch (_) {
      throw const ChatbotApiException(
        'Something went wrong while uploading the image.',
      );
    }
  }

  void _logImageDebug(http.Response response) {
    if (!kDebugMode) {
      return;
    }

    final String bodyPreview = response.body.length > 1500
        ? '${response.body.substring(0, 1500)}...'
        : response.body;

    debugPrint('[ChatbotApiService] /image statusCode: ${response.statusCode}');
    debugPrint('[ChatbotApiService] /image content-type: ${response.headers['content-type']}');
    debugPrint('[ChatbotApiService] /image body: $bodyPreview');
  }

  Map<String, dynamic>? _tryDecodeMap(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage({
    required int statusCode,
    required String body,
    required Map<String, String> headers,
  }) {
    final Map<String, dynamic>? decoded = _tryDecodeMap(body);
    if (decoded != null) {
      final String? fromDetail = _normalizeErrorField(decoded['detail']);
      if (fromDetail != null) {
        return fromDetail;
      }

      final String? fromMessage = _normalizeErrorField(decoded['message']);
      if (fromMessage != null) {
        return fromMessage;
      }

      final String? fromError = _normalizeErrorField(decoded['error']);
      if (fromError != null) {
        return fromError;
      }
    }

    final String plainText = body.trim();
    if (plainText.isNotEmpty) {
      return 'Server error ($statusCode): $plainText';
    }

    final String? contentType = headers['content-type'];
    if (contentType != null && contentType.isNotEmpty) {
      return 'Server error ($statusCode). Invalid $contentType response.';
    }

    return 'Server error ($statusCode). Please try again later.';
  }

  String? _normalizeErrorField(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final String cleaned = value.trim();
      return cleaned.isEmpty ? null : cleaned;
    }

    if (value is List && value.isNotEmpty) {
      final List<String> items = value
          .map((dynamic item) => _normalizeErrorField(item) ?? '')
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
      if (items.isNotEmpty) {
        return items.join(', ');
      }
    }

    if (value is Map && value.isNotEmpty) {
      final String serialized = value.toString().trim();
      return serialized.isEmpty ? null : serialized;
    }

    final String fallback = value.toString().trim();
    return fallback.isEmpty ? null : fallback;
  }
}
