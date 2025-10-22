import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order.dart';
import '../../controllers/order_controller.dart';
import '../../utils/app_bar_utils.dart';

class OrderStatusUpdateScreen extends StatefulWidget {
  final Order order;
  
  const OrderStatusUpdateScreen({super.key, required this.order});

  @override
  State<OrderStatusUpdateScreen> createState() => _OrderStatusUpdateScreenState();
}

class _OrderStatusUpdateScreenState extends State<OrderStatusUpdateScreen> {
  late OrderStatus? selectedStatus;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController trackingController = TextEditingController();
  bool addNotes = false;
  bool addTracking = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.status;
    notesController.text = widget.order.notes ?? '';
    trackingController.text = widget.order.trackingNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find();
    
    return Scaffold(
      appBar: AppBarUtils.whiteAppBar(
        title: 'Update Order #${widget.order.id != null ? widget.order.id!.substring(0, 8).toUpperCase() : 'UNKNOWN'}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            _buildCurrentStatusCard(),
            const SizedBox(height: 24),
            
            // Status Selection
            _buildStatusSelectionSection(),
            const SizedBox(height: 24),
            
            // Tracking Number Section
            if (selectedStatus == OrderStatus.shipped || widget.order.trackingNumber != null)
              _buildTrackingSection(),
            
            // Notes Section
            _buildNotesSection(),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            _buildActionButtons(orderController),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              widget.order.status?.color.withValues(alpha: 0.1) ?? Colors.grey.withValues(alpha: 0.1),
              widget.order.status?.color.withValues(alpha: 0.05) ?? Colors.grey.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.order.status?.color ?? Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.order.status?.icon ?? Icons.help_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Status',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.order.status?.displayName ?? 'Unknown',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.order.status?.color ?? Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.order.status?.description ?? 'No description available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select New Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...OrderStatus.values.map((status) {
          final isSelected = selectedStatus == status;
          final isCurrent = widget.order.status == status;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedStatus = status;
                  if (status == OrderStatus.shipped) {
                    addTracking = true;
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? status.color.withValues(alpha: 0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? status.color 
                        : isCurrent 
                            ? widget.order.status?.color.withValues(alpha: 0.3) ?? Colors.grey[300]!
                            : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        status.icon,
                        color: status.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                status.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isSelected ? status.color : Colors.black87,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.order.status?.color ?? Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Current',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: status.color,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_shipping,
              color: Colors.blue[600],
            ),
            const SizedBox(width: 8),
            const Text(
              'Tracking Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Add/Update Tracking Number',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: addTracking || trackingController.text.isNotEmpty,
                    onChanged: (value) {
                      setState(() {
                        addTracking = value;
                        if (!value) {
                          trackingController.clear();
                        }
                      });
                    },
                    activeColor: Colors.blue[600],
                  ),
                ],
              ),
              if (addTracking || trackingController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: trackingController,
                  decoration: InputDecoration(
                    labelText: 'Tracking Number',
                    hintText: 'Enter tracking number',
                    prefixIcon: const Icon(Icons.local_shipping),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notes,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            const Text(
              'Order Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Add/Update Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: addNotes || notesController.text.isNotEmpty,
                    onChanged: (value) {
                      setState(() {
                        addNotes = value;
                        if (!value) {
                          notesController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              if (addNotes || notesController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add notes for this order...',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(OrderController orderController) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedStatus != widget.order.status
                ? () => _updateOrder(orderController)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedStatus?.color ?? Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectedStatus == widget.order.status
                  ? 'No Changes to Apply'
                  : 'Update Order Status',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateOrder(OrderController orderController) async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Prepare batch update data
      Map<String, dynamic> updateData = {
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add status if changed
      if (selectedStatus != widget.order.status) {
        updateData['status'] = selectedStatus.toString().split('.').last;
      }

      // Add tracking number if provided and changed
      if (trackingController.text.isNotEmpty && 
          trackingController.text != widget.order.trackingNumber) {
        updateData['trackingNumber'] = trackingController.text;
      }

      // Add notes if changed
      if (notesController.text != widget.order.notes) {
        updateData['notes'] = notesController.text;
      }

      // Perform single batch update to Firestore
      await orderController.updateOrderBatch(widget.order.id ?? '', updateData, selectedStatus);

      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      // Show success and go back
      Get.snackbar(
        'Success',
        'Order updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.back(); // Go back to order details
    } catch (e) {
      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Failed to update order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    trackingController.dispose();
    super.dispose();
  }
}
