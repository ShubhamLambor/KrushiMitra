// lib/features/auth/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // NEW
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthService {
  static final DioClient _dioClient = DioClient();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // --- REGISTER ---
  static Future<Map<String, dynamic>> register(String name, String phone, String password, String role) async {
    print("DEBUG: [AuthService] Starting register request for phone: $phone");
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'phone': phone,
          'password': password,
          'role': role,
        },
      );
      print("DEBUG: [AuthService] Register API Response Status: ${response.statusCode}");
      return response.data;
    } on DioException catch (e) {
      print("DEBUG: [AuthService] Register DioException: ${e.message}");
      // Use a generic error message fallback if AppStrings is not defined in this scope
      final errorMessage = e.response?.data['error'] ?? e.message ?? 'Registration failed';
      return {'error': errorMessage};
    } catch (e) {
      print("DEBUG: [AuthService] Register General Exception: $e");
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // --- LOGIN ---
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    print("DEBUG: [AuthService] Starting login request for phone: $phone");
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {
          'phone': phone,
          'password': password,
        },
      );

      print("DEBUG: [AuthService] API Response Status: ${response.statusCode}");
      print("DEBUG: [AuthService] API Response Data: ${response.data}");

      final data = response.data;

      // If login is successful, save the JWT token securely
      if (response.statusCode == 200 && data.containsKey('token')) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        print("DEBUG: [AuthService] Token successfully saved to secure storage.");

        // NEW: Automatically update the FCM token immediately after saving the JWT
        await updateFcmToken();
      } else {
        print("DEBUG: [AuthService] Warning: Status 200 but no token in response.");
      }

      return data;
    } on DioException catch (e) {
      print("DEBUG: [AuthService] Login DioException Caught: ${e.message}");
      print("DEBUG: [AuthService] Login DioException Response: ${e.response?.data}");

      final errorMessage = e.response?.data['error'] ?? e.message ?? 'Unknown error';
      return {'error': errorMessage};
    } catch (e) {
      print("DEBUG: [AuthService] Login General Exception Caught: $e");
      return {'error': 'Failed to connect to server: $e'};
    }
  }

// --- UPDATE FCM TOKEN ---
  static Future<void> updateFcmToken() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        print("DEBUG: [AuthService] Could not get FCM token from device.");
        return;
      }

      String? jwtToken = await _storage.read(key: 'jwt_token');
      if (jwtToken == null) {
        print("DEBUG: [AuthService] No JWT token found, skipping FCM update.");
        return;
      }

      // FIXED: Using ApiConstants.fcmToken
      final response = await _dioClient.dio.patch(
        ApiConstants.fcmToken,
        data: {'fcm_token': fcmToken},
        options: Options(
          headers: {'Authorization': 'Bearer $jwtToken'},
        ),
      );

      if (response.statusCode == 200) {
        print('✅ FCM Token successfully saved to database!');
      }
    } catch (e) {
      print('❌ Error sending FCM token: $e');
    }
  }

  // --- LOGOUT ---
  static Future<void> logout() async {
    print("DEBUG: [AuthService] Logging out and clearing FCM token...");
    try {
      String? jwtToken = await _storage.read(key: 'jwt_token');

      if (jwtToken != null) {
        // FIXED: Using ApiConstants.logout
        await _dioClient.dio.post(
          ApiConstants.logout,
          options: Options(
            headers: {'Authorization': 'Bearer $jwtToken'},
          ),
        );
        print("DEBUG: [AuthService] Successfully cleared FCM token on backend.");
      }
    } catch (e) {
      print('❌ Error clearing FCM token on backend: $e');
    } finally {
      await _storage.delete(key: 'jwt_token');
      print("DEBUG: [AuthService] Local JWT deleted.");
    }
  }
}