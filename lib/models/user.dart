import 'package:cloud_firestore/cloud_firestore.dart';
import 'shipping_address.dart';
import 'payment_method.dart';

enum UserRole { customer, admin, staff }

class User {
  final String? id;
  final String? email;
  final String? name;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Additional properties needed by the app
  final List<ShippingAddress>? shippingAddresses;
  final String? defaultShippingAddressId;
  final List<PaymentMethod>? paymentMethods;
  final String? defaultPaymentMethodId;

  User({
    this.id,
    this.email,
    this.name,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.role = UserRole.customer,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.shippingAddresses,
    this.defaultShippingAddressId,
    this.paymentMethods,
    this.defaultPaymentMethodId,
  });

  // Create a User from a Firebase user and additional data
  factory User.fromFirebaseUser(String uid, Map<String, dynamic>? userData) {
    if (userData == null) {
      // Default values for new users
      return User(
        id: uid,
        role: UserRole.customer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        shippingAddresses: [],
        paymentMethods: [],
      );
    }

    return User(
      id: uid,
      email: userData['email'],
      name: userData['name'],
      phone: userData['phone'],
      address: userData['address'],
      profileImageUrl: userData['profileImageUrl'],
      role: _parseUserRole(userData['role']),
      createdAt: userData['createdAt'] != null
          ? (userData['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: userData['updatedAt'] != null
          ? (userData['updatedAt'] as Timestamp).toDate()
          : null,
      isActive: userData['isActive'] ?? true,
      shippingAddresses: userData['shippingAddresses'] != null
          ? List<ShippingAddress>.from((userData['shippingAddresses'] as List)
              .map((item) => ShippingAddress.fromJson(item)))
          : [],
      defaultShippingAddressId: userData['defaultShippingAddressId'],
      paymentMethods: userData['paymentMethods'] != null
          ? List<PaymentMethod>.from((userData['paymentMethods'] as List)
              .map((item) => PaymentMethod.fromJson(item)))
          : [],
      defaultPaymentMethodId: userData['defaultPaymentMethodId'],
    );
  }

  static UserRole _parseUserRole(String? role) {
    if (role == 'admin') return UserRole.admin;
    if (role == 'staff') return UserRole.staff;
    return UserRole.customer;
  }

  // Convert user role enum to string
  static String userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.staff:
        return 'staff';
      case UserRole.customer:
        return 'customer';
    }
  }

  // Create a User from Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return User(
      id: doc.id,
      email: data['email'],
      name: data['name'],
      phone: data['phone'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      role: _parseUserRole(data['role']),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      shippingAddresses: data['shippingAddresses'] != null
          ? List<ShippingAddress>.from((data['shippingAddresses'] as List)
              .map((item) => ShippingAddress.fromJson(item)))
          : [],
      defaultShippingAddressId: data['defaultShippingAddressId'],
      paymentMethods: data['paymentMethods'] != null
          ? List<PaymentMethod>.from((data['paymentMethods'] as List)
              .map((item) => PaymentMethod.fromJson(item)))
          : [],
      defaultPaymentMethodId: data['defaultPaymentMethodId'],
    );
  }
  
  // Create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      profileImageUrl: json['profileImageUrl'],
      role: _parseUserRole(json['role']),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp 
              ? (json['createdAt'] as Timestamp).toDate() 
              : DateTime.parse(json['createdAt']))
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp 
              ? (json['updatedAt'] as Timestamp).toDate() 
              : DateTime.parse(json['updatedAt']))
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  // Convert User to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'role': userRoleToString(role),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': DateTime.now(),
      'isActive': isActive,
      'shippingAddresses': shippingAddresses?.map((address) => address.toJson()).toList(),
      'defaultShippingAddressId': defaultShippingAddressId,
      'paymentMethods': paymentMethods?.map((method) => method.toJson()).toList(),
      'defaultPaymentMethodId': defaultPaymentMethodId,
    };
  }

  // Create a copy of the User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<ShippingAddress>? shippingAddresses,
    String? defaultShippingAddressId,
    List<PaymentMethod>? paymentMethods,
    String? defaultPaymentMethodId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      shippingAddresses: shippingAddresses ?? this.shippingAddresses,
      defaultShippingAddressId: defaultShippingAddressId ?? this.defaultShippingAddressId,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      defaultPaymentMethodId: defaultPaymentMethodId ?? this.defaultPaymentMethodId,
    );
  }
  
  // Get the default shipping address if available
  ShippingAddress? get defaultShippingAddress {
    if (defaultShippingAddressId == null || shippingAddresses == null || shippingAddresses!.isEmpty) {
      return null;
    }
    return shippingAddresses!.firstWhere(
      (address) => address.id == defaultShippingAddressId,
      orElse: () => shippingAddresses!.first,
    );
  }
  
  // Get the default payment method if available
  PaymentMethod? get defaultPaymentMethod {
    if (defaultPaymentMethodId == null || paymentMethods == null || paymentMethods!.isEmpty) {
      return null;
    }
    return paymentMethods!.firstWhere(
      (method) => method.id == defaultPaymentMethodId,
      orElse: () => paymentMethods!.first,
    );
  }
}