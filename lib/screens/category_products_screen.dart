import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as search_ctrl;
import '../widgets/product_card_v2.dart';
import '../utils/responsive.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  
  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late final search_ctrl.SearchController searchController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController = Get.put(search_ctrl.SearchController(), tag: widget.categoryName);
    
    // Set the category filter when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a delay to ensure the controller is fully initialized
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && searchController.availableCategories.contains(widget.categoryName)) {
          searchController.updateCategory(widget.categoryName);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.withValues(alpha: 0.1),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: false,
        actions: [
          Obx(() {
            final products = searchController.filteredProducts;
            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: Center(
                child: products.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${products.length} items',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar for this category
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => searchController.updateSearchQuery(value),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.categoryName.toLowerCase()}...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  suffixIcon: Obx(() {
                    final query = searchController.searchQuery;
                    return query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                              searchController.updateSearchQuery('');
                            },
                          )
                        : const SizedBox();
                  }),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ),

            // Category Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[100]!, Colors.grey[200]!], // Light grey colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(widget.categoryName),
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.categoryName} Collection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Obx(() {
                          final products = searchController.filteredProducts;
                          return Text(
                            'Discover ${products.length} amazing products',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Products Grid
            Expanded(
              child: Obx(() {
                final products = searchController.filteredProducts;
                
                if (products.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFFEEEEEE), const Color(0xFFF5F5F5)], // Light grey colors
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(widget.categoryName),
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No ${widget.categoryName} Found',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'re currently updating our ${widget.categoryName.toLowerCase()} collection.\nCheck back soon for new arrivals!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Responsive grid with max-width constraint
                final crossAxisCount = Responsive.value<int>(
                  context: context,
                  mobile: 2,
                  tablet: 3,
                  desktop: 4,
                );
                
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.isDesktop(context) ? 1400.0 : double.infinity,
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(Responsive.isDesktop(context) ? 20 : 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.72, // Same as image search to avoid overflow
                        crossAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                        mainAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCardV2(
                          product: product,
                          onTap: () {
                            Get.to(() => ProductDetailsScreen(product: product));
                          },
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cameras':
        return Icons.camera_alt_rounded;
      case 'lenses':
        return Icons.camera_rounded;
      case 'tripods':
        return Icons.settings_input_component_rounded;
      case 'lighting':
        return Icons.flashlight_on_rounded;
      case 'accessories':
        return Icons.camera_enhance_rounded;
      case 'drones':
        return Icons.flight_rounded;
      case 'storage':
        return Icons.sd_card_rounded;
      case 'bags':
        return Icons.backpack_rounded;
      default:
        return Icons.photo_camera_rounded;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Safely dispose the search controller
    try {
      Get.delete<search_ctrl.SearchController>(tag: widget.categoryName);
    } catch (e) {
      // Controller may already be disposed
      debugPrint('Controller already disposed: $e');
    }
    super.dispose();
  }
}