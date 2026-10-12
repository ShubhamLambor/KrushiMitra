// lib/features/crop_manager/screens/add_crop_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../services/crop_service.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _cropNameController = TextEditingController();
  final _areaController = TextEditingController();
  final _sownDateController = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  bool _isLoading = false;

  Future<void> _handleAddCrop() async {
    final cropName = _cropNameController.text.trim();
    final areaText = _areaController.text.trim();
    final sownDate = _sownDateController.text.trim();

    if (cropName.isEmpty || areaText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final area = double.tryParse(areaText);
    if (area == null || area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number for area')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final error = await CropService.addCrop(
        cropName: cropName,
        area: area,
        sownDate: sownDate,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crop registered successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _areaController.dispose();
    _sownDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add Active Crop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Register New Crop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Track a new crop in your field to manage expenses and yields.',
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
                  CustomTextField(
                    label: 'Crop Name',
                    hint: 'e.g. Tomato, Wheat',
                    controller: _cropNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Area (in Acres)',
                    hint: 'e.g. 2.5',
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Sown Date (YYYY-MM-DD)',
                    hint: 'e.g. 2026-10-12',
                    controller: _sownDateController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : PrimaryButton(
              text: 'Save Active Crop',
              onPressed: _handleAddCrop,
            ),
          ],
        ),
      ),
    );
  }
}