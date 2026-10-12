// lib/features/marketplace/screens/publish_listing_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/language_provider.dart';
import '../services/marketplace_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class PublishListingScreen extends StatefulWidget {
  const PublishListingScreen({super.key});

  @override
  State<PublishListingScreen> createState() => _PublishListingScreenState();
}

class _PublishListingScreenState extends State<PublishListingScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedUnit = 'Kg';
  final List<String> _units = ['Kg', 'Quintal', 'Ton', 'Boxes'];
  bool _isLoading = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // Let the user choose between Camera and Gallery
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                if (photo != null) setState(() => _selectedImage = File(photo.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                if (image != null) setState(() => _selectedImage = File(image.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePublish() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final quantityText = _quantityController.text.trim();
    final priceText = _priceController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty || quantityText.isEmpty || priceText.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return;
    }

    final quantity = double.tryParse(quantityText);
    final price = double.tryParse(priceText);

    if (quantity == null || quantity <= 0 || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers for quantity and price')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await MarketplaceService.publishListing(
      title: title,
      description: description,
      quantity: quantity,
      unit: _selectedUnit,
      pricePerUnit: price,
      location: location,
      imageFile: _selectedImage, // Pass the image file!
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing published successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(context.tr('publish_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              'Sell Your Produce',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Add details and a photo to attract buyers quickly.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // --- NEW: Image Upload Box ---
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 2),
                  image: _selectedImage != null
                      ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.green.shade600),
                    const SizedBox(height: 12),
                    const Text('Tap to add a photo of your produce', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                )
                    : Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ),
              ),
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
                    label: context.tr('produce_title_label'),
                    hint: 'Enter title',
                    controller: _titleController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Description (Optional)',
                    hint: 'Add quality details, variety, etc.',
                    controller: _descController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          label: context.tr('quantity_label'),
                          hint: 'e.g. 500',
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('unit_label'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedUnit,
                                  isExpanded: true,
                                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.green.shade700),
                                  items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontWeight: FontWeight.w500)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedUnit = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: context.tr('price_label'),
                    hint: 'e.g. 30',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: context.tr('location_label'),
                    hint: 'e.g. Pune APMC',
                    controller: _locationController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : PrimaryButton(
              text: context.tr('publish_btn'),
              onPressed: _handlePublish,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}