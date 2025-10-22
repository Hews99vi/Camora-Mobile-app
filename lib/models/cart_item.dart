import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String? id;
  final String? userId;
  final String? productId;
  final String? productName;
  final String? productImage;
  final String? size;
  final String? color;
  final int? quantity;
  final double? price;
  final double? total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItem({
    this.id,
    this.userId,
    this.productId,
    this.productName,
    this.productImage,
    this.size,
    this.color,
    this.quantity = 1,
    this.price,
    double? total,
    this.createdAt,
    this.updatedAt,
  }) : total = total ?? (price != null && quantity != null ? price * quantity : null);
  
  // Calculate the total price based on price and quantity
  double? get calculatedTotal {
    if (price == null || quantity == null) return total;
    return price! * quantity!;
  }

  // Create a CartItem from Firestore document
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return CartItem(
      id: doc.id,
      userId: data['userId'],
      productId: data['productId'],
      productName: data['productName'],
      productImage: data['productImage'],
      size: data['size'],
      color: data['color'],
      quantity: data['quantity'],
      price: (data['price'] as num?)?.toDouble(),
      total: (data['total'] as num?)?.toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create a CartItem from a Map
  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      userId: data['userId'],
      productId: data['productId'],
      productName: data['productName'],
      productImage: data['productImage'],
      size: data['size'],
      color: data['color'],
      quantity: data['quantity'],
      price: (data['price'] as num?)?.toDouble(),
      total: (data['total'] as num?)?.toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
  
  // Create a CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['userId'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'],
      price: (json['price'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp 
              ? (json['createdAt'] as Timestamp).toDate() 
              : DateTime.parse(json['createdAt'].toString()))
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp 
              ? (json['updatedAt'] as Timestamp).toDate() 
              : DateTime.parse(json['updatedAt'].toString()))
          : null,
    );
  }

  // Convert CartItem to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'size': size,
      'color': color,
      'quantity': quantity,
      'price': price,
      'total': total,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': DateTime.now(),
    };
  }

  // Create a copy of the CartItem with updated fields
  CartItem copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productImage,
    String? size,
    String? color,
    int? quantity,
    double? price,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}