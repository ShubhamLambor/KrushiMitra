// lib/features/dashboard/screens/farmer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../weather/services/weather_service.dart';
import '../../crop_manager/services/crop_service.dart';
import '../../marketplace/services/marketplace_service.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _cropCount = 0;
  int _pendingEnquiryCount = 0;
  int _listingCount = 0;
  bool _isLoadingMetrics = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardMetrics();
  }

  Future<void> _loadDashboardMetrics() async {
    try {
      final crops = await CropService.getCrops();
      final enquiries = await MarketplaceService.getFarmerEnquiries();
      final listings = await MarketplaceService.getFarmerListings();

      if (!mounted) return;
      setState(() {
        _cropCount = crops.length;
        _pendingEnquiryCount = enquiries?.where((e) => e['status'] == 'PENDING').length ?? 0;
        _listingCount = listings?.length ?? 0;
        _isLoadingMetrics = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMetrics = false);
    }
  }

  Map<String, dynamic> _getWeatherActionUI(dynamic tempVal, dynamic precipVal) {
    final t = double.tryParse(tempVal?.toString() ?? '25') ?? 25.0;
    final p = double.tryParse(precipVal?.toString() ?? '0') ?? 0.0;

    if (p > 2.0) {
      return {
        'bgColor': Colors.red.shade50,
        'borderColor': Colors.red.shade300,
        'iconColor': Colors.red.shade700,
        'icon': Icons.warning_amber_rounded,
        'headline': 'Rain Expected: Do not spray chemicals today.',
      };
    } else if (t > 35.0) {
      return {
        'bgColor': Colors.orange.shade50,
        'borderColor': Colors.orange.shade300,
        'iconColor': Colors.orange.shade800,
        'icon': Icons.local_fire_department_rounded,
        'headline': 'Extreme Heat: Irrigate crops heavily.',
      };
    } else {
      return {
        'bgColor': Colors.green.shade50,
        'borderColor': Colors.green.shade300,
        'iconColor': Colors.green.shade700,
        'icon': Icons.check_circle_outline_rounded,
        'headline': 'Good conditions for farming activities.',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);
    const surfaceColor = Colors.white;
    final borderColor = Colors.grey.shade200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.agriculture_rounded, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr('dashboard'),
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.translate_rounded, size: 20, color: Colors.grey.shade700),
            tooltip: 'Change Language',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (code) => context.read<LanguageProvider>().changeLanguage(code),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text('English', style: TextStyle(fontSize: 14))),
              PopupMenuItem(value: 'mr', child: Text('मराठी (Marathi)', style: TextStyle(fontSize: 14))),
              PopupMenuItem(value: 'hi', child: Text('हिंदी (Hindi)', style: TextStyle(fontSize: 14))),
            ],
          ),
          IconButton(
            icon: Icon(Icons.account_circle_outlined, size: 22, color: Colors.grey.shade700),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          await _loadDashboardMetrics();
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 0. Welcome Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Colors.green.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Welcome, Farmer!',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage your crops and connect with buyers seamlessly.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. Weather Advisory Card
              FutureBuilder<Map<String, dynamic>?>(
                future: WeatherService.getWeather(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                  }

                  final weather = snapshot.data;
                  final temp = weather?['temperature_2m'];
                  final humidity = weather?['relative_humidity_2m'];
                  final precip = weather?['precipitation'];
                  final uiProps = _getWeatherActionUI(temp, precip);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: uiProps['bgColor'],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: uiProps['borderColor'], width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(uiProps['icon'] as IconData, color: uiProps['iconColor'], size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                uiProps['headline'] as String,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWeatherStat(Icons.thermostat, '${temp ?? '--'}°C'),
                            _buildWeatherStat(Icons.water_drop_outlined, '${precip ?? '0'} mm'),
                            _buildWeatherStat(Icons.air, '${humidity ?? '--'}%'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. Live Metrics Summary Row
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Active Crops', '$_cropCount', Icons.grass, primaryColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Pending Orders', '$_pendingEnquiryCount', Icons.mark_email_unread, Colors.blue.shade700)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Listings', '$_listingCount', Icons.storefront, Colors.amber.shade800)),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Quick Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Register Crop',
                      icon: Icons.add_rounded,
                      color: primaryColor,
                      onTap: () async {
                        await context.push('/add-crop');
                        _loadDashboardMetrics();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Financials',
                      icon: Icons.analytics_outlined,
                      color: const Color(0xFF334155),
                      onTap: () => context.push('/financial-summary'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Dedicated Management Navigation Cards
              const Text(
                'Farm Management',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              _buildNavCard(
                title: 'My Active Crops',
                subtitle: 'Manage active fields, view growth cycles, and add expenses',
                icon: Icons.grass_rounded,
                iconColor: primaryColor,
                backgroundColor: surfaceColor,
                borderColor: borderColor,
                badgeCount: _cropCount,
                onTap: () async {
                  await context.push('/my-crops');
                  _loadDashboardMetrics();
                },
              ),
              const SizedBox(height: 12),

              _buildNavCard(
                title: 'Buyer Enquiries',
                subtitle: 'Review incoming customer orders and accept/reject requests',
                icon: Icons.mark_email_unread_outlined,
                iconColor: Colors.blue.shade700,
                backgroundColor: surfaceColor,
                borderColor: borderColor,
                badgeCount: _pendingEnquiryCount,
                badgeColor: Colors.red,
                onTap: () async {
                  await context.push('/farmer-enquiries');
                  _loadDashboardMetrics();
                },
              ),
              const SizedBox(height: 12),

              _buildNavCard(
                title: 'Published Marketplace Items',
                subtitle: 'Check stock levels and manage active crop listings',
                icon: Icons.storefront_outlined,
                iconColor: Colors.amber.shade800,
                backgroundColor: surfaceColor,
                borderColor: borderColor,
                badgeCount: _listingCount,
                onTap: () async {
                  await context.push('/my-listings');
                  _loadDashboardMetrics();
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/publish-listing');
          _loadDashboardMetrics();
        },
        backgroundColor: primaryColor,
        elevation: 2,
        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18, color: Colors.white),
        label: const Text('Sell Produce', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required int badgeCount,
    Color badgeColor = const Color(0xFF1B5E20),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                      ),
                      if (badgeCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}