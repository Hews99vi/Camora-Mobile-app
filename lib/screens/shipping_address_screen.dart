import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/shipping_address.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shipping Addresses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black87,
          size: 24,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
          color: Colors.black87,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAddressDialog(),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser;
        if (user == null) {
          return const Center(child: Text('Please log in to manage addresses'));
        }

        if (user.shippingAddresses == null || user.shippingAddresses!.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: user.shippingAddresses!.length,
          itemBuilder: (context, index) {
            final address = user.shippingAddresses![index];
            final isDefault = address.id == user.defaultShippingAddressId;
            return _buildAddressCard(address, isDefault);
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
            Icons.location_on_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Addresses Added',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a shipping address to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddAddressDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ShippingAddress address, bool isDefault) {
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
                Expanded(
                  child: Text(
                    address.name ?? 'No Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
              address.fullAddress,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (address.phoneNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                'Phone: ${address.phoneNumber}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isDefault)
                  TextButton.icon(
                    onPressed: () => _setAsDefault(address),
                    icon: const Icon(Icons.star_outline, size: 16),
                    label: const Text('Set as Default'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showEditAddressDialog(address),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _deleteAddress(address),
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

  void _showAddAddressDialog() {
    _showAddressDialog();
  }

  void _showEditAddressDialog(ShippingAddress address) {
    _showAddressDialog(address: address);
  }

  void _showAddressDialog({ShippingAddress? address}) {
    final isEditing = address != null;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AddressFormScreen(
          address: address,
          isEditing: isEditing,
          onSave: (newAddress) => _saveAddress(
            address,
            newAddress.name,
            newAddress.street,
            newAddress.city,
            newAddress.state,
            newAddress.zipCode,
            newAddress.country,
            newAddress.phoneNumber,
          ),
        ),
      ),
    );
  }

  void _saveAddress(ShippingAddress? existingAddress, String? name, String? street,
      String? city, String? state, String? zip, String? country, String? phone) {
    final newAddress = ShippingAddress(
      id: existingAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      street: street,
      city: city,
      state: state,
      zipCode: zip,
      country: country,
      phoneNumber: phone,
      isDefault: existingAddress?.isDefault ?? false,
      createdAt: existingAddress?.createdAt ?? DateTime.now(),
    );

    // Update user's shipping addresses
    final user = authController.currentUser!;
    List<ShippingAddress> updatedAddresses = List.from(user.shippingAddresses ?? []);
    
    if (existingAddress != null) {
      final index = updatedAddresses.indexWhere((a) => a.id == existingAddress.id);
      if (index != -1) {
        updatedAddresses[index] = newAddress;
      }
    } else {
      updatedAddresses.add(newAddress);
      // If this is the first address, make it default
      if (updatedAddresses.length == 1) {
        updatedAddresses[0] = newAddress.copyWith(isDefault: true);
        authController.updateProfile(user.copyWith(
          shippingAddresses: updatedAddresses,
          defaultShippingAddressId: newAddress.id,
        ));
        return;
      }
    }

    authController.updateProfile(user.copyWith(shippingAddresses: updatedAddresses));
    
    Get.snackbar(
      'Success',
      existingAddress != null ? 'Address updated successfully' : 'Address added successfully',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[700],
    );
  }

  void _setAsDefault(ShippingAddress address) {
    final user = authController.currentUser!;
    List<ShippingAddress> updatedAddresses = (user.shippingAddresses ?? [])
        .map((a) => a.copyWith(isDefault: a.id == address.id))
        .toList();

    authController.updateProfile(user.copyWith(
      shippingAddresses: updatedAddresses,
      defaultShippingAddressId: address.id,
    ));

    Get.snackbar(
      'Success',
      'Default address updated',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[700],
    );
  }

  void _deleteAddress(ShippingAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final user = authController.currentUser!;
              List<ShippingAddress> updatedAddresses = (user.shippingAddresses ?? [])
                  .where((a) => a.id != address.id)
                  .toList();

              String? newDefaultId = user.defaultShippingAddressId;
              if (address.id == user.defaultShippingAddressId) {
                newDefaultId = updatedAddresses.isNotEmpty ? updatedAddresses.first.id : null;
                if (newDefaultId != null) {
                  updatedAddresses = updatedAddresses
                      .map((a) => a.id == newDefaultId ? a.copyWith(isDefault: true) : a)
                      .toList();
                }
              }

              authController.updateProfile(user.copyWith(
                shippingAddresses: updatedAddresses,
                defaultShippingAddressId: newDefaultId,
              ));

              Navigator.of(context).pop();
              Get.snackbar(
                'Success',
                'Address deleted successfully',
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

class _AddressFormScreen extends StatefulWidget {
  final ShippingAddress? address;
  final bool isEditing;
  final Function(ShippingAddress) onSave;

  const _AddressFormScreen({
    this.address,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<_AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<_AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _zipController = TextEditingController(text: widget.address?.zipCode ?? '');
    _countryController = TextEditingController(text: widget.address?.country ?? 'United States');
    _phoneController = TextEditingController(text: widget.address?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveAddress,
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
                        Icons.location_on,
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
                            widget.isEditing ? 'Update Address' : 'New Address',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please fill in all the required information',
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
              
              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number (Optional)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 32),
              
              // Address Information Section
              _buildSectionHeader('Address Information'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _streetController,
                label: 'Street Address',
                icon: Icons.home_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateController,
                      label: 'State',
                      icon: Icons.map_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _zipController,
                      label: 'ZIP Code',
                      icon: Icons.local_post_office_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ZIP code';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _countryController,
                      label: 'Country',
                      icon: Icons.public_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter country';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveAddress,
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
                        widget.isEditing ? Icons.update : Icons.add_location_alt,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isEditing ? 'Update Address' : 'Save Address',
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
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
      ),
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = ShippingAddress(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        country: _countryController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        isDefault: widget.address?.isDefault ?? false,
        createdAt: widget.address?.createdAt ?? DateTime.now(),
      );

      widget.onSave(newAddress);
      Navigator.of(context).pop();
    }
  }
}
