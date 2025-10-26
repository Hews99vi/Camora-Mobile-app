import 'package:flutter/foundation.dart';

// This is a stub implementation for platforms where flutter_stripe is not available
// It mimics the flutter_stripe API but does nothing

class Stripe {
  static set publishableKey(String key) {
    // Do nothing in stub
    debugPrint('Stripe.publishableKey is not implemented in this build');
  }
  
  static set merchantIdentifier(String identifier) {
    // Do nothing in stub
    debugPrint('Stripe.merchantIdentifier is not implemented in this build');
  }
  
  static set stripeAccountId(String? accountId) {
    // Do nothing in stub
    debugPrint('Stripe.stripeAccountId is not implemented in this build');
  }
  
  static set urlScheme(String? scheme) {
    // Do nothing in stub
    debugPrint('Stripe.urlScheme is not implemented in this build');
  }
  
  static Future<void> instance() async {
    // Return a completed future that does nothing
    return;
  }
  
  static Future<void> createPaymentMethod({Map<String, dynamic>? params}) async {
    // Return a completed future that does nothing
    debugPrint('Stripe.createPaymentMethod is not implemented in this build');
    return;
  }
  
  // Add other commonly used methods to avoid runtime errors
  static Future<void> initPaymentSheet({required Map<String, dynamic> paymentSheetParameters}) async {
    debugPrint('Stripe.initPaymentSheet is not implemented in this build');
    return;
  }
  
  static Future<void> presentPaymentSheet() async {
    debugPrint('Stripe.presentPaymentSheet is not implemented in this build');
    return;
  }
  
  static Future<void> confirmPaymentSheetPayment() async {
    debugPrint('Stripe.confirmPaymentSheetPayment is not implemented in this build');
    return;
  }
}

// Mock other Stripe classes that might be used
class CardFieldInputDetails {
  final bool complete;
  final String? brand;
  final String? number;
  final String? cvc;
  final int? expiryMonth;
  final int? expiryYear;
  final String? last4;
  
  CardFieldInputDetails({
    this.complete = false, 
    this.brand, 
    this.number, 
    this.cvc, 
    this.expiryMonth, 
    this.expiryYear, 
    this.last4
  });
}

class PaymentMethod {
  final String id;
  final String type;
  final BillingDetails? billingDetails;
  final Card? card;
  
  PaymentMethod({
    required this.id, 
    required this.type, 
    this.billingDetails, 
    this.card
  });
}

class BillingDetails {
  final String? email;
  final String? name;
  final String? phone;
  final Address? address;
  
  BillingDetails({this.email, this.name, this.phone, this.address});
}

class Address {
  final String? city;
  final String? country;
  final String? line1;
  final String? line2;
  final String? postalCode;
  final String? state;
  
  Address({
    this.city, 
    this.country, 
    this.line1, 
    this.line2, 
    this.postalCode, 
    this.state
  });
}

class Card {
  final String? brand;
  final String? country;
  final int? expMonth;
  final int? expYear;
  final String? funding;
  final String? last4;
  
  Card({
    this.brand, 
    this.country, 
    this.expMonth, 
    this.expYear, 
    this.funding, 
    this.last4
  });
}