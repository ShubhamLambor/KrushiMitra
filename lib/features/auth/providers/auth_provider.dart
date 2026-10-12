import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  String? _userRole;
  bool _isCheckingAuth = true;

  bool get isAuthenticated => _isAuthenticated;
  String? get userRole => _userRole;
  bool get isCheckingAuth => _isCheckingAuth;

  AuthProvider() {
    checkAuthStatus();
  }

  // Check if a token already exists on app startup
  Future<void> checkAuthStatus() async {
    print("DEBUG: [AuthProvider] Checking initial auth status...");
    final token = await _storage.read(key: 'jwt_token');
    final role = await _storage.read(key: 'user_role');

    if (token != null && role != null) {
      _isAuthenticated = true;
      _userRole = role;
      print("DEBUG: [AuthProvider] Found existing session. Role: $role");
    } else {
      print("DEBUG: [AuthProvider] No existing session found.");
    }

    _isCheckingAuth = false;
    print("DEBUG: [AuthProvider] checkAuthStatus complete. Notifying listeners...");
    notifyListeners();
  }

  // Handle Login and update state globally
  Future<String?> login(String phone, String password) async {
    print("DEBUG: [AuthProvider] Calling AuthService.login...");
    final response = await AuthService.login(phone, password);

    if (response.containsKey('error')) {
      print("DEBUG: [AuthProvider] Login failed with error: ${response['error']}");
      return response['error'];
    }

    // Save role to secure storage so it survives app restarts
    final role = response['user']['role'];
    print("DEBUG: [AuthProvider] Login successful. Saving role: $role");
    await _storage.write(key: 'user_role', value: role);

    _isAuthenticated = true;
    _userRole = role;

    print("DEBUG: [AuthProvider] State updated. Notifying listeners (triggering GoRouter)...");
    notifyListeners(); // This tells the app to redraw and GoRouter to redirect

    return null; // Null means success
  }

  // Handle Logout
  Future<void> logout() async {
    print("DEBUG: [AuthProvider] Executing logout...");
    await AuthService.logout();
    await _storage.delete(key: 'user_role');

    _isAuthenticated = false;
    _userRole = null;
    print("DEBUG: [AuthProvider] Logout complete. Notifying listeners...");
    notifyListeners();
  }
}