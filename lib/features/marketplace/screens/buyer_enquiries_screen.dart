// lib/features/marketplace/screens/buyer_enquiries_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/marketplace_service.dart';

class BuyerEnquiriesScreen extends StatefulWidget {
  const BuyerEnquiriesScreen({super.key});

  @override
  State<BuyerEnquiriesScreen> createState() => _BuyerEnquiriesScreenState();
}

class _BuyerEnquiriesScreenState extends State<BuyerEnquiriesScreen> {
  late Future<List<dynamic>?> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = MarketplaceService.getBuyerOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Purchase Requests'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load purchase history.'));
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t made any purchase requests yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final status = order['status'] ?? 'PENDING';

                // Configure Badge Colors
                Color statusColor;
                IconData statusIcon;
                switch (status) {
                  case 'ACCEPTED':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    break;
                  case 'REJECTED':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                    break;
                  default:
                    statusColor = Colors.orange;
                    statusIcon = Icons.access_time_filled;
                }

                // Format Date safely
                String dateStr = order['created_at'] ?? '';
                try {
                  final dt = DateTime.parse(dateStr);
                  dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
                } catch (_) {
                  dateStr = 'Recently';
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Title and Status Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                order['listing_title'] ?? 'Crop Listing',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, size: 14, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Body: Order Details
                        Text('Requested Quantity: ${order['quantity']} units', style: const TextStyle(fontWeight: FontWeight.w500)),
                        if (order['message'] != null && order['message'].toString().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Your Note: "${order['message']}"',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                          ),
                        ],
                        const Divider(height: 24),

                        // Footer: Farmer Contact Info & Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Farmer Details:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 14, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text('${order['farmer_name']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text('${order['farmer_phone']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              dateStr,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}