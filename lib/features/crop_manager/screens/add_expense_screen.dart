// lib/features/crop_manager/screens/add_expense_screen.dart
import 'package:flutter/material.dart';
import '../services/crop_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();

  List<dynamic> _crops = [];
  bool _isLoadingCrops = true;
  bool _isSubmitting = false;

  int? _selectedCropId;
  String _selectedCategory = 'Seeds';
  final List<String> _categories = ['Seeds', 'Fertilizer', 'Pesticide', 'Labour', 'Irrigation', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchCrops();
  }

  Future<void> _fetchCrops() async {
    final crops = await CropService.getActiveCrops();
    if (!mounted) return;

    setState(() {
      _crops = crops;
      _isLoadingCrops = false;
      if (crops.isNotEmpty) {
        _selectedCropId = crops[0]['id'];
      }
    });
  }

  Future<void> _handleSubmit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || _selectedCropId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a crop and enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final error = await CropService.addExpense(
      cropId: _selectedCropId!,
      category: _selectedCategory,
      amount: amount,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense recorded successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add Crop Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoadingCrops
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _crops.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco_outlined, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No active crops found. Please add a crop first before recording expenses.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Log an Expense',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep your farm analytics accurate by recording costs.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Crop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedCropId,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.green.shade700),
                        items: _crops.map<DropdownMenuItem<int>>((crop) {
                          return DropdownMenuItem<int>(
                            value: crop['id'],
                            child: Text('${crop['name']} (${crop['area']} Acres)', style: const TextStyle(fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCropId = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Expense Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.green.shade700),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w500)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Amount (₹)',
                    hint: 'Enter expense amount',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : PrimaryButton(
              text: 'Save Expense',
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}