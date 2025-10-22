import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingAddress {
  final String? id;
  final String? userId;
  final String? name;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? phoneNumber;
  final bool? isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShippingAddress({
    this.id,
    this.userId,
    this.name,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.phoneNumber,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  // Create a ShippingAddress from Firestore document
  factory ShippingAddress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return ShippingAddress(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      street: data['street'],
      city: data['city'],
      state: data['state'],
      zipCode: data['zipCode'],
      country: data['country'],
      phoneNumber: data['phoneNumber'],
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create a ShippingAddress from a Map
  factory ShippingAddress.fromMap(Map<String, dynamic> data) {
    return ShippingAddress(
      id: data['id'],
      userId: data['userId'],
      name: data['name'],
      street: data['street'],
      city: data['city'],
      state: data['state'],
      zipCode: data['zipCode'],
      country: data['country'],
      phoneNumber: data['phoneNumber'],
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
  
  // Create a ShippingAddress from JSON
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
      phoneNumber: json['phoneNumber'],
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

  // Convert ShippingAddress to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': DateTime.now(),
    };
  }

  // Create a copy of the ShippingAddress with updated fields
  ShippingAddress copyWith({
    String? id,
    String? userId,
    String? name,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phoneNumber,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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