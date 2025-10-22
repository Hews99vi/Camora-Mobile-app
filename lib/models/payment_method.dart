import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethod {
  final String? id;
  final String? userId;
  final String? holderName;
  final String? last4;
  final String? brand;
  final int? expiryMonth;
  final int? expiryYear;
  final bool? isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentMethod({
    this.id,
    this.userId,
    this.holderName,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  // Create a PaymentMethod from Firestore document
  factory PaymentMethod.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return PaymentMethod(
      id: doc.id,
      userId: data['userId'],
      holderName: data['holderName'],
      last4: data['last4'],
      brand: data['brand'],
      expiryMonth: data['expiryMonth'],
      expiryYear: data['expiryYear'],
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
  
  // Create a PaymentMethod from JSON
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      userId: json['userId'],
      holderName: json['holderName'],
      last4: json['last4'],
      brand: json['brand'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      isDefault: json['isDefault'] ?? false,
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

  // Convert PaymentMethod to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'holderName': holderName,
      'last4': last4,
      'brand': brand,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': DateTime.now(),
    };
  }

  // Create a copy of the PaymentMethod with updated fields
  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? holderName,
    String? last4,
    String? brand,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      holderName: holderName ?? this.holderName,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get the expiry date as a formatted string (MM/YY)
  String get expiryDate {
    if (expiryMonth == null || expiryYear == null) return '';
    final month = expiryMonth.toString().padLeft(2, '0');
    final year = expiryYear.toString().substring(2);
    return '$month/$year';
  }

  // Get the card icon based on the brand
  String get cardIcon {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return 'assets/icons/visa.png';
      case 'mastercard':
        return 'assets/icons/mastercard.png';
      case 'amex':
        return 'assets/icons/amex.png';
      case 'discover':
        return 'assets/icons/discover.png';
      default:
        return 'assets/icons/credit_card.png';
    }
  }

  // Get the masked card number
  String get maskedNumber {
    if (last4 == null) return '';
    return '**** **** **** $last4';
  }
  
  // Get the display name (brand and last 4 digits)
  String get displayName {
    if (brand == null || last4 == null) return 'Card';
    return '${brand!} **** $last4';
  }
  
  // Get the expiry date in MM/YY format for display
  String get expiryDisplay {
    return expiryDate;
  }
}