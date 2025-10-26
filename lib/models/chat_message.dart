import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  system
}

class ChatMessage {
  final String? id;
  final String senderId;
  final String senderName;
  final String? receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.senderName,
    this.receiverId,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  // Create a ChatMessage from a Firestore document
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverId: data['receiverId'],
      content: data['content'] ?? '',
      type: _parseMessageType(data['type']),
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }

  static MessageType _parseMessageType(String? type) {
    if (type == 'image') return MessageType.image;
    if (type == 'system') return MessageType.system;
    return MessageType.text;
  }

  static String messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.image:
        return 'image';
      case MessageType.system:
        return 'system';
      default:
        return 'text';
    }
  }

  // Convert ChatMessage to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'content': content,
      'type': messageTypeToString(type),
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  // Create a copy of the ChatMessage with updated fields
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class ChatRoom {
  final String id;
  final String userId;
  final String userName;
  final DateTime lastMessageTime;
  final String lastMessage;
  final bool hasUnreadMessages;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.userName,
    required this.lastMessageTime,
    required this.lastMessage,
    this.hasUnreadMessages = false,
  });

  // Create a ChatRoom from a Firestore document
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : DateTime.now(),
      lastMessage: data['lastMessage'] ?? '',
      hasUnreadMessages: data['hasUnreadMessages'] ?? false,
    );
  }

  // Convert ChatRoom to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessage': lastMessage,
      'hasUnreadMessages': hasUnreadMessages,
    };
  }

  // Create a copy of the ChatRoom with updated fields
  ChatRoom copyWith({
    String? id,
    String? userId,
    String? userName,
    DateTime? lastMessageTime,
    String? lastMessage,
    bool? hasUnreadMessages,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }
}