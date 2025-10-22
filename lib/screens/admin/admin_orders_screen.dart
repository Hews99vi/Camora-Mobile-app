import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../models/order.dart';
import 'order_status_update_screen.dart';
import '../../utils/app_bar_utils.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderController _orderController = Get.put(OrderController());

  String _formatDate(DateTime date) {
    return DateFormatter.formatDate(date);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: OrderStatus.values.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarUtils.whiteAppBar(
        title: 'Order Management',
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            const Tab(text: 'All Orders'),
            ...OrderStatus.values.map((status) => Tab(text: status.displayName)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _orderController.loadOrders(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: Obx(() {
        if (_orderController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_orderController.error.isNotEmpty) {
          String errorMessage = _orderController.error;
          bool isPermissionError = errorMessage.contains('permission-denied');
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPermissionError ? Icons.security : Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  isPermissionError 
                      ? 'You do not have permission to access this area'
                      : 'Error: ${_orderController.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (isPermissionError)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'This section is only accessible to admin users. Please contact your administrator.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _orderController.loadOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildOrdersList(_orderController.orders),
            ...OrderStatus.values.map(
              (status) => _buildOrdersList(_orderController.getOrdersByStatus(status)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _orderController.loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
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
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id != null ? order.id!.substring(0, 8).toUpperCase() : 'UNKNOWN'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName ?? 'Unknown Customer',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.createdAt != null ? _formatDate(order.createdAt!) : 'Unknown date',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order Status
              Row(
                children: [
                  _buildStatusChip(
                    order.status?.displayName ?? 'Unknown', 
                    order.status?.color ?? Colors.grey
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    order.paymentStatus?.displayName ?? 'Unknown',
                    order.paymentStatus?.color ?? Colors.grey,
                  ),
                  const Spacer(),
                  Text(
                    '${order.items?.length ?? 0} item${(order.items?.length ?? 0) > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // First item preview
              if (order.items != null && order.items!.isNotEmpty)
                Text(
                  (order.items!.first.productName ?? 'Unknown Product') +
                      (order.items!.length > 1 
                          ? ' (+${order.items!.length - 1} more)' 
                          : ''),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    Get.to(() => OrderDetailsScreen(order: order));
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find();
    
    return Scaffold(
      appBar: AppBarUtils.whiteAppBar(
        title: 'Order #${order.id != null ? order.id!.substring(0, 8).toUpperCase() : 'UNKNOWN'}',
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Order Actions',
            onSelected: (value) async {
              switch (value) {
                case 'edit_status':
                  Get.to(() => OrderStatusUpdateScreen(order: order));
                  break;
                case 'edit_payment':
                  _showPaymentStatusDialog(context, orderController);
                  break;
                case 'add_tracking':
                  _showTrackingDialog(context, orderController);
                  break;
                case 'add_notes':
                  _showNotesDialog(context, orderController);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_status',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Update Status & Tracking'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit_payment',
                child: Row(
                  children: [
                    Icon(Icons.payment, size: 20),
                    SizedBox(width: 8),
                    Text('Update Payment'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_tracking',
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, size: 20),
                    SizedBox(width: 8),
                    Text('Add Tracking'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_notes',
                child: Row(
                  children: [
                    Icon(Icons.notes, size: 20),
                    SizedBox(width: 8),
                    Text('Add Notes'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 16),
            
            // Customer Info Card
            _buildCustomerCard(),
            const SizedBox(height: 16),
            
            // Shipping Address Card
            _buildShippingCard(),
            const SizedBox(height: 16),
            
            // Order Items Card
            _buildItemsCard(),
            const SizedBox(height: 16),
            
            // Order Timeline
            _buildTimelineCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Order ID', '#${order.id != null ? order.id!.substring(0, 8).toUpperCase() : 'UNKNOWN'}'),
            _buildInfoRow('Date', order.createdAt != null ? DateFormatter.formatDateTime(order.createdAt!) : 'Unknown'),
            _buildInfoRow('Status', order.status?.displayName ?? 'Unknown'),
            _buildInfoRow('Payment', order.paymentStatus?.displayName ?? 'Unknown'),
            if (order.trackingNumber != null)
              _buildInfoRow('Tracking', order.trackingNumber!),
            const Divider(),
            _buildInfoRow(
              'Total Amount',
              '\$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', order.customerName ?? 'Unknown'),
            _buildInfoRow('Email', order.customerEmail ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              order.shippingAddress?.fullName ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(order.shippingAddress?.fullAddress ?? 'No address provided'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(order.items ?? []).map((item) => _buildItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage ?? 'https://placehold.co/600x400?text=No+Image',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.size ?? 'N/A'} × ${item.quantity ?? 0}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.total?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Current Status with Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: order.status?.color.withValues(alpha: 0.1) ?? Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: order.status?.color.withValues(alpha: 0.3) ?? Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: order.status?.color ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      order.status?.icon ?? Icons.help_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status: ${order.status?.displayName ?? 'Unknown'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: order.status?.color ?? Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.status?.description ?? 'No description available',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildTimelineItem(
              'Order Placed',
              order.createdAt != null ? DateFormatter.formatDateTime(order.createdAt!) : 'Unknown',
              true,
              Icons.shopping_cart,
              Colors.blue,
            ),
            if (order.status != null && order.status!.progressValue >= 2)
              _buildTimelineItem(
                'Order Confirmed',
                order.updatedAt != null 
                    ? DateFormatter.formatDateTime(order.updatedAt!)
                    : 'Pending',
                order.status!.progressValue >= 2,
                Icons.check_circle_outline,
                Colors.blue,
              ),
            if (order.status != null && order.status!.progressValue >= 3)
              _buildTimelineItem(
                'Processing',
                order.updatedAt != null 
                    ? DateFormatter.formatDateTime(order.updatedAt!)
                    : 'Pending',
                order.status!.progressValue >= 3,
                Icons.inventory,
                Colors.indigo,
              ),
            if (order.status != null && order.status!.progressValue >= 4)
              _buildTimelineItem(
                'Shipped',
                order.updatedAt != null 
                    ? DateFormatter.formatDateTime(order.updatedAt!)
                    : 'Pending',
                order.status!.progressValue >= 4,
                Icons.local_shipping,
                Colors.purple,
              ),
            if (order.status != null && order.status!.progressValue >= 5)
              _buildTimelineItem(
                'Delivered',
                order.updatedAt != null 
                    ? DateFormatter.formatDateTime(order.updatedAt!)
                    : 'Pending',
                order.status!.progressValue >= 5,
                Icons.home,
                Colors.green,
              ),
            
            if (order.status == OrderStatus.cancelled)
              _buildTimelineItem(
                'Order Cancelled',
                order.updatedAt != null 
                    ? DateFormatter.formatDateTime(order.updatedAt!)
                    : (order.createdAt != null ? DateFormatter.formatDateTime(order.createdAt!) : 'Unknown date'),
                true,
                Icons.cancel,
                Colors.red,
              ),
            
            if (order.status == OrderStatus.refunded)
              _buildTimelineItem(
                'Order Refunded',
                order.updatedAt != null 
                    ? DateFormatter.formatDateTime(order.updatedAt!)
                    : (order.createdAt != null ? DateFormatter.formatDateTime(order.createdAt!) : 'Unknown date'),
                true,
                Icons.money_off,
                Colors.grey,
              ),
            
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notes,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Order Notes:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      order.notes!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isCompleted, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey[600],
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.black87 : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentStatusDialog(BuildContext context, OrderController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PaymentStatus.values.map((status) {
            return ListTile(
              title: Text(status.displayName),
              leading: Icon(
                order.paymentStatus == status ? Icons.radio_button_checked : Icons.radio_button_off,
                color: status.color,
              ),
              onTap: () {
                controller.updatePaymentStatus(order.id ?? '', status);
                Get.back();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTrackingDialog(BuildContext context, OrderController controller) {
    final TextEditingController trackingController = TextEditingController(
      text: order.trackingNumber ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tracking Number'),
        content: TextField(
          controller: trackingController,
          decoration: const InputDecoration(
            labelText: 'Tracking Number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (trackingController.text.isNotEmpty) {
                controller.updateTrackingNumber(order.id ?? '', trackingController.text);
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context, OrderController controller) {
    final TextEditingController notesController = TextEditingController(
      text: order.notes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Order Notes'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.addOrderNotes(order.id ?? '', notesController.text);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
