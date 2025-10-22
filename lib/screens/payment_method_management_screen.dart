import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/payment_method.dart';

class PaymentMethodManagementScreen extends StatefulWidget {
  const PaymentMethodManagementScreen({super.key});

  @override
  State<PaymentMethodManagementScreen> createState() => _PaymentMethodManagementScreenState();
}

class _PaymentMethodManagementScreenState extends State<PaymentMethodManagementScreen> {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 18,
            ),
            onPressed: () => Get.back(),
            color: Colors.black87,
            padding: EdgeInsets.zero,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPaymentMethodDialog(),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser;
        if (user == null) {
          return const Center(child: Text('Please log in to manage payment methods'));
        }

        if (user.paymentMethods == null || user.paymentMethods!.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: user.paymentMethods!.length,
          itemBuilder: (context, index) {
            final paymentMethod = user.paymentMethods![index];
            final isDefault = paymentMethod.id == user.defaultPaymentMethodId;
            return _buildPaymentMethodCard(paymentMethod, isDefault);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Methods',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a payment method to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddPaymentMethodDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Add Payment Method'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod paymentMethod, bool isDefault) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _getCardIcon(paymentMethod.brand ?? 'unknown'),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentMethod.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Expires ${paymentMethod.expiryDisplay}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              paymentMethod.holderName ?? 'Card Holder',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isDefault)
                  TextButton.icon(
                    onPressed: () => _setAsDefault(paymentMethod),
                    icon: const Icon(Icons.star_outline, size: 16),
                    label: const Text('Set as Default'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showEditPaymentMethodDialog(paymentMethod),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _deletePaymentMethod(paymentMethod),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      case 'mastercard':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'MC',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      case 'amex':
      case 'american_express':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'AMEX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        );
      default:
        return Icon(
          Icons.credit_card,
          color: Colors.grey[600],
          size: 32,
        );
    }
  }

  void _showAddPaymentMethodDialog() {
    _showPaymentMethodDialog();
  }

  void _showEditPaymentMethodDialog(PaymentMethod paymentMethod) {
    _showPaymentMethodDialog(paymentMethod: paymentMethod);
  }

  void _showPaymentMethodDialog({PaymentMethod? paymentMethod}) {
    final isEditing = paymentMethod != null;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PaymentMethodFormScreen(
          paymentMethod: paymentMethod,
          isEditing: isEditing,
          onSave: (newPaymentMethod) => _savePaymentMethod(
            paymentMethod,
            newPaymentMethod.holderName,
            newPaymentMethod.last4,
            newPaymentMethod.brand,
            newPaymentMethod.expiryMonth,
            newPaymentMethod.expiryYear,
          ),
        ),
      ),
    );
  }

  void _savePaymentMethod(PaymentMethod? existingPaymentMethod, String? holderName, 
      String? cardNumber, String? brand, int? expiryMonth, int? expiryYear) {
    // For editing, we only update the last 4 digits if new number is provided
    String? last4 = cardNumber != null && cardNumber.length >= 4 
                  ? cardNumber.substring(cardNumber.length - 4) 
                  : cardNumber;
    
    final newPaymentMethod = PaymentMethod(
      id: existingPaymentMethod?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authController.currentUser?.id,
      last4: last4,
      brand: brand,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      holderName: holderName,
      isDefault: existingPaymentMethod?.isDefault ?? false,
      createdAt: existingPaymentMethod?.createdAt ?? DateTime.now(),
    );

    // Update user's payment methods
    final user = authController.currentUser!;
    List<PaymentMethod> updatedPaymentMethods = user.paymentMethods != null 
        ? List.from(user.paymentMethods!) 
        : [];
    
    if (existingPaymentMethod != null) {
      final index = updatedPaymentMethods.indexWhere((pm) => pm.id == existingPaymentMethod.id);
      if (index != -1) {
        updatedPaymentMethods[index] = newPaymentMethod;
      }
    } else {
      updatedPaymentMethods.add(newPaymentMethod);
      // If this is the first payment method, make it default
      if (updatedPaymentMethods.length == 1) {
        updatedPaymentMethods[0] = newPaymentMethod.copyWith(isDefault: true);
        authController.updateProfile(user.copyWith(
          paymentMethods: updatedPaymentMethods,
          defaultPaymentMethodId: newPaymentMethod.id,
        ));
        return;
      }
    }

    authController.updateProfile(user.copyWith(paymentMethods: updatedPaymentMethods));
    
    Get.snackbar(
      'Success',
      existingPaymentMethod != null ? 'Payment method updated successfully' : 'Payment method added successfully',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[700],
    );
  }

  void _setAsDefault(PaymentMethod paymentMethod) {
    final user = authController.currentUser!;
    List<PaymentMethod> updatedPaymentMethods = user.paymentMethods != null
        ? user.paymentMethods!.map((pm) => pm.copyWith(isDefault: pm.id == paymentMethod.id)).toList()
        : [];

    authController.updateProfile(user.copyWith(
      paymentMethods: updatedPaymentMethods,
      defaultPaymentMethodId: paymentMethod.id,
    ));

    Get.snackbar(
      'Success',
      'Default payment method updated',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[700],
    );
  }

  void _deletePaymentMethod(PaymentMethod paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final user = authController.currentUser!;
              List<PaymentMethod> updatedPaymentMethods = user.paymentMethods != null
                  ? user.paymentMethods!.where((pm) => pm.id != paymentMethod.id).toList()
                  : [];

              String? newDefaultId = user.defaultPaymentMethodId;
              if (paymentMethod.id == user.defaultPaymentMethodId) {
                newDefaultId = updatedPaymentMethods.isNotEmpty ? updatedPaymentMethods.first.id : null;
                if (newDefaultId != null) {
                  updatedPaymentMethods = updatedPaymentMethods
                      .map((pm) => pm.id == newDefaultId ? pm.copyWith(isDefault: true) : pm)
                      .toList();
                }
              }

              authController.updateProfile(user.copyWith(
                paymentMethods: updatedPaymentMethods,
                defaultPaymentMethodId: newDefaultId,
              ));

              Navigator.of(context).pop();
              Get.snackbar(
                'Success',
                'Payment method deleted successfully',
                backgroundColor: Colors.green[100],
                colorText: Colors.green[700],
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodFormScreen extends StatefulWidget {
  final PaymentMethod? paymentMethod;
  final bool isEditing;
  final Function(PaymentMethod) onSave;

  const _PaymentMethodFormScreen({
    this.paymentMethod,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<_PaymentMethodFormScreen> createState() => _PaymentMethodFormScreenState();
}

class _PaymentMethodFormScreenState extends State<_PaymentMethodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _holderNameController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryMonthController;
  late final TextEditingController _expiryYearController;
  late String _selectedBrand;

  @override
  void initState() {
    super.initState();
    _holderNameController = TextEditingController(text: widget.paymentMethod?.holderName ?? '');
    _cardNumberController = TextEditingController(text: widget.paymentMethod?.last4 ?? '');
    _expiryMonthController = TextEditingController(text: widget.paymentMethod?.expiryMonth?.toString() ?? '');
    _expiryYearController = TextEditingController(text: widget.paymentMethod?.expiryYear?.toString() ?? '');
    _selectedBrand = widget.paymentMethod?.brand ?? 'visa';
  }

  @override
  void dispose() {
    _holderNameController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Payment Method' : 'Add Payment Method',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 18,
            ),
            onPressed: () => Get.back(),
            color: Colors.black87,
            padding: EdgeInsets.zero,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _savePaymentMethod,
            child: Text(
              widget.isEditing ? 'Update' : 'Save',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing ? 'Update Payment Method' : 'New Payment Method',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your payment information is secure and encrypted',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Cardholder Information
              _buildSectionHeader('Cardholder Information'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _holderNameController,
                label: 'Cardholder Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Card Information
              _buildSectionHeader('Card Information'),
              const SizedBox(height: 16),
              
              // Card Brand Selection
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                decoration: InputDecoration(
                  labelText: 'Card Brand',
                  prefixIcon: Icon(Icons.credit_card, color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: ['visa', 'mastercard', 'amex', 'discover']
                    .map((brand) => DropdownMenuItem(
                          value: brand,
                          child: Row(
                            children: [
                              _getBrandIcon(brand),
                              const SizedBox(width: 12),
                              Text(brand.toUpperCase()),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedBrand = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _cardNumberController,
                label: widget.isEditing ? 'Last 4 Digits' : 'Card Number',
                icon: Icons.credit_card_outlined,
                keyboardType: TextInputType.number,
                maxLength: widget.isEditing ? 4 : 16,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.isEditing ? 'Please enter last 4 digits' : 'Please enter card number';
                  }
                  if (widget.isEditing && value.length != 4) {
                    return 'Please enter 4 digits';
                  }
                  if (!widget.isEditing && value.length < 13) {
                    return 'Please enter valid card number';
                  }
                  return null;
                },
                helperText: widget.isEditing ? 'Only last 4 digits for security' : null,
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _expiryMonthController,
                      label: 'Month (MM)',
                      icon: Icons.calendar_month,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final month = int.tryParse(value);
                        if (month == null || month < 1 || month > 12) {
                          return 'Invalid month';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _expiryYearController,
                      label: 'Year (YY)',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 0 || year > 99) {
                          return 'Invalid year';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your payment information is encrypted and stored securely',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _savePaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isEditing ? Icons.update : Icons.add_card,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isEditing ? 'Update Payment Method' : 'Save Payment Method',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLength,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: Colors.black),
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        counterText: '', // Hide character counter
      ),
    );
  }

  Widget _getBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        );
      case 'mastercard':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'MC',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        );
      case 'amex':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'AMEX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 8,
            ),
          ),
        );
      default:
        return Icon(Icons.credit_card, color: Colors.grey[600], size: 16);
    }
  }

  void _savePaymentMethod() {
    if (_formKey.currentState!.validate()) {
      // For editing, we only update the last 4 digits if new number is provided
      String last4 = _cardNumberController.text.length >= 4 
          ? _cardNumberController.text.substring(_cardNumberController.text.length - 4) 
          : _cardNumberController.text;
      
      final newPaymentMethod = PaymentMethod(
        id: widget.paymentMethod?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.paymentMethod?.userId,
        last4: last4,
        brand: _selectedBrand,
        expiryMonth: int.tryParse(_expiryMonthController.text.padLeft(2, '0')),
        expiryYear: int.tryParse(_expiryYearController.text.padLeft(2, '0')),
        holderName: _holderNameController.text,
        isDefault: widget.paymentMethod?.isDefault ?? false,
        createdAt: widget.paymentMethod?.createdAt ?? DateTime.now(),
      );

      widget.onSave(newPaymentMethod);
      Navigator.of(context).pop();
    }
  }
}
