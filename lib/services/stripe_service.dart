import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';
import '../utils/logger.dart';
import 'web_stripe_service.dart';

// We use stripe_stub.dart directly to avoid errors when flutter_stripe package is not available
// This is important for builds where we've disabled the stripe dependency
import './stripe_stub.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  void init() {
    if (kIsWeb) {
      // Use web implementation
      Logger.debug('Initializing Stripe for web');
      WebStripeService().init(publishableKey: AppConfig.stripePublishableKey);
    } else {
      // Use mobile implementation - only initialize Stripe on non-web platforms
      try {
        Stripe.publishableKey = AppConfig.stripePublishableKey;
        Logger.debug('Stripe initialized with publishable key: ${AppConfig.stripePublishableKey.substring(0, 20)}...');
      } catch (e) {
        Logger.error('Error initializing Stripe: $e', error: e);
      }
    }
  }

  // IMPORTANT: In a real production app, you would have a backend server that:
  // 1. Creates payment intents using your secret key
  // 2. Returns the client secret to your mobile app
  // 3. Handles webhooks for payment confirmations
  // 
  // This is a DEMO implementation that simulates those backend calls
  // for portfolio/demonstration purposes.

  Future<Map<String, dynamic>?> createPaymentIntent({
    required String amount,
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // In a real app, this would call your backend server
      // For demo purposes, we'll simulate the response
      Logger.debug('Creating payment intent for amount: $amount $currency');
      
      // Simulate backend processing time
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock payment intent response (this would come from your backend)
      final mockPaymentIntent = {
        'id': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
        'client_secret': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}_secret_mock',
        'amount': int.parse(amount),
        'currency': currency,
        'status': 'requires_payment_method',
        'metadata': metadata ?? {},
      };
      
      Logger.debug('Mock payment intent created: ${mockPaymentIntent['id']}');
      return mockPaymentIntent;
    } catch (error) {
      Logger.error('Error creating payment intent: $error', error: error);
      return null;
    }
  }

  Future<bool> processPayment({
    required String paymentIntentClientSecret,
    required BuildContext context,
  }) async {
    try {
      // For demo purposes, show a simulated payment dialog
      // In a real app, you would use the actual Stripe payment sheet
      Logger.debug('Processing demo Stripe payment with client secret: ${paymentIntentClientSecret.substring(0, 20)}...');
      
      // Show a custom payment simulation dialog with card details
      bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _StripePaymentSimulationDialog(),
      );
      
      return result ?? false;
    } catch (e) {
      Logger.error('Payment processing error: $e', error: e);
      if (context.mounted) {
        _showErrorDialog(context, 'An unexpected error occurred');
      }
      return false;
    }
  }

  Future<String?> createCustomer({
    required String email,
    required String name,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // In a real app, this would call your backend server
      // For demo purposes, we'll simulate the response
      Logger.debug('Creating customer for email: $email');
      
      // Simulate backend processing time
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mock customer ID (this would come from your backend)
      final mockCustomerId = 'cus_mock_${DateTime.now().millisecondsSinceEpoch}';
      
      Logger.debug('Mock customer created: $mockCustomerId');
      return mockCustomerId;
    } catch (error) {
      Logger.error('Error creating customer: $error', error: error);
      return null;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper method to convert amount to cents (Stripe requires amounts in smallest currency unit)
  static String formatAmountForStripe(double amount) {
    return (amount * 100).round().toString();
  }
}

// Demo Stripe Payment Simulation Dialog with Card Details
class _StripePaymentSimulationDialog extends StatefulWidget {
  @override
  State<_StripePaymentSimulationDialog> createState() => _StripePaymentSimulationDialogState();
}

class _StripePaymentSimulationDialogState extends State<_StripePaymentSimulationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();
  
  // State management
  bool _showCardForm = true;
  int _currentStep = 0;
  final List<String> _steps = [
    'Validating card details...',
    'Contacting your bank...',
    'Processing payment...',
    'Payment successful!'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    // Pre-fill with test card details for demo
    _cardNumberController.text = '4242 4242 4242 4242';
    _expiryController.text = '12/25';
    _cvcController.text = '123';
    _nameController.text = 'John Doe';
  }

  void _processPayment() async {
    setState(() {
      _showCardForm = false;
    });

    // Simulate payment processing with steps
    for (int i = 0; i < _steps.length; i++) {
      setState(() {
        _currentStep = i;
      });
      _controller.forward();
      await Future.delayed(Duration(milliseconds: i == _steps.length - 1 ? 1000 : 1200));
      if (i < _steps.length - 1) {
        _controller.reset();
      }
    }
    
    // Close dialog with success
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF635BFF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Stripe Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_showCardForm)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: _showCardForm ? _buildCardForm() : _buildProcessingView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Card number
        _buildTextField(
          controller: _cardNumberController,
          label: 'Card number',
          hint: '1234 1234 1234 1234',
          keyboardType: TextInputType.number,
        ),
        
        const SizedBox(height: 12),
        
        // Expiry and CVC
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _expiryController,
                label: 'MM/YY',
                hint: '12/25',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _cvcController,
                label: 'CVC',
                hint: '123',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Cardholder name
        _buildTextField(
          controller: _nameController,
          label: 'Cardholder name',
          hint: 'John Doe',
          keyboardType: TextInputType.name,
        ),
        
        const SizedBox(height: 20),
        
        // Demo note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo mode: Pre-filled with Stripe test card',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Pay button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF635BFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Pay now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF635BFF)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Processing animation
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              children: [
                LinearProgressIndicator(
                  value: _currentStep == _steps.length - 1 ? 1.0 : _animation.value,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _currentStep == _steps.length - 1 
                      ? Colors.green 
                      : const Color(0xFF635BFF),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _steps[_currentStep],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 30),
        
        // Success message when complete
        if (_currentStep == _steps.length - 1)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Payment completed successfully!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
