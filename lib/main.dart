import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart'; // NEW: For routing
import 'firebase_options.dart';

import 'core/providers/language_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// NEW: Helper function to route dynamically based on the user's role
void _handleNotificationClick() {
  final context = AppRouter.navigatorKey.currentContext;
  if (context != null) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userRole == 'BUYER') {
      context.push('/buyer-enquiries');
    } else {
      // Farmers check their received orders here
      context.push('/order-history');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. FOREGROUND: Listen for messages when the app is actively open
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('DEBUG: [Firebase] Got a message whilst in the foreground!');

    if (message.notification != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.notification?.title ?? 'New Notification',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(message.notification?.body ?? ''),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              // SCENARIO 1: Tapping the Foreground Snackbar
              _handleNotificationClick();
            },
          ),
        ),
      );
    }
  });

  // 2. BACKGROUND: User taps notification while app is running in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('DEBUG: [Firebase] Notification tapped from background!');
    _handleNotificationClick();
  });

  // Start the UI immediately
  runApp(const KrushiMitraApp());

  // 3. TERMINATED: User taps notification when app was completely closed
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('DEBUG: [Firebase] App launched from terminated state via notification!');
    // Delay slightly to ensure GoRouter has finished building the initial screen
    Future.delayed(const Duration(milliseconds: 800), () {
      _handleNotificationClick();
    });
  }

  // Fetch the token in the background
  Future.microtask(() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      String? token = await messaging.getToken();
      debugPrint("SUCCESS! YOUR FCM TOKEN IS: $token");
    } catch (e) {
      debugPrint("FCM ERROR: Failed to get token! $e");
    }
  });
}

class KrushiMitraApp extends StatelessWidget {
  const KrushiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'KrushiMitra',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.createRouter(authProvider),
          );
        },
      ),
    );
  }
}