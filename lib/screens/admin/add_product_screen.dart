import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final ProductController productController = Get.find();
  final CategoryController categoryController = Get.put(CategoryController());

  final TextEditingController _stockController = TextEditingController();
  String? _selectedCategory;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name ?? '';
    _descriptionController.text = product.description ?? '';
    _priceController.text = (product.price ?? 0.0).toString();
    _selectedCategory = product.category;
    _stockController.text = (product.stock ?? 0).toString();
    
    if (product.images != null && product.images!.isNotEmpty) {
      _imageUrlController.text = product.images!.first;
    }
  }
  
  // Color utilities now moved to ColorUtils class

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      Get.snackbar('Error', 'Please select a category');
      return;
    }

    final product = Product(
      id: isEditing ? widget.product!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      images: _imageUrlController.text.isNotEmpty ? [_imageUrlController.text] : [],
      category: _selectedCategory!,
      stock: int.tryParse(_stockController.text) ?? 0,
      rating: isEditing ? widget.product!.rating : 0.0,
      reviewCount: isEditing ? widget.product!.reviewCount : 0,
    );

    try {
      bool success;
      if (isEditing) {
        success = await productController.updateProduct(product);
      } else {
        success = await productController.addProduct(product);
      }

      if (success) {
        // Show a success snackbar with a delay to ensure it's visible after navigation
        Get.back();
        Future.delayed(Duration(milliseconds: 300), () {
          Get.snackbar(
            'Success', 
            isEditing ? 'Product updated successfully' : 'Product added successfully',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      } else {
        // If the operation returned false but didn't throw an exception
        Get.snackbar(
          'Error',
          'Operation failed. Please check your Firebase configuration.',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      String errorMessage;
      
      if (e.toString().contains('database') && e.toString().contains('does not exist')) {
        errorMessage = 'Firebase database is not set up. Please configure your Firebase project.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = 'Failed to ${isEditing ? 'update' : 'add'} product: ${e.toString()}';
      }
      
      Get.snackbar(
        'Error', 
        errorMessage,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Loading indicator in app bar
          Obx(() => productController.isLoading 
            ? Container(
                margin: const EdgeInsets.only(right: 16),
                child: const Center(
                  child: SizedBox(
                    height: 20, 
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ) 
            : Container()
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (\$)',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            Obx(() {
              if (categoryController.categories.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No categories available. Please create categories first.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to category management
                              Get.toNamed('/admin/categories');
                            },
                            child: const Text('Add Categories'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select a category'),
                items: categoryController.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 16),

            // Image URL
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                border: OutlineInputBorder(),
                hintText: 'https://example.com/image.jpg',
              ),
            ),
            const SizedBox(height: 16),

            // Stock
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter stock quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Save button
            Obx(
              () => ElevatedButton(
                onPressed: productController.isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: productController.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Product' : 'Add Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
