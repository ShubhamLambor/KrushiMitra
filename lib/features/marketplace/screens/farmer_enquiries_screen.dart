// lib/features/marketplace/screens/farmer_enquiries_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/marketplace_service.dart';

class FarmerEnquiriesScreen extends StatefulWidget {
  const FarmerEnquiriesScreen({super.key});

  @override
  State<FarmerEnquiriesScreen> createState() => _FarmerEnquiriesScreenState();
}

class _FarmerEnquiriesScreenState extends State<FarmerEnquiriesScreen> {
  late Future<List<dynamic>?> _enquiriesFuture;

  @override
  void initState() {
    super.initState();
    _loadEnquiries();
  }

  void _loadEnquiries() {
    setState(() {
      _enquiriesFuture = MarketplaceService.getFarmerEnquiries();
    });
  }

  Future<void> _updateStatus(int enquiryId, String status) async {
    final error = await MarketplaceService.updateEnquiryStatus(
      enquiryId: enquiryId,
      status: status,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Order $status successfully!'),
            backgroundColor: status == 'ACCEPTED' ? Colors.green : Colors.orange
        ),
      );
      _loadEnquiries(); // Refresh the list instantly
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Incoming Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEnquiries),
        ],
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _enquiriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load incoming orders.'));
          }

          final enquiries = snapshot.data!;
          if (enquiries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No incoming orders yet.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadEnquiries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: enquiries.length,
              itemBuilder: (context, index) {
                final item = enquiries[index];
                final status = item['status'] ?? 'PENDING';

                Color statusColor = Colors.orange;
                if (status == 'ACCEPTED') statusColor = Colors.green;
                if (status == 'REJECTED') statusColor = Colors.red;

                // Format Date safely
                String dateStr = item['created_at'] ?? '';
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['listing_title'] ?? 'Produce',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Requested Quantity: ${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w500)),

                        if (item['message'] != null && item['message'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Text('"${item['message']}"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Buyer Details:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(item['buyer_name'] ?? 'Unknown Buyer', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(item['buyer_phone'] ?? '', style: TextStyle(color: Colors.grey.shade700)),
                              ],
                            ),
                            Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                        // Only show buttons if the status is still PENDING
                        if (status == 'PENDING') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateStatus(item['id'], 'REJECTED'),
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red)
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus(item['id'], 'ACCEPTED'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text('Accept', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
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