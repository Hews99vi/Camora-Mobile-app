import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../models/user.dart';
import '../controllers/auth_controller.dart';

class ChatService extends GetxController {
  static ChatService get instance => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authController = Get.find<AuthController>();

  // Collection references
  CollectionReference get _chatRoomsCollection => _firestore.collection('chatRooms');
  CollectionReference _messagesCollection(String chatRoomId) => 
      _firestore.collection('chatRooms').doc(chatRoomId).collection('messages');
  
  // Stream of chat rooms for the current user (customer or admin)
  Stream<List<ChatRoom>> getChatRooms() {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return Stream.value([]);
    
    // Different queries based on user role
    Query query;
    if (currentUser.role == UserRole.admin) {
      // Admins can see all chat rooms
      query = _chatRoomsCollection.orderBy('lastMessageTime', descending: true);
    } else {
      // Customers only see their own chat rooms
      query = _chatRoomsCollection
          .where('userId', isEqualTo: currentUser.id)
          .orderBy('lastMessageTime', descending: true);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatRoom.fromFirestore(doc))
          .toList();
    });
  }
  
  // Stream of messages for a specific chat room
  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _messagesCollection(chatRoomId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }
  
  // Send a text message
  Future<void> sendTextMessage(String chatRoomId, String content) async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    
    final message = ChatMessage(
      senderId: currentUser.id!,
      senderName: currentUser.name ?? 'Anonymous',
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );
    
    await _sendMessage(chatRoomId, message);
  }
  
  // Send an image message
  Future<void> sendImageMessage(String chatRoomId, File image) async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    
    // Upload image to Firebase Storage
    final fileName = 'chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = _storage.ref().child(fileName);
    
    try {
      // Upload image
      await storageRef.putFile(image);
      
      // Get download URL
      final imageUrl = await storageRef.getDownloadURL();
      
      // Create and send message
      final message = ChatMessage(
        senderId: currentUser.id!,
        senderName: currentUser.name ?? 'Anonymous',
        content: 'Sent an image',
        type: MessageType.image,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );
      
      await _sendMessage(chatRoomId, message);
    } catch (e) {
      debugPrint('Error sending image: $e');
      throw Exception('Failed to send image message: $e');
    }
  }
  
  // Helper method to send any type of message and update the chat room
  Future<void> _sendMessage(String chatRoomId, ChatMessage message) async {
    try {
      // Get chat room details to update
      final chatRoomSnapshot = await _chatRoomsCollection.doc(chatRoomId).get();
      final chatRoom = ChatRoom.fromFirestore(chatRoomSnapshot);
      
      // Add message to the messages subcollection
      await _messagesCollection(chatRoomId).add(message.toJson());
      
      // Update chat room with latest message info
      await _chatRoomsCollection.doc(chatRoomId).update({
        'lastMessage': message.content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'hasUnreadMessages': message.senderId != chatRoom.userId, // Mark unread for the other user
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }
  
  // Create a new chat room for a user
  Future<String> createChatRoom(String userId, String userName) async {
    try {
      // Check if chat room already exists
      final existingRooms = await _chatRoomsCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (existingRooms.docs.isNotEmpty) {
        // Return existing chat room ID
        return existingRooms.docs.first.id;
      }
      
      // Create new chat room
      final chatRoom = ChatRoom(
        id: '', // Will be filled by Firestore
        userId: userId,
        userName: userName,
        lastMessageTime: DateTime.now(),
        lastMessage: 'Chat created',
      );
      
      final docRef = await _chatRoomsCollection.add(chatRoom.toJson());
      
      // Send system welcome message
      final welcomeMessage = ChatMessage(
        senderId: 'system',
        senderName: 'System',
        content: 'Welcome to chat support! How can we help you today?',
        type: MessageType.system,
        timestamp: DateTime.now(),
      );
      
      await _messagesCollection(docRef.id).add(welcomeMessage.toJson());
      
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      throw Exception('Failed to create chat room: $e');
    }
  }
  
  // Mark all messages in a chat room as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return;
    
    try {
      // Get unread messages not sent by the current user
      final unreadMessages = await _messagesCollection(chatRoomId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUser.id)
          .get();
      
      // Mark each message as read
      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'isRead': true});
      }
      
      // Update chat room to remove unread flag
      await _chatRoomsCollection.doc(chatRoomId).update({
        'hasUnreadMessages': false,
      });
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }
}