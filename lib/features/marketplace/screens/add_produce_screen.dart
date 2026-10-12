// lib/features/marketplace/screens/add_produce_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // We use this to format the date nicely

class AddProduceScreen extends StatefulWidget {
  const AddProduceScreen({super.key});

  @override
  State<AddProduceScreen> createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
  final _produceNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedUnit = 'kg';
  final List<String> _units = ['kg', 'quintal', 'tons', 'crates', 'dozens'];

  DateTime _availabilityDate = DateTime.now(); // Defaults to today

  @override
  void dispose() {
    _produceNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Function to open the calendar picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _availabilityDate,
      firstDate: DateTime.now(), // Cannot pick a past date to sell produce
      lastDate: DateTime.now().add(const Duration(days: 90)), // Up to 3 months ahead
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _availabilityDate) {
      setState(() {
        _availabilityDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Produce for Sale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Produce Name
            const Text('What are you selling?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _produceNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Red Tomatoes, Basmati Rice',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Quantity & Unit (Side by Side)
            const Text('Total Quantity Available', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g., 50',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _units.map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) _selectedUnit = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Expected Price
            const Text('Expected Price (per unit)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: 'e.g., 40',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Availability Date
            const Text('When will it be ready for pickup?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(_availabilityDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 5. Submit Button
            ElevatedButton(
              onPressed: () {
                // Mock Saving Data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing published to local buyers!')),
                );
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text('Publish Listing', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}