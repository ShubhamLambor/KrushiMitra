// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Provider Import
import '../../features/auth/providers/auth_provider.dart';

// Screen Imports
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/crop_manager/screens/add_crop_screen.dart';
import '../../features/crop_manager/screens/financial_summary_screen.dart';
import '../../features/crop_manager/screens/my_crops_screen.dart';
import '../../features/dashboard/screens/farmer_dashboard.dart';
import '../../features/dashboard/screens/buyer_dashboard.dart';
import '../../features/crop_manager/screens/add_expense_screen.dart';
import '../../features/marketplace/screens/add_produce_screen.dart';
import '../../features/marketplace/screens/marketplace_feed_screen.dart';
import '../../features/marketplace/screens/my_listings_screen.dart';
import '../../features/marketplace/screens/produce_details_screen.dart';
import '../../features/marketplace/screens/buyer_enquiries_screen.dart';
import '../../features/marketplace/screens/farmer_enquiries_screen.dart'; // Added Farmer Enquiries Import
import '../../features/marketplace/screens/publish_listing_screen.dart';
import '../../features/profile/screens/order_history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/weather/screens/weather_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,

      redirect: (context, state) {
        final isAuth = authProvider.isAuthenticated;
        final isChecking = authProvider.isCheckingAuth;
        final location = state.matchedLocation;

        if (isChecking) return '/';

        if (!isAuth) {
          if (location == '/login' || location == '/register') {
            return null;
          }
          return '/login';
        }

        if (isAuth) {
          if (location == '/' || location == '/login' || location == '/register') {
            return authProvider.userRole == 'BUYER' ? '/buyer-dashboard' : '/farmer-dashboard';
          }
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/farmer-dashboard', builder: (context, state) => const FarmerDashboardScreen()),
        GoRoute(path: '/buyer-dashboard', builder: (context, state) => const BuyerDashboardScreen()),
        GoRoute(path: '/add-expense', builder: (context, state) => const AddExpenseScreen()),
        GoRoute(path: '/financial-summary', builder: (context, state) => const FinancialSummaryScreen()),
        GoRoute(path: '/add-produce', builder: (context, state) => const AddProduceScreen()),
        GoRoute(path: '/my-crops', builder: (context, state) => const MyCropsScreen()),
        GoRoute(path: '/my-listings', builder: (context, state) => const MyListingsScreen()),
        GoRoute(
          path: '/produce-details',
          builder: (context, state) {
            final produceData = state.extra as Map<String, dynamic>;
            return ProduceDetailsScreen(produce: produceData);
          },
        ),
        GoRoute(path: '/buyer-enquiries', builder: (context, state) => const BuyerEnquiriesScreen()),
        GoRoute(path: '/farmer-enquiries', builder: (context, state) => const FarmerEnquiriesScreen()), // Added Route
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(path: '/publish-listing', builder: (context, state) => const PublishListingScreen()),
        GoRoute(path: '/marketplace-feed', builder: (context, state) => const MarketplaceFeedScreen()),
        GoRoute(path: '/weather', builder: (context, state) => const WeatherScreen()),
        GoRoute(path: '/add-crop', builder: (context, state) => const AddCropScreen()),
        GoRoute(path: '/order-history', builder: (context, state) => const OrderHistoryScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text('KrushiMitra', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}