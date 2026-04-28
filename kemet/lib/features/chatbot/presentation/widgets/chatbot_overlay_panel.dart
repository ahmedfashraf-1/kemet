import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/features/chatbot/models/chatbot_api_response.dart';
import 'package:kemet/features/chatbot/models/chatbot_media_response.dart';
import 'package:kemet/features/chatbot/models/message_model.dart';
import 'package:kemet/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:kemet/features/chatbot/presentation/widgets/message_input.dart';
import 'package:kemet/features/chatbot/presentation/widgets/quick_suggestions.dart';
import 'package:kemet/features/chatbot/services/chatbot_api_service.dart';
import 'package:kemet/features/chatbot/services/chatbot_media_service.dart';

class ChatbotOverlayPanel extends StatefulWidget {
  final VoidCallback onClose;

  const ChatbotOverlayPanel({super.key, required this.onClose});

  @override
  State<ChatbotOverlayPanel> createState() => _ChatbotOverlayPanelState();
}

class _ChatbotOverlayPanelState extends State<ChatbotOverlayPanel>
    with SingleTickerProviderStateMixin {
  static const List<String> _suggestions = [
    'Giza',
    'Luxor',
    'Abu Simbel',
    'Museum',
    'Karnak',
  ];

  String? _userId; // Will be loaded from SharedPreferences

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotApiService _apiService = ChatbotApiService();
  final ChatbotMediaService _mediaService = ChatbotMediaService();

  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  bool _isSendingText = false;
  bool _isSendingImage = false;

  bool get _isBusy => _isSendingText || _isSendingImage;

  final List<MessageModel> _messages = [
    MessageModel(
      id: 'welcome',
      text: "Marhaba! I'm your personal Egypt tour guide...",
      isUser: false,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    )..forward();

    final curved = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(curved);

    // Load user_id from SharedPreferences
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _introController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _apiService.dispose();
    _mediaService.dispose();
    super.dispose();
  }

  /// Load user_id from SharedPreferences
  /// This should be set during Google Sign-In authentication
  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      debugPrint('🔵 [CHATBOT] loaded user_id from prefs -> ${userId ?? 'null'}');
      if (userId != null && userId.isNotEmpty) {
        setState(() {
          _userId = userId;
        });
      }
    } catch (e) {
      debugPrint('Error loading user_id: $e');
    }
  }

  Future<void> _sendTextMessage([String? value]) async {
    if (_isBusy) {
      return;
    }

    final text = (value ?? _controller.text).trim();
    if (text.isEmpty) {
      return;
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final userMessage = MessageModel(
      id: 'user_$timestamp',
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    final typingId = 'typing_$timestamp';
    final typingMessage = MessageModel(
      id: typingId,
      text: '',
      isUser: false,
      isTyping: true,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messages.add(typingMessage);
      _isSendingText = true;
    });

    _controller.clear();
    FocusScope.of(context).unfocus();
    _scrollToBottom();

    try {
      // Ensure valid user id before sending
      final prefs = await SharedPreferences.getInstance();
      final uid = (_userId != null && _userId!.isNotEmpty)
          ? _userId!
          : (prefs.getString('current_user_id') ?? '');
      debugPrint('🔵 [CHATBOT] Sending text message as user_id=$uid');
      if (uid.isEmpty) {
        if (!mounted) return;
        setState(() {
          _removeTypingMessage(typingId);
          _addBotText('Please sign in to use the chatbot.', isError: true);
        });
        return;
      }

      final response = await _apiService.sendMessage(
        userId: uid,
        message: text,
      );

      if (!mounted) {
        return;
      }

      final replyText = _resolveReplyText(
        responseText: response.response,
        history: response.history,
        fallbackPrompt: text,
      );

      setState(() {
        _removeTypingMessage(typingId);
        _addBotText(replyText);
      });
    } on ChatbotApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _removeTypingMessage(typingId);
        _addBotText(error.message, isError: true);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _removeTypingMessage(typingId);
        _addBotText(
          'Something went wrong while loading the chatbot response.',
          isError: true,
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingText = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _pickImageAndSend() async {
    if (_isBusy) {
      return;
    }

    final ImageSource? source = await _showImageSourcePicker();
    if (source == null || !mounted) {
      return;
    }

    String? typingId;

    try {
      final String? imagePath = await _mediaService.pickImagePath(source: source);
      if (imagePath == null || !mounted) {
        return;
      }

      typingId = _buildTypingId();
      final String currentTypingId = typingId;

      setState(() {
        _isSendingImage = true;
        _messages.add(
          MessageModel(
            id: 'image_${DateTime.now().microsecondsSinceEpoch}',
            text: '',
            isUser: true,
            createdAt: DateTime.now(),
            type: MessageType.image,
            localFilePath: imagePath,
          ),
        );
        _messages.add(
          MessageModel(
            id: currentTypingId,
            text: '',
            isUser: false,
            isTyping: true,
            createdAt: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();

      // Ensure valid user id before sending image
      final prefs = await SharedPreferences.getInstance();
      final uid = (_userId != null && _userId!.isNotEmpty)
          ? _userId!
          : (prefs.getString('current_user_id') ?? '');
      debugPrint('🔵 [CHATBOT] Sending image message as user_id=$uid');
      if (uid.isEmpty) {
        if (!mounted) return;
        setState(() {
          final String? failedTypingId = typingId;
          if (failedTypingId != null) {
            _removeTypingMessage(failedTypingId);
          }
          _addBotText('Please sign in to use the chatbot.', isError: true);
        });
        return;
      }

      final ChatbotImageResponse response = await _apiService.sendImageMessage(
        File(imagePath),
        userId: uid,
      );

      if (!mounted) {
        return;
      }

      final String analysis = response.imageAnalysis.trim();
      final String botResponse = response.response.trim();

      setState(() {
        _removeTypingMessage(currentTypingId);
        if (analysis.isNotEmpty) {
          _addBotText('Image analysis: $analysis');
        }
        _addBotText(
          botResponse.isNotEmpty
              ? botResponse
              : 'Thanks for the image. I can help explain what I see.',
        );
      });
    } on ChatbotMediaException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        final String? failedTypingId = typingId;
        if (failedTypingId != null) {
          _removeTypingMessage(failedTypingId);
        }
        _addBotText(error.message, isError: true);
      });
    } on ChatbotApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        final String? failedTypingId = typingId;
        if (failedTypingId != null) {
          _removeTypingMessage(failedTypingId);
        }
        _addBotText(error.message, isError: true);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        final String? failedTypingId = typingId;
        if (failedTypingId != null) {
          _removeTypingMessage(failedTypingId);
        }
        _addBotText('Failed to upload image. Please try again.', isError: true);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingImage = false;
        });
        _scrollToBottom();
      }
    }
  }

  String _buildTypingId() => 'typing_${DateTime.now().microsecondsSinceEpoch}';

  void _removeTypingMessage(String typingId) {
    _messages.removeWhere((message) => message.id == typingId);
  }

  void _addBotText(String text, {bool isError = false}) {
    _messages.add(
      MessageModel(
        id: '${isError ? 'error' : 'bot'}_${DateTime.now().microsecondsSinceEpoch}',
        text: text,
        isUser: false,
        isError: isError,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<ImageSource?> _showImageSourcePicker() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1511),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.mainGold,
                    size: 22.sp,
                  ),
                  title: Text(
                    'Choose from gallery',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.mainGold,
                    size: 22.sp,
                  ),
                  title: Text(
                    'Take a photo',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _resolveReplyText({
    required String responseText,
    required List<ChatbotHistoryEntry> history,
    required String fallbackPrompt,
  }) {
    final String trimmedResponse = responseText.trim();
    if (trimmedResponse.isNotEmpty) {
      return trimmedResponse;
    }

    for (final entry in history.reversed) {
      if (entry.role.toLowerCase() == 'assistant' && entry.content.trim().isNotEmpty) {
        return entry.content.trim();
      }
    }

    return _buildFallbackReply(fallbackPrompt);
  }

  String _buildFallbackReply(String prompt) {
    final String lower = prompt.toLowerCase();

    if (lower.contains('giza')) {
      return 'Giza is home to the Great Pyramid and the Sphinx. Sunset there is unforgettable.';
    }
    if (lower.contains('luxor')) {
      return 'Luxor is like an open-air museum. Start with Karnak Temple, then visit the Valley of the Kings.';
    }
    if (lower.contains('abu simbel')) {
      return 'Abu Simbel is in Aswan and famous for its massive rock-cut temples of Ramses II.';
    }
    if (lower.contains('museum')) {
      return 'The Grand Egyptian Museum near Giza is a perfect stop to explore ancient treasures.';
    }
    if (lower.contains('karnak')) {
      return 'Karnak Temple in Luxor is one of the largest religious complexes ever built in ancient Egypt.';
    }

    return 'Great question. I can help with history, tickets, transport, and the best times to visit Egypt landmarks.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double panelWidth = math.min(
              math.max(0, constraints.maxWidth - 32.w),
              860.0,
            ).toDouble();
            final double panelHeight = math.min(
              math.max(0, constraints.maxHeight - 48.h),
              760.0,
            ).toDouble();

            return SizedBox(
              width: panelWidth,
              height: panelHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF181310), Color(0xFF0F0C0A)],
                    ),
                    border: Border.all(
                      color: AppColors.subtleGoldBorder.withOpacity(0.9),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 36,
                        offset: const Offset(0, 22),
                      ),
                      BoxShadow(
                        color: AppColors.mainGold.withOpacity(0.12),
                        blurRadius: 26,
                        spreadRadius: -6,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(0.8, -0.9),
                                radius: 1.15,
                                colors: [
                                  AppColors.mainGold.withOpacity(0.12),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          _PanelHeader(onClose: widget.onClose),
                          Divider(
                            height: 1,
                            color: AppColors.subtleGoldBorder.withOpacity(0.5),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  return ChatBubble(message: _messages[index]);
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                            child: QuickSuggestions(
                              suggestions: _suggestions,
                              onTap: (value) {
                                _sendTextMessage(value);
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                            child: MessageInput(
                              controller: _controller,
                              onSend: _sendTextMessage,
                              onPickImage: _pickImageAndSend,
                              isSending: _isBusy,
                              isBusy: _isBusy,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _PanelHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 12.w, 14.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.mainGold.withOpacity(0.2),
                  AppColors.darkGold.withOpacity(0.55),
                ],
              ),
              border: Border.all(color: AppColors.mainGold.withOpacity(0.35)),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.mainGold,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI Tour Guide',
                      style: GoogleFonts.cinzel(
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFD98A),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD98A).withOpacity(0.75),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  'Ask me anything about Egypt',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.9),
                    fontSize: 12.sp,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(999.r),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: AppColors.subtleGoldBorder.withOpacity(0.6),
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimary.withOpacity(0.92),
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

