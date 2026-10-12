// lib/features/dashboard/screens/buyer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../marketplace/services/marketplace_service.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Vegetables', 'Fruits', 'Grains'];

  late Future<List<dynamic>?> _listingsFuture;

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

  void _loadListings() {
    setState(() {
      _listingsFuture = MarketplaceService.getListings();
    });
  }

  Future<void> _callFarmer(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open phone dialer')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showOrderDialog(BuildContext context, dynamic item) {
    final qtyController = TextEditingController(text: item['quantity'].toString());
    final msgController = TextEditingController(text: 'I am interested in buying this produce.');
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Offer for ${item['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Farmer: ${item['farmer_name']}', style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 20),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Required Quantity (${item['unit']})',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: msgController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Message / Offer',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: isSubmitting ? null : () async {
                final qty = double.tryParse(qtyController.text.trim()) ?? 0;
                if (qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid quantity')));
                  return;
                }

                setDialogState(() => isSubmitting = true);

                final error = await MarketplaceService.sendEnquiry(
                  listingId: item['id'],
                  quantity: qty,
                  message: msgController.text.trim(),
                );

                if (!mounted) return;
                Navigator.pop(context);

                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enquiry sent successfully to farmer!'), backgroundColor: Colors.green),
                  );
                }
              },
              child: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Send Offer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Buyer Marketplace',
              style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long_rounded, size: 22, color: Colors.grey.shade700),
            onPressed: () => context.push('/buyer-enquiries'),
            tooltip: 'My Purchases',
          ),
          IconButton(
            icon: Icon(Icons.account_circle_outlined, size: 22, color: Colors.grey.shade700),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async => _loadListings(),
        child: Column(
          children: [
            // Header Search & Filters Container
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  // Promotional Welcome Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, Colors.green.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Fresh Harvest Direct', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 2),
                              Text('Buy directly from verified local farmers at best prices.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search fresh produce (e.g., tomato, wheat)...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              color: Colors.white,
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (selected) => setState(() => _selectedFilterIndex = index),
                      backgroundColor: Colors.white,
                      selectedColor: primaryColor.withOpacity(0.1),
                      side: BorderSide(color: isSelected ? primaryColor.withOpacity(0.3) : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      labelStyle: TextStyle(
                        color: isSelected ? primaryColor : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // Listings Feed
            Expanded(
              child: FutureBuilder<List<dynamic>?>(
                future: _listingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryColor));
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Failed to connect to market.', style: TextStyle(color: Colors.grey.shade600)),
                          TextButton.icon(
                            onPressed: _loadListings,
                            icon: const Icon(Icons.refresh, color: primaryColor),
                            label: const Text('Retry', style: TextStyle(color: primaryColor)),
                          )
                        ],
                      ),
                    );
                  }

                  final allListings = snapshot.data!;
                  final filteredListings = allListings.where((item) {
                    final title = (item['title'] ?? '').toString().toLowerCase();
                    final desc = (item['description'] ?? '').toString().toLowerCase();
                    final searchLower = _searchQuery.toLowerCase();

                    final matchesSearch = title.contains(searchLower) || desc.contains(searchLower);

                    bool matchesFilter = true;
                    if (_selectedFilterIndex != 0) {
                      final category = _filters[_selectedFilterIndex];
                      if (category == 'Vegetables') {
                        matchesFilter = title.contains('potato') || title.contains('tomato') || title.contains('onion') || title.contains('carrot');
                      } else if (category == 'Fruits') {
                        matchesFilter = title.contains('mango') || title.contains('apple') || title.contains('banana') || title.contains('grape');
                      } else if (category == 'Grains') {
                        matchesFilter = title.contains('wheat') || title.contains('rice') || title.contains('corn') || title.contains('soybean');
                      }
                    }

                    return matchesSearch && matchesFilter;
                  }).toList();

                  if (filteredListings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('No produce found matching your search.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredListings.length,
                    itemBuilder: (context, index) {
                      final item = filteredListings[index];
                      final phone = item['farmer_phone']?.toString() ?? '';
                      final imageUrl = item['image_url'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl != null && imageUrl.toString().isNotEmpty)
                                Image.network(
                                  imageUrl,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 160,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['title'] ?? 'Produce',
                                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '₹${item['price_per_unit']}/${item['unit']}',
                                            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w800, fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(item['description'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Text('Stock: ${item['quantity']}', style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 14),
                                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(item['location'] ?? 'Unknown Location', style: TextStyle(color: Colors.grey.shade800, fontSize: 12), overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 13,
                                              backgroundColor: primaryColor.withOpacity(0.1),
                                              child: const Icon(Icons.person, size: 14, color: primaryColor),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(item['farmer_name'] ?? 'Farmer', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0F172A))),
                                                if (phone.isNotEmpty)
                                                  Text(phone, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            if (phone.isNotEmpty)
                                              Container(
                                                margin: const EdgeInsets.only(right: 6),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey.shade300),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.phone_outlined, size: 16),
                                                  color: Colors.blue.shade700,
                                                  onPressed: () => _callFarmer(phone),
                                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ElevatedButton(
                                              onPressed: () => _showOrderDialog(context, item),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                elevation: 0,
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              child: const Text('Send Offer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      ),
    );
  }
}