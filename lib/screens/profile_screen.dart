import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'shipping_address_screen.dart';
import 'payment_method_management_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Obx(() {
        if (!authController.isLoggedIn) {
          return _buildGuestView();
        }
        return _buildLoggedInView(authController);
      }),
    );
  }

  Widget _buildGuestView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.pink,
          child: Icon(
            Icons.person,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Guest User',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Sign in to access your profile, orders, and preferences.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Get.to(() => const LoginScreen());
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInView(AuthController authController) {
    final user = authController.currentUser!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Avatar and Info
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(Get.context!).primaryColor,
          child: Text(
            user.name?.isNotEmpty == true && user.name != null ? user.name![0].toUpperCase() : 'U',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name ?? 'User',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? 'No email provided',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        if (user.role == UserRole.admin) ...[
          const SizedBox(height: 8),
          Container(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),

        // Menu Items
        _buildMenuItem(
          icon: Icons.shopping_bag,
          title: 'My Orders',
          onTap: () {
            Get.to(() => const OrderHistoryScreen());
          },
        ),
        _buildMenuItem(
          icon: Icons.location_on,
          title: 'Shipping Addresses',
          onTap: () {
            Get.to(() => const ShippingAddressScreen());
          },
        ),
        _buildMenuItem(
          icon: Icons.payment,
          title: 'Payment Methods',
          onTap: () {
            Get.to(() => const PaymentMethodManagementScreen());
          },
        ),
        _buildMenuItem(
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () {
            Get.snackbar('Coming Soon', 'Notification settings will be available soon!');
          },
        ),
        _buildMenuItem(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            Get.snackbar('Coming Soon', 'Help & Support will be available soon!');
          },
        ),

        const SizedBox(height: 32),

        // Sign Out Button
        OutlinedButton.icon(
          onPressed: () async {
            await authController.logout();
            Get.offAll(() => const LoginScreen());
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Sign Out',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
