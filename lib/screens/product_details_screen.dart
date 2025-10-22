import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  final CartController _cartController = Get.put(CartController());
  final ProductController _productController = Get.put(ProductController());
  
  int _currentImageIndex = 0;
  String? _selectedSize;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Set default size if available
    if (widget.product.sizes?.isNotEmpty == true) {
      _selectedSize = widget.product.sizes!.first;
    } else {
      // If no sizes are specified, create a default "One Size" option
      _selectedSize = "One Size";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're on web and adjust layout accordingly
    final isWeb = MediaQuery.of(context).size.width > 900;
    
    if (isWeb) {
      return _buildWebLayout(context);
    }
    
    return _buildMobileLayout(context);
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: false,
        title: Text(
          'Camora',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          Obx(() {
            bool isInWishlist = _productController.isInWishlist(widget.product.id ?? '');
            return TextButton.icon(
              onPressed: () {
                _productController.toggleWishlist(widget.product.id ?? '');
              },
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist ? Colors.red : Colors.grey[600],
                size: 20,
              ),
              label: Text(
                isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                style: TextStyle(
                  color: isInWishlist ? Colors.red : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
          TextButton.icon(
            onPressed: () {
              Get.snackbar(
                'Share', 
                'Share feature coming soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Theme.of(context).primaryColor,
                colorText: Colors.white,
              );
            },
            icon: Icon(Icons.share, color: Colors.grey[700], size: 20),
            label: Text(
              'Share',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image gallery
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(25),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildWebImageGallery(),
                    ),
                  ),
                ),
                
                const SizedBox(width: 32),
                
                // Right side - Product details
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(25),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWebProductHeader(),
                        const SizedBox(height: 24),
                        _buildRatingSection(),
                        const SizedBox(height: 32),
                        if (widget.product.sizes?.isNotEmpty == true) ...[
                          _buildSizeSelection(),
                          const SizedBox(height: 32),
                        ],
                        _buildQuantitySelection(),
                        const SizedBox(height: 32),
                        _buildWebActionButtons(),
                        const SizedBox(height: 40),
                        _buildDescription(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            pinned: true,
            expandedHeight: 400,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
            actions: [
              Obx(() {
                bool isInWishlist = _productController.isInWishlist(widget.product.id ?? '');
                return IconButton(
                  onPressed: () {
                    _productController.toggleWishlist(widget.product.id ?? '');
                  },
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : Colors.grey[600],
                  ),
                );
              }),
              IconButton(
                onPressed: () {
                  // Simple share functionality
                  Get.snackbar(
                    'Share', 
                    'Share feature coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          
          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  _buildProductHeader(),
                  const SizedBox(height: 16),
                  
                  // Rating and Reviews
                  _buildRatingSection(),
                  const SizedBox(height: 24),
                  
                  // Size Selection
                  if (widget.product.sizes?.isNotEmpty == true) ...[
                    _buildSizeSelection(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Quantity Selection
                  _buildQuantitySelection(),
                  const SizedBox(height: 24),
                  
                  // Description
                  _buildDescription(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildWebImageGallery() {
    return Column(
      children: [
        // Main image
        SizedBox(
          height: 500,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.product.images?.length ?? 0,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.product.images?[index] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.error, size: 48),
                ),
              );
            },
          ),
        ),
        
        // Thumbnail images
        if ((widget.product.images?.length ?? 0) > 1)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (widget.product.images?.length ?? 0).clamp(0, 5),
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentImageIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: _currentImageIndex == index ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.images?[index] ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWebProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name ?? 'Product',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '\$${widget.product.price?.toStringAsFixed(2) ?? '0.00'}',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWebActionButtons() {
    final canAddToCart = _selectedSize != null && 
        (widget.product.stock ?? 10) >= _quantity;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canAddToCart ? () {
              print("Web layout: Buy Now pressed - navigating to checkout");
              // Clear cart and add only this item for Buy Now
              _cartController.clearCart();
              _cartController.addToCart(
                widget.product,
                _selectedSize!,
                _quantity,
              );
              Get.to(() => const CheckoutScreen());
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAddToCart 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: canAddToCart ? 2 : 0,
            ),
            child: Text(
              'Buy Now - \$${widget.product.price?.toStringAsFixed(2) ?? '0.00'}',
              style: TextStyle(
                color: canAddToCart ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: canAddToCart ? () {
              _cartController.addToCart(
                widget.product,
                _selectedSize!,
                _quantity,
              );
              Get.snackbar(
                'Added to Cart',
                '${widget.product.name} has been added to your cart',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            } : null,
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: canAddToCart ? Theme.of(context).primaryColor : Colors.grey[400],
            ),
            label: Text(
              'Add to Cart',
              style: TextStyle(
                color: canAddToCart ? Theme.of(context).primaryColor : Colors.grey[400],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: canAddToCart 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300]!,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: widget.product.images?.length ?? 0,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.product.images?[index] ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            );
          },
        ),
        
        // Image Indicators
        if ((widget.product.images?.length ?? 0) > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.product.images?.length ?? 0,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name ?? 'Product',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${widget.product.price?.toStringAsFixed(2) ?? '0.00'}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < (widget.product.rating?.floor() ?? 0)
                ? Icons.star
                : index < (widget.product.rating ?? 0)
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: 20,
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${widget.product.rating?.toStringAsFixed(1) ?? '0.0'} (${widget.product.reviewCount ?? 0} reviews)',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelection() {
    // If no sizes are available, display a "One Size" option
    List<String> sizes = widget.product.sizes?.isNotEmpty == true 
        ? widget.product.sizes!
        : ["One Size"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: sizes.map((size) {
            final isSelected = _selectedSize == size;
            final stock = widget.product.stock ?? 1; // Default to 1 if stock not specified
            final isAvailable = stock > 0;
            
            return GestureDetector(
              onTap: isAvailable ? () {
                setState(() {
                  _selectedSize = size;
                });
              } : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isAvailable
                            ? Colors.grey[300]!
                            : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : isAvailable
                          ? Colors.white
                          : Colors.grey[100],
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isAvailable
                            ? Colors.black87
                            : Colors.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelection() {
    final maxStock = _selectedSize != null 
        ? widget.product.stock ?? 10 // Default to 10 if stock not specified
        : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _quantity > 1 ? () {
                setState(() {
                  _quantity--;
                });
              } : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _quantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: _quantity < maxStock ? () {
                setState(() {
                  _quantity++;
                });
              } : null,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              widget.product.stock != null ? 'Stock: $maxStock' : 'In Stock',
              style: TextStyle(
                color: maxStock > 0 ? Colors.green[600] : Colors.grey[600],
                fontSize: 14,
                fontWeight: maxStock > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.description ?? 'No description available.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    // Always enable buttons if a size is selected (default to "One Size" if needed)
    final canAddToCart = _selectedSize != null && 
        (widget.product.stock ?? 10) >= _quantity;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canAddToCart ? () {
                _cartController.addToCart(
                  widget.product,
                  _selectedSize!,
                  _quantity,
                );
                Get.snackbar(
                  'Added to Cart',
                  '${widget.product.name} has been added to your cart',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } : null,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to Cart'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: canAddToCart 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey[300]!,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: canAddToCart ? () {
                print("Buy Now pressed - navigating to checkout");
                // Clear cart and add only this item for Buy Now
                _cartController.clearCart();
                _cartController.addToCart(
                  widget.product,
                  _selectedSize!,
                  _quantity,
                );
                Get.to(() => const CheckoutScreen());
              } : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: canAddToCart 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
