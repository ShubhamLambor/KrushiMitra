// lib/features/marketplace/screens/my_listings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/marketplace_service.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late Future<List<dynamic>?> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  void _loadListings() {
    setState(() {
      _listingsFuture = MarketplaceService.getFarmerListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Published Marketplace Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadListings,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _listingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load published listings.'));
          }

          final listings = snapshot.data!;
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No items currently published.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async => _loadListings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final item = listings[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.inventory_2_outlined, color: Colors.amber.shade800, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? 'Produce',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stock: ${item['quantity']} ${item['unit'] ?? 'Kg'}',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item['price_per_unit'] ?? item['price']}\nper ${item['unit'] ?? 'unit'}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/publish-listing');
          _loadListings(); // Refresh list after publishing new produce
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('Sell Produce', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}