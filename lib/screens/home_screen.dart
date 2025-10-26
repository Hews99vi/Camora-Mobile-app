import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../widgets/product_card_v2.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/best_selling_section.dart';
import '../widgets/designer_categories_section.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../utils/responsive.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    'All',
    'Cameras',
    'Lenses',
    'Tripods',
    'Lighting',
    'Accessories'
  ];

  int _selectedCategoryIndex = 0;
  final ProductController productController = Get.find();
  final CartController cartController = Get.put(CartController());

  List<Product> get filteredProducts {
    if (_selectedCategoryIndex == 0) {
      return productController.products;
    }
    final selectedCategory = categories[_selectedCategoryIndex];
    return productController.products
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Constrain content width on desktop for better proportions
    final maxWidth = Responsive.isDesktop(context) ? 1400.0 : double.infinity;
    
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.grey.withValues(alpha: 0.1),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'CM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Camora',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Camera & Accessories',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const SearchScreen());
                  },
                ),
              ),

              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        Obx(() {
                          final itemCount = cartController.itemCount;
                          if (itemCount == 0) return const SizedBox.shrink();
                          
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                itemCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const CartScreen());
                  },
                ),
              ),
            ],
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: HeroCarousel(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 32),
              child: BestSellingSection(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: Responsive.isDesktop(context) ? 0 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Shop by Category',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.black : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    categories[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[700],
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Products Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedCategoryIndex == 0
                            ? 'All Products'
                            : categories[_selectedCategoryIndex],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Obx(() => Text(
                    '${filteredProducts.length} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isDesktop(context) ? 20 : 16,
              vertical: 8,
            ),
            sliver: Obx(() {
              // Responsive grid: more columns on larger screens
              final crossAxisCount = Responsive.value<int>(
                context: context,
                mobile: 2,
                tablet: 3,
                desktop: 4,
              );
              
              return SliverMasonryGrid.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                crossAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                childCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCardV2(
                    product: filteredProducts[index],
                    onTap: () {
                      Get.to(() => ProductDetailsScreen(product: filteredProducts[index]));
                    },
                  );
                },
              );
            }),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: DesignerCategoriesSection(),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
