// lib/features/profile/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../marketplace/services/marketplace_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<dynamic>?> _ordersFuture;
  late String _role;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _role = authProvider.userRole ?? 'BUYER';
    _fetchOrders();
  }

  void _fetchOrders() {
    setState(() {
      _ordersFuture = _role.toUpperCase() == 'FARMER'
          ? MarketplaceService.getFarmerEnquiries()
          : MarketplaceService.getBuyerOrders();
    });
  }

  Future<void> _handleStatusUpdate(int orderId, String newStatus) async {
    // Show a quick loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    // FIXED: Using named parameters to match your existing service method
    final errorMessage = await MarketplaceService.updateEnquiryStatus(
        enquiryId: orderId,
        status: newStatus
    );

    if (!mounted) return;
    Navigator.pop(context); // Remove loading indicator

    // FIXED: Your service returns null on success, and a string on error
    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${newStatus.toLowerCase()} successfully!'),
          backgroundColor: newStatus == 'ACCEPTED' ? Colors.green : Colors.red,
        ),
      );
      _fetchOrders(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Order History',
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No orders found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final status = order['status'] ?? 'PENDING';

              final title = order['listing_title'] ?? order['title'] ?? 'Produce';
              final personName = _role == 'FARMER' ? order['buyer_name'] : order['farmer_name'];
              final date = order['created_at'] != null ? order['created_at'].toString().split('T')[0] : 'Recent';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A)),
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(personName ?? 'User', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(date, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                        const Spacer(),
                        Text(
                          'Qty: ${order['quantity']}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: primaryColor),
                        ),
                      ],
                    ),
                    // Show Action Buttons if user is FARMER and status is PENDING
                    if (_role == 'FARMER' && status == 'PENDING') ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleStatusUpdate(order['id'], 'REJECTED'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleStatusUpdate(order['id'], 'ACCEPTED'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg, fg;
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        bg = Colors.green.shade50; fg = Colors.green.shade800;
        break;
      case 'REJECTED':
        bg = Colors.red.shade50; fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.amber.shade50; fg = Colors.amber.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}