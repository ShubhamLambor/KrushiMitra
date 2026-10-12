// lib/features/marketplace/screens/marketplace_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/marketplace_service.dart';

class MarketplaceFeedScreen extends StatefulWidget {
  const MarketplaceFeedScreen({super.key});

  @override
  State<MarketplaceFeedScreen> createState() => _MarketplaceFeedScreenState();
}

class _MarketplaceFeedScreenState extends State<MarketplaceFeedScreen> {
  late Future<List<dynamic>?> _listingsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadListings({String? query}) {
    setState(() {
      _listingsFuture = MarketplaceService.getListings(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Produce Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              _loadListings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _loadListings(query: value); // Update feed as user types
              },
              decoration: InputDecoration(
                hintText: 'Search for crops or produce...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _loadListings();
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // 2. Marketplace Feed
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: _listingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                } else if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text('Failed to load marketplace listings.'));
                }

                final listings = snapshot.data!;
                if (listings.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'No produce currently available in the marketplace.'
                          : 'No results found for "${_searchController.text}"',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final item = listings[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // USE GO_ROUTER to navigate and pass the data!
                          context.push('/produce-details', extra: item);
                        },
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
                                      item['title'] ?? 'Produce',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Chip(
                                    label: Text('₹${item['price_per_unit']} / ${item['unit']}'),
                                    backgroundColor: Colors.green.shade50,
                                    labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(item['description'], style: TextStyle(color: Colors.grey.shade700)),
                              ],
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('Qty: ${item['quantity']} ${item['unit']}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(item['location'] ?? 'Unknown'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Farmer: ${item['farmer_name']}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'Ph: ${item['farmer_phone']}',
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}