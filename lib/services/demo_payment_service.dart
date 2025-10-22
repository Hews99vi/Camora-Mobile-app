import 'dart:math';
import 'package:flutter/material.dart';

class DemoPaymentService {
  static final DemoPaymentService _instance = DemoPaymentService._internal();
  factory DemoPaymentService() => _instance;
  DemoPaymentService._internal();

  // Simulate payment processing with random success/failure for demo
  Future<Map<String, dynamic>> simulatePayment({
    required double amount,
    required String customerName,
    required String customerEmail,
    Map<String, dynamic>? metadata,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate fake payment intent ID
    final paymentIntentId = 'pi_demo_${_generateRandomId()}';
    
    // Simulate payment processing dialog
    return {
      'success': true, // Always succeed in demo mode
      'paymentIntentId': paymentIntentId,
      'amount': (amount * 100).round(), // Convert to cents
      'currency': 'usd',
      'status': 'succeeded',
      'customer': {
        'name': customerName,
        'email': customerEmail,
      },
      'metadata': metadata ?? {},
    };
  }

  Future<bool> showDemoPaymentDialog(BuildContext context, double amount) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DemoPaymentDialog(amount: amount),
    ) ?? false;
  }

  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(24, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}

class _DemoPaymentDialog extends StatefulWidget {
  final double amount;

  const _DemoPaymentDialog({required this.amount});

  @override
  State<_DemoPaymentDialog> createState() => _DemoPaymentDialogState();
}

class _DemoPaymentDialogState extends State<_DemoPaymentDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isProcessing = true;
  bool _paymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _simulatePaymentProcess();
  }

  void _simulatePaymentProcess() async {
    _animationController.repeat();
    
    // Simulate payment processing time
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
    });
    
    _animationController.stop();
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isProcessing) ...[
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 2 * 3.14159,
                  child: const Icon(
                    Icons.credit_card,
                    size: 64,
                    color: Colors.blue,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Processing Payment...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Demo Mode - No real payment is being processed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ] else if (_paymentSuccess) ...[
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${widget.amount.toStringAsFixed(2)} charged successfully',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: const Text(
                '⚠️ DEMO MODE: This is a simulated payment',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
      actions: _paymentSuccess
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue'),
              ),
            ]
          : null,
    );
  }
}
