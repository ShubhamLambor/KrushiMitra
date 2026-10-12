// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the provider to get the role and logout function
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.userRole ?? 'User';

    // Consistent color palette matching the dashboard
    const primaryColor = Color(0xFF1B5E20);
    const surfaceColor = Colors.white;
    final borderColor = Colors.grey.shade200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Profile Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.person_rounded, size: 40, color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'My Account',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Preferences & Settings Menu
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: // Inside ProfileScreen, replace your menu tile column with this:
              Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.history_rounded,
                    title: 'Order History',
                    onTap: () => context.push('/order-history'), // <-- Added Route
                    isFirst: true,
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _buildMenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => context.push('/settings'), // <-- Added Route
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. Modern Logout Button
            InkWell(
              onTap: () async {
                // This clears the token and triggers GoRouter to auto-redirect to /login
                await authProvider.logout();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Menu Tile ---
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? 16 : 0),
          bottom: Radius.circular(isLast ? 16 : 0),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF334155)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
    );
  }
}