import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import '../controllers/product_controller.dart';
import '../utils/responsive.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final RxInt _currentIndex = 0.obs;
  final ProductController _productController = Get.find<ProductController>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Use responsive layout for web on desktop screens
    final bool useWebLayout = kIsWeb && Responsive.isDesktop(context);
    
    if (useWebLayout) {
      return _buildWebLayout(context);
    }
    
    return _buildMobileLayout(context);
  }
  
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side navigation rail
          Obx(() => NavigationRail(
            selectedIndex: _currentIndex.value,
            onDestinationSelected: (index) => _currentIndex.value = index,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            elevation: 1,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            unselectedIconTheme: const IconThemeData(
              color: Colors.grey,
              size: 24,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Camora',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: Text('Categories'),
              ),
              NavigationRailDestination(
                icon: Badge(
                  isLabelVisible: _productController.wishlistIds.isNotEmpty,
                  label: Text('${_productController.wishlistIds.length}'),
                  child: const Icon(Icons.favorite_border),
                ),
                selectedIcon: Badge(
                  isLabelVisible: _productController.wishlistIds.isNotEmpty,
                  label: Text('${_productController.wishlistIds.length}'),
                  child: const Icon(Icons.favorite),
                ),
                label: const Text('Wishlist'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Chat'),
              ),
            ],
          )),
          
          // Vertical divider
          const VerticalDivider(thickness: 1, width: 1),
          
          // Main content area
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: Obx(() => _screens[_currentIndex.value]),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: Obx(() => _screens[_currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _currentIndex.value,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(
                    _productController.wishlistIds.isNotEmpty 
                        ? Icons.favorite 
                        : Icons.favorite_border,
                    color: _currentIndex.value == 2 
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  if (_productController.wishlistIds.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${_productController.wishlistIds.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Wishlist',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
          ],
          onTap: (index) => _currentIndex.value = index,
        ),
      ),
    );
  }
}
