// lib/features/crop_manager/screens/my_crops_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/crop_service.dart';

class MyCropsScreen extends StatefulWidget {
  const MyCropsScreen({super.key});

  @override
  State<MyCropsScreen> createState() => _MyCropsScreenState();
}

class _MyCropsScreenState extends State<MyCropsScreen> {
  late Future<List<dynamic>?> _cropsFuture;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  void _loadCrops() {
    setState(() {
      _cropsFuture = CropService.getCrops();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Active Crops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCrops,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _cropsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load active crops.'));
          }

          final crops = snapshot.data!;
          if (crops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grass_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No crops registered yet.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async => _loadCrops(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                final date = crop['sown_date']?.toString().split('T')[0] ?? 'N/A';

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
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.eco_rounded, color: primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop['name'] ?? 'Crop',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Area: ${crop['area']} Acres',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sown On: $date',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/add-expense'),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Expense'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
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
          await context.push('/add-crop');
          _loadCrops(); // Refresh list after adding
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Crop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}