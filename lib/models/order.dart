import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  processing,
  confirmed, // Added confirmed status
  shipped,
  delivered,
  cancelled,
  returned,
  refunded
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
  partiallyRefunded
}

// Status color and icon data
class OrderStatusInfo {
  final String displayName;
  final String description;
  final Color color;
  final IconData icon;
  final double progressValue;

  OrderStatusInfo({
    required this.displayName,
    required this.description,
    required this.color,
    required this.icon,
    required this.progressValue,
  });
}

// Payment status color data
class PaymentStatusInfo {
  final String displayName;
  final Color color;

  PaymentStatusInfo({
    required this.displayName,
    required this.color,
  });
}

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }
  
  // Get the display name for UI
  String get displayName => name;
  
  // Get the description for UI
  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Your order has been received and is awaiting processing.';
      case OrderStatus.processing:
        return 'Your order is being prepared for shipping.';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed and is being prepared.';
      case OrderStatus.shipped:
        return 'Your order has been shipped and is on the way.';
      case OrderStatus.delivered:
        return 'Your order has been delivered to the destination.';
      case OrderStatus.cancelled:
        return 'This order has been cancelled.';
      case OrderStatus.returned:
        return 'This order has been returned.';
      case OrderStatus.refunded:
        return 'A refund has been issued for this order.';
    }
  }
  
  // Get the color for UI
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.confirmed:
        return Colors.cyan;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.amber;
      case OrderStatus.refunded:
        return Colors.purple;
    }
  }
  
  // Get the icon for UI
  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.confirmed:
        return Icons.check;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.returned:
        return Icons.replay;
      case OrderStatus.refunded:
        return Icons.money;
    }
  }
  
  // Get progress value for UI (0.0 to 1.0)
  double get progressValue {
    switch (this) {
      case OrderStatus.pending:
        return 0.16;
      case OrderStatus.processing:
        return 0.33;
      case OrderStatus.confirmed:
        return 0.5;
      case OrderStatus.shipped:
        return 0.75;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
      case OrderStatus.returned:
        return 0.0;
      case OrderStatus.refunded:
        return 0.0;
    }
  }
  
  // Get the status flow for order tracking
  bool get progressOrder {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.processing:
      case OrderStatus.shipped:
      case OrderStatus.delivered:
        return true;
      default:
        return false;
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get name {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }
  
  // Get the display name for UI
  String get displayName => name;
  
  // Get the description for UI
  String get description {
    switch (this) {
      case PaymentStatus.pending:
        return 'Payment is being processed.';
      case PaymentStatus.paid:
        return 'Payment has been completed successfully.';
      case PaymentStatus.failed:
        return 'Payment transaction has failed.';
      case PaymentStatus.refunded:
        return 'Payment has been fully refunded.';
      case PaymentStatus.partiallyRefunded:
        return 'Payment has been partially refunded.';
    }
  }
  
  // Get the color for UI
  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.partiallyRefunded:
        return Colors.deepPurple;
    }
  }
  
  // Get the icon for UI
  IconData get icon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.pending_actions;
      case PaymentStatus.paid:
        return Icons.paid;
      case PaymentStatus.failed:
        return Icons.error_outline;
      case PaymentStatus.refunded:
        return Icons.replay;
      case PaymentStatus.partiallyRefunded:
        return Icons.sync_problem;
    }
  }
}

class OrderItem {
  final String? id;
  final String? productId;
  final String? productName;
  final String? productImage;
  final String? size;
  final String? color;
  final int? quantity;
  final double? price;
  final double? total;

  OrderItem({
    this.id,
    this.productId,
    this.productName,
    this.productImage,
    this.size,
    this.color,
    this.quantity,
    this.price,
    this.total,
  });

  // Create an OrderItem from a Map
  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      id: data['id'],
      productId: data['productId'],
      productName: data['productName'],
      productImage: data['productImage'],
      size: data['size'],
      color: data['color'],
      quantity: data['quantity'],
      price: (data['price'] as num?)?.toDouble(),
      total: (data['total'] as num?)?.toDouble(),
    );
  }
  
  // Create an OrderItem from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem.fromMap(json);
  }

  // Convert OrderItem to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'size': size,
      'color': color,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class ShippingAddress {
  final String? id;
  final String? name;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? phoneNumber;
  final bool? isDefault;
  final String? fullName;
  final String? address;

  ShippingAddress({
    this.id,
    this.name,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.phoneNumber,
    this.isDefault,
    this.fullName,
    this.address,
  });

  // Create a ShippingAddress from a Map
  factory ShippingAddress.fromMap(Map<String, dynamic> data) {
    return ShippingAddress(
      id: data['id'],
      name: data['name'],
      street: data['street'],
      city: data['city'],
      state: data['state'],
      zipCode: data['zipCode'],
      country: data['country'],
      phoneNumber: data['phoneNumber'],
      isDefault: data['isDefault'],
      fullName: data['fullName'],
      address: data['address'],
    );
  }
  
  // Create a ShippingAddress from JSON
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress.fromMap(json);
  }

  // Convert ShippingAddress to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
      'fullName': fullName,
      'address': address,
    };
  }

  // Create a copy of the ShippingAddress with updated fields
  ShippingAddress copyWith({
    String? id,
    String? name,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phoneNumber,
    bool? isDefault,
    String? fullName,
    String? address,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefault: isDefault ?? this.isDefault,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
    );
  }

  // Get the full address as a string
  String get fullAddress {
    final streetStr = street ?? '';
    final cityStr = city ?? '';
    final stateStr = state ?? '';
    final zipStr = zipCode ?? '';
    final countryStr = country ?? '';
    
    return '$streetStr, $cityStr, $stateStr $zipStr, $countryStr'.replaceAll(RegExp(r', ,|,  |, $'), '');
  }
}

class Order {
  final String? id;
  final String? userId;
  final String? userName;
  final String? customerName;
  final String? customerEmail;
  final List<OrderItem>? items;
  final ShippingAddress? shippingAddress;
  final double? subTotal;
  final double? shippingFee;
  final double? tax;
  final double? discount;
  final double? totalAmount;
  final String? paymentMethod;
  final PaymentStatus? paymentStatus;
  final OrderStatus? status;
  final String? trackingNumber;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? paymentIntentId;

  Order({
    this.id,
    this.userId,
    this.userName,
    this.customerName,
    this.customerEmail,
    this.items,
    this.shippingAddress,
    this.subTotal,
    this.shippingFee,
    this.tax,
    this.discount,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.status,
    this.trackingNumber,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.shippedAt,
    this.deliveredAt,
    this.paymentIntentId,
  });

  // Create an Order from Firestore document
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Order(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'],
      customerName: data['customerName'],
      customerEmail: data['customerEmail'],
      items: data['items'] != null
          ? List<OrderItem>.from(
              (data['items'] as List).map((item) => OrderItem.fromMap(item)))
          : null,
      shippingAddress: data['shippingAddress'] != null
          ? ShippingAddress.fromMap(data['shippingAddress'])
          : null,
      subTotal: (data['subTotal'] as num?)?.toDouble(),
      shippingFee: (data['shippingFee'] as num?)?.toDouble(),
      tax: (data['tax'] as num?)?.toDouble(),
      discount: (data['discount'] as num?)?.toDouble(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble(),
      paymentMethod: data['paymentMethod'],
      paymentStatus: _parsePaymentStatus(data['paymentStatus']),
      status: _parseOrderStatus(data['status']),
      trackingNumber: data['trackingNumber'],
      notes: data['notes'],
      paymentIntentId: data['paymentIntentId'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      shippedAt: data['shippedAt'] != null
          ? (data['shippedAt'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
    );
  }
  
  // Create an Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      items: json['items'] != null
          ? List<OrderItem>.from(
              (json['items'] as List).map((item) => OrderItem.fromJson(item)))
          : null,
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddress.fromJson(json['shippingAddress'])
          : null,
      subTotal: (json['subTotal'] as num?)?.toDouble(),
      shippingFee: (json['shippingFee'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      status: _parseOrderStatus(json['status']),
      trackingNumber: json['trackingNumber'],
      notes: json['notes'],
      paymentIntentId: json['paymentIntentId'],
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
      shippedAt: json['shippedAt'] != null
          ? (json['shippedAt'] is Timestamp 
              ? (json['shippedAt'] as Timestamp).toDate() 
              : DateTime.parse(json['shippedAt'].toString()))
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? (json['deliveredAt'] is Timestamp 
              ? (json['deliveredAt'] as Timestamp).toDate() 
              : DateTime.parse(json['deliveredAt'].toString()))
          : null,
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    if (status == 'processing') {
      return OrderStatus.processing;
    }
    if (status == 'confirmed') {
      return OrderStatus.confirmed;
    }
    if (status == 'shipped') {
      return OrderStatus.shipped;
    }
    if (status == 'delivered') {
      return OrderStatus.delivered;
    }
    if (status == 'cancelled') {
      return OrderStatus.cancelled;
    }
    if (status == 'returned') {
      return OrderStatus.returned;
    }
    if (status == 'refunded') {
      return OrderStatus.refunded;
    }
    return OrderStatus.pending;
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    if (status == 'paid') {
      return PaymentStatus.paid;
    }
    if (status == 'failed') {
      return PaymentStatus.failed;
    }
    if (status == 'refunded') {
      return PaymentStatus.refunded;
    }
    if (status == 'partiallyRefunded') {
      return PaymentStatus.partiallyRefunded;
    }
    return PaymentStatus.pending;
  }

  // Convert OrderStatus enum to string
  static String orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.returned:
        return 'returned';
      case OrderStatus.refunded:
        return 'refunded';
    }
  }

  // Convert PaymentStatus enum to string
  static String paymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.partiallyRefunded:
        return 'partiallyRefunded';
    }
  }

  // Convert Order to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'items': items?.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress?.toJson(),
      'subTotal': subTotal,
      'shippingFee': shippingFee,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus != null
          ? paymentStatusToString(paymentStatus!)
          : paymentStatusToString(PaymentStatus.pending),
      'status': status != null
          ? orderStatusToString(status!)
          : orderStatusToString(OrderStatus.pending),
      'trackingNumber': trackingNumber,
      'notes': notes,
      'paymentIntentId': paymentIntentId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': DateTime.now(),
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'deliveredAt':
          deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }

  // Create a copy of the Order with updated fields
  Order copyWith({
    String? id,
    String? userId,
    String? userName,
    String? customerName,
    String? customerEmail,
    List<OrderItem>? items,
    ShippingAddress? shippingAddress,
    double? subTotal,
    double? shippingFee,
    double? tax,
    double? discount,
    double? totalAmount,
    String? paymentMethod,
    PaymentStatus? paymentStatus,
    OrderStatus? status,
    String? trackingNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    String? paymentIntentId,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      subTotal: subTotal ?? this.subTotal,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
    );
  }
  
  // Get order status info for UI
  OrderStatusInfo get statusInfo {
    if (status == null) {
      return OrderStatusInfo(
        displayName: 'Unknown',
        description: 'Unknown order status',
        color: Colors.grey,
        icon: Icons.help_outline,
        progressValue: 0.0
      );
    }
    
    return OrderStatusInfo(
      displayName: status!.displayName,
      description: status!.description,
      color: status!.color,
      icon: status!.icon,
      progressValue: status!.progressValue
    );
  }
  
  // Get payment status info for UI
  PaymentStatusInfo get paymentStatusInfo {
    if (paymentStatus == null) {
      return PaymentStatusInfo(
        displayName: 'Unknown',
        color: Colors.grey
      );
    }
    
    return PaymentStatusInfo(
      displayName: paymentStatus!.displayName,
      color: paymentStatus!.color
    );
  }
  
  // Get formatted creation date
  String get formattedCreatedAt {
    if (createdAt == null) return 'N/A';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }
  
  // Get formatted date with time
  String get formattedCreatedAtWithTime {
    if (createdAt == null) return 'N/A';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year} ${createdAt!.hour}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }
  
  // Get formatted delivery date if available
  String get formattedDeliveredAt {
    if (deliveredAt == null) return 'Not delivered yet';
    return '${deliveredAt!.day}/${deliveredAt!.month}/${deliveredAt!.year}';
  }
  
  // Get total number of items
  int get itemCount {
    if (items == null) {
      return 0;
    }
    return items!.fold(0, (total, item) => total + (item.quantity ?? 0));
  }
  
  // Check if order has been delivered
  bool get isDelivered => status == OrderStatus.delivered;
  
  // Check if order is in progress
  bool get isInProgress {
    return status == OrderStatus.pending || 
      status == OrderStatus.processing || 
      status == OrderStatus.shipped;
  }
}