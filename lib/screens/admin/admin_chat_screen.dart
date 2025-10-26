import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/chat_message.dart';
import '../../utils/theme.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final ChatController _chatController = Get.find<ChatController>();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Force refresh chat rooms when screen loads
    _chatController.refreshChatRooms();
    // Clear any previously selected chat
    _chatController.currentChatRoomId.value = '';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _chatController.sendImageMessage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Obx(() => Text(
          _chatController.currentChatRoomId.isEmpty
              ? 'Customer Support'
              : _getChatRoomById(_chatController.currentChatRoomId.value)?.userName ?? 'Chat'
        )),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _chatController.refreshChatRooms();
              Get.snackbar(
                'Refreshed',
                'Chat conversations refreshed',
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade900,
                duration: const Duration(seconds: 1),
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
        // Add back button if a chat is open
        leading: Obx(() {
          if (_chatController.currentChatRoomId.isEmpty) {
            return const SizedBox.shrink(); // Return empty widget when no chat selected
          }
          return IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _chatController.currentChatRoomId.value = '';
            },
          );
        }),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          // If no chat is selected, show conversations list
          if (_chatController.currentChatRoomId.isEmpty) {
            return _buildConversationsList();
          }
          
          // If chat is selected, show chat messages
          return _buildChatMessages();
        }),
      ),
    );
  }

  // List of all conversations (WhatsApp-style)
  Widget _buildConversationsList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade100,
          width: double.infinity,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Conversations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_chatController.chatRooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No active conversations',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _chatController.refreshChatRooms,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: _chatController.chatRooms.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chatRoom = _chatController.chatRooms[index];
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          chatRoom.userName.isNotEmpty 
                              ? chatRoom.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Unread indicator
                      if (chatRoom.hasUnreadMessages)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    chatRoom.userName,
                    style: TextStyle(
                      fontWeight: chatRoom.hasUnreadMessages 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatRoom.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: chatRoom.hasUnreadMessages
                              ? Colors.black87
                              : Colors.grey.shade600,
                          fontWeight: chatRoom.hasUnreadMessages
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(chatRoom.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _chatController.selectChatRoom(chatRoom.id);
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // Chat messages when a conversation is selected
  Widget _buildChatMessages() {
    final ScrollController scrollController = ScrollController();
    
    return Column(
      children: [
        // Messages area
        Expanded(
          child: _chatController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : _chatController.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No messages yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation by sending a message',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: _chatController.messages.length,
                      itemBuilder: (context, index) {
                        final message = _chatController.messages[index];
                        return _buildMessageItem(message, context);
                      },
                    ),
        ),

        // Input area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
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
                  child: TextField(
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
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _chatController.sendTextMessage();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                Obx(() {
                  final text = _chatController.messageController.value.text;
                  final bool canSend = text.trim().isNotEmpty;
                  
                  return MaterialButton(
                    onPressed: canSend
                      ? () {
                          _chatController.sendTextMessage();
                          FocusScope.of(context).unfocus();
                          // Scroll to bottom after sending
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (scrollController.hasClients) {
                              scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          });
                        }
                      : null,
                    color: canSend 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade300,
                    textColor: canSend ? Colors.white : Colors.grey,
                    minWidth: 0,
                    elevation: 0,
                    highlightElevation: 0,
                    padding: const EdgeInsets.all(12),
                    shape: const CircleBorder(),
                    child: const Icon(Icons.send),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ChatRoom? _getChatRoomById(String id) {
    try {
      return _chatController.chatRooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
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