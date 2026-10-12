// lib/features/marketplace/screens/produce_details_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/marketplace_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ProduceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> produce; // Accept real data

  const ProduceDetailsScreen({super.key, required this.produce});

  @override
  State<ProduceDetailsScreen> createState() => _ProduceDetailsScreenState();
}

class _ProduceDetailsScreenState extends State<ProduceDetailsScreen> {
  final _quantityController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitEnquiry() async {
    final quantityText = _quantityController.text.trim();
    final message = _messageController.text.trim();

    if (quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quantity.')),
      );
      return;
    }

    final quantity = double.tryParse(quantityText);
    if (quantity == null || quantity <= 0 || quantity > widget.produce['quantity']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid quantity up to ${widget.produce['quantity']}.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await MarketplaceService.sendEnquiry(
      listingId: widget.produce['id'],
      quantity: quantity,
      message: message,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enquiry sent to ${widget.produce['farmer_name']}!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(); // Go back to feed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.produce;

    return Scaffold(
      appBar: AppBar(title: const Text('Produce Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Produce Header
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  image: item['image_url'] != null
                      ? DecorationImage(
                    image: NetworkImage(item['image_url']),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: item['image_url'] == null
                    ? const Icon(Icons.eco, color: Colors.green, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(item['title'] ?? 'Produce', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item['description'], style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${item['price_per_unit']} / ${item['unit']}', style: TextStyle(fontSize: 20, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                Text('Available: ${item['quantity']} ${item['unit']}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 30, thickness: 1),

            // 2. Farmer Info
            const Text('Farmer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.person, color: Colors.white)),
              title: Text(item['farmer_name'] ?? 'Unknown Farmer'),
              subtitle: Text(item['location'] ?? 'Unknown Location'),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () {
                  // In the future, you can use url_launcher to call the farmer directly
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Farmer Phone: ${item['farmer_phone']}')),
                  );
                },
              ),
            ),
            const Divider(height: 30, thickness: 1),

            // 3. Send Enquiry Form
            const Text('Interested? Send an Enquiry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'How much do you want to buy?',
              hint: 'Max: ${item['quantity']}',
              controller: _quantityController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Message to Farmer', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., I can pick this up tomorrow morning.',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : PrimaryButton(
              text: 'Send Enquiry',
              onPressed: _submitEnquiry,
            ),
          ],
        ),
      ),
    );
  }
}