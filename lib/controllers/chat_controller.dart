import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../controllers/auth_controller.dart';

class ChatController extends GetxController {
  static ChatController get instance => Get.find();
  
  final ChatService _chatService = Get.put(ChatService());
  final AuthController _authController = Get.find<AuthController>();
  
  // Reactive variables
  final RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentChatRoomId = ''.obs;
  final Rx<TextEditingController> messageController = TextEditingController().obs;
  
  // Streams
  Stream<List<ChatRoom>>? _chatRoomsStream;
  Stream<List<ChatMessage>>? _messagesStream;
  
  @override
  void onInit() {
    super.onInit();
    // Start listening to chat rooms
    _loadChatRooms();
  }
  
  @override
  void onClose() {
    messageController.value.dispose();
    super.onClose();
  }
  
  // Load chat rooms for the current user
  void _loadChatRooms() {
    final user = _authController.currentUser;
    if (user == null) return;
    
    try {
      _chatRoomsStream = _chatService.getChatRooms();
      
      // Listen to the stream and update the chatRooms list
      _chatRoomsStream?.listen((rooms) {
        chatRooms.assignAll(rooms);
      });
    } catch (e) {
      debugPrint('Error loading chat rooms: $e');
      Get.snackbar('Error', 'Failed to load chats');
    }
  }
  
  // Select and load messages for a specific chat room
  Future<void> selectChatRoom(String chatRoomId) async {
    if (chatRoomId == currentChatRoomId.value) return; // Already selected
    
    currentChatRoomId.value = chatRoomId;
    isLoading.value = true;
    
    try {
      _messagesStream = _chatService.getChatMessages(chatRoomId);
      
      // Listen to the stream and update the messages list
      _messagesStream?.listen((msgs) {
        messages.assignAll(msgs);
      });
      
      // Mark messages as read
      await _chatService.markMessagesAsRead(chatRoomId);
    } catch (e) {
      debugPrint('Error loading messages: $e');
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Send a text message
  Future<void> sendTextMessage() async {
    final message = messageController.value.text.trim();
    if (message.isEmpty || currentChatRoomId.value.isEmpty) return;
    
    try {
      // Store message text before clearing
      final messageText = message;
      
      // Clear input field immediately for better UX
      messageController.value.clear();
      
      // Send message
      await _chatService.sendTextMessage(currentChatRoomId.value, messageText);
      
      // Debug log for confirmation
      debugPrint('Message sent successfully: $messageText');
    } catch (e) {
      debugPrint('Error sending message: $e');
      Get.snackbar(
        'Error', 
        'Failed to send message. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  // Send an image message
  Future<void> sendImageMessage(File image) async {
    if (currentChatRoomId.value.isEmpty) return;
    
    isLoading.value = true;
    try {
      await _chatService.sendImageMessage(currentChatRoomId.value, image);
    } catch (e) {
      debugPrint('Error sending image: $e');
      Get.snackbar('Error', 'Failed to send image');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Create a new chat for the current user (customer)
  Future<String?> createNewChat() async {
    final user = _authController.currentUser;
    if (user == null) return null;
    
    isLoading.value = true;
    try {
      final chatRoomId = await _chatService.createChatRoom(
        user.id!,
        user.name ?? 'Anonymous User',
      );
      return chatRoomId;
    } catch (e) {
      debugPrint('Error creating chat: $e');
      Get.snackbar('Error', 'Failed to create chat');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Check if the current user is an admin
  bool get isAdmin => _authController.isAdmin;
  
  // Get badge count for unread messages
  int getUnreadChatCount() {
    return chatRooms.where((room) => room.hasUnreadMessages).length;
  }
  
  // Refresh chat rooms
  Future<void> refreshChatRooms() async {
    // Clear the current chat room ID to prevent auto-selection
    currentChatRoomId.value = '';
    
    // Clear messages
    messages.clear();
    
    // Re-load chat rooms
    _loadChatRooms();
  }
}