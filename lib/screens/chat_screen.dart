import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/chat_message.dart';
import '../utils/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController _chatController = Get.find<ChatController>();
  final AuthController _authController = Get.find<AuthController>();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // If no chat room exists yet, create one
    if (_chatController.chatRooms.isEmpty) {
      final chatRoomId = await _chatController.createNewChat();
      if (chatRoomId != null) {
        _chatController.selectChatRoom(chatRoomId);
      }
    }
    // If chat rooms exist but none is selected, select the first one
    else if (_chatController.currentChatRoomId.isEmpty && _chatController.chatRooms.isNotEmpty) {
      _chatController.selectChatRoom(_chatController.chatRooms.first.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _chatController.sendImageMessage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap outside to dismiss keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          title: const Text('Chat with Support'),
          elevation: 0,
        ),
        body: Column(
        children: [
          // Messages area
          Expanded(
            child: Obx(() {
              if (_chatController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_chatController.messages.isEmpty) {
                return const Center(
                  child: Text('No messages yet. Start a conversation!'),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = _chatController.messages[index];
                  return _buildMessageItem(message, context);
                },
              );
            }),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(0, -1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Image upload button
                  IconButton(
                    icon: const Icon(Icons.photo),
                    color: Theme.of(context).primaryColor,
                    onPressed: _pickImage,
                  ),
                  // Text field
                  Expanded(
                    child: Obx(() => TextField(
                      controller: _chatController.messageController.value,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          _chatController.sendTextMessage();
                        }
                      },
                    )),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  Obx(() {
                    final text = _chatController.messageController.value.text;
                    return Material(
                      color: text.trim().isEmpty
                          ? Colors.grey.shade300
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: text.trim().isEmpty
                            ? null
                            : () {
                                _chatController.sendTextMessage();
                                FocusScope.of(context).unfocus(); // Hide keyboard after sending
                              },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.send,
                            color: text.trim().isEmpty
                                ? Colors.grey
                                : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, BuildContext context) {
    final currentUserId = _authController.currentUser?.id;
    final isMyMessage = message.senderId == currentUserId;
    final isSystemMessage = message.type == MessageType.system;

    // Format timestamp
    final formattedTime = DateFormat('h:mm a').format(message.timestamp);
    final formattedDate = DateFormat('MMM d').format(message.timestamp);
    final timeLabel = '$formattedTime · $formattedDate';

    if (isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isMyMessage
              ? Theme.of(context).primaryColor
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name (only show for received messages)
            if (!isMyMessage && message.type != MessageType.system)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isMyMessage ? Colors.white70 : AppTheme.primaryColor,
                  ),
                ),
              ),

            // Message content
            if (message.type == MessageType.text)
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: !isMyMessage ? 4 : 8,
                  bottom: 4,
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMyMessage ? Colors.white : Colors.black87,
                  ),
                ),
              )
            else if (message.type == MessageType.image && message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isMyMessage ? Colors.white : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
              child: Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isMyMessage ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}