import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/order.dart';
import 'order_details_screen.dart';
import '../utils/app_bar_utils.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get or initialize the OrderController
    final OrderController orderController = Get.isRegistered<OrderController>() 
        ? Get.find<OrderController>() 
        : Get.put(OrderController());
    final AuthController authController = Get.find();

    // Load user's orders when the screen is built
    final currentUser = authController.currentUser;
    if (currentUser != null) {
      // Load orders for the current user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentUser.id != null) {
          orderController.loadUserOrders(currentUser.id!);
        }
      });
    }

    return Scaffold(
      appBar: AppBarUtils.whiteAppBar(
        title: 'My Orders',
        centerTitle: true,
      ),
      body: Obx(() {
        final currentUser = authController.currentUser;
        
        if (currentUser == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Please Log In',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You need to be logged in to view your orders',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        if (orderController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderController.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Orders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  orderController.error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => currentUser.id != null ? orderController.loadUserOrders(currentUser.id!) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Filter orders for current user (as backup in case loadUserOrders wasn't called)
        final userOrders = orderController.orders
            .where((order) => order.userId == authController.currentUser?.id)
            .toList();

        if (userOrders.isEmpty && !orderController.isLoading) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (authController.currentUser != null) {
              return authController.currentUser!.id != null 
                  ? orderController.loadUserOrders(authController.currentUser!.id!) 
                  : null;
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userOrders.length,
            itemBuilder: (context, index) {
              final order = userOrders[index];
              return _buildOrderCard(order);
            },
          ),
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
            Icons.shopping_bag_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Start Shopping'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              final authController = Get.find<AuthController>();
              final orderController = Get.find<OrderController>();
              final userId = authController.currentUser?.id;
              if (userId != null) {
                await orderController.createSampleOrders(userId);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Create Sample Orders (Testing)'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id != null ? order.id!.substring(0, 8).toUpperCase() : 'Unknown'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  order.status != null 
                    ? _buildStatusChip(order.status!)
                    : _buildStatusChip(OrderStatus.pending),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Placed on ${order.createdAt != null ? _formatDate(order.createdAt!) : 'Unknown date'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  order.paymentStatus != null
                    ? _buildPaymentStatusChip(order.paymentStatus!)
                    : _buildPaymentStatusChip(PaymentStatus.pending),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${order.items?.length ?? 0} item${(order.items?.length ?? 0) > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (order.status == OrderStatus.shipped && order.trackingNumber != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Tracking Available',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.status?.description ?? 'Order status unknown',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (order.items != null && order.items!.isNotEmpty && order.items!.first.productImage != null)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(order.items!.first.productImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
              if (order.trackingNumber != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Tracking: ${order.trackingNumber}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        text = 'Pending';
        break;
      case OrderStatus.processing:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        text = 'Processing';
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        text = 'Confirmed';
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        text = 'Shipped';
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        text = 'Cancelled';
        break;
      case OrderStatus.returned:
        backgroundColor = Colors.amber[100]!;
        textColor = Colors.amber[700]!;
        text = 'Returned';
        break;
      case OrderStatus.refunded:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        text = 'Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(PaymentStatus paymentStatus) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (paymentStatus) {
      case PaymentStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        text = 'Payment Pending';
        break;
      case PaymentStatus.paid:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = 'Paid';
        break;
      case PaymentStatus.failed:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        text = 'Payment Failed';
        break;
      case PaymentStatus.refunded:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        text = 'Refunded';
        break;
      case PaymentStatus.partiallyRefunded:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.purple[700]!;
        text = 'Partially Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showOrderDetails(Order order) {
    Get.to(() => OrderDetailsScreen(order: order));
  }
}
