import 'package:image_picker/image_picker.dart';

class ChatbotMediaException implements Exception {
  final String message;

  const ChatbotMediaException(this.message);

  @override
  String toString() => 'ChatbotMediaException: $message';
}

class ChatbotMediaService {
  final ImagePicker _picker;

  ChatbotMediaService({
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  Future<String?> pickImagePath({required ImageSource source}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 88,
      );
      return file?.path;
    } catch (_) {
      throw const ChatbotMediaException(
        'Unable to access the selected image.',
      );
    }
  }

  void dispose() {
    // No disposable resources in image-only mode.
  }
}
