import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/stripe_service.dart';
import '../utils/logger.dart';
import '../services/demo_payment_service.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class PaymentController extends GetxController {
  final StripeService _stripeService = StripeService();
  final DemoPaymentService _demoPaymentService = DemoPaymentService();
  
  var isProcessingPayment = false.obs;
  var paymentSuccess = false.obs;
  var paymentIntentId = ''.obs;

  // Demo mode flag - set to true for demonstration
  static const bool isDemoMode = true;

  @override
  void onInit() {
    super.onInit();
    if (!isDemoMode) {
      _stripeService.init();
    }
  }

  Future<bool> processPayment({
    required List<CartItem> cartItems,
    required String customerEmail,
    required String customerName,
    required ShippingAddress shippingAddress,
    required BuildContext context,
  }) async {
    try {
      isProcessingPayment.value = true;
      
      // Calculate total amount
      double totalAmount = cartItems.fold(0.0, 
        (sum, item) => sum + ((item.price ?? 0.0) * (item.quantity ?? 0)));

      if (isDemoMode) {
        // Use demo payment service
        bool success = await _demoPaymentService.showDemoPaymentDialog(context, totalAmount);
        
        if (success) {
          // Generate fake payment intent for demo
          final demoPayment = await _demoPaymentService.simulatePayment(
            amount: totalAmount,
            customerName: customerName,
            customerEmail: customerEmail,
            metadata: {
              'shipping_address': '${shippingAddress.address}, ${shippingAddress.city}, ${shippingAddress.zipCode}',
            },
          );
          
          paymentIntentId.value = demoPayment['paymentIntentId'];
          paymentSuccess.value = true;
          
          Get.snackbar(
            'Demo Payment Successful',
            'Your demo payment has been processed! (No real money charged)',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
        
        return success;
      } else {
        // Use real Stripe service
        // Create customer in Stripe (optional, for better customer management)
        String? customerId = await _stripeService.createCustomer(
          email: customerEmail,
          name: customerName,
          metadata: {
            'shipping_address': '${shippingAddress.address}, ${shippingAddress.city}, ${shippingAddress.zipCode}',
          },
        );

        // Create payment intent
        Map<String, dynamic>? paymentIntent = await _stripeService.createPaymentIntent(
          amount: StripeService.formatAmountForStripe(totalAmount),
          currency: 'usd', // Change to your preferred currency
          customerId: customerId,
          metadata: {
            'customer_name': customerName,
            'customer_email': customerEmail,
            'shipping_address': '${shippingAddress.address}, ${shippingAddress.city}',
            'items_count': cartItems.length.toString(),
          },
        );

        if (paymentIntent == null) {
          throw Exception('Failed to create payment intent');
        }

        paymentIntentId.value = paymentIntent['id'];

        // Store context reference before async operation
        if (!context.mounted) return false;

        // Process the payment
        bool success = await _stripeService.processPayment(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          context: context,
        );

        if (success) {
          paymentSuccess.value = true;
          if (context.mounted) {
            Get.snackbar(
              'Payment Successful',
              'Your payment has been processed successfully!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          }
        }

        return success;
      }
    } catch (e) {
      Logger.error('Payment error: $e', error: e);
      Get.snackbar(
        'Payment Failed',
        'Failed to process payment: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  void resetPaymentState() {
    paymentSuccess.value = false;
    paymentIntentId.value = '';
    isProcessingPayment.value = false;
  }
}
