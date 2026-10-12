// lib/features/crop_manager/services/crop_service.dart
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class CropService {
  static final DioClient _dioClient = DioClient();

  // 1. Fetch active crops (supports both getCrops and getActiveCrops)
  static Future<List<dynamic>> getCrops() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.crops);
      if (response.statusCode == 200) {
        // Safely extract the crops list whether wrapped or returned directly
        if (response.data is Map) {
          return response.data['crops'] ?? [];
        } else if (response.data is List) {
          return response.data;
        }
      }
      return [];
    } catch (e) {
      print("DEBUG: [CropService] Error fetching crops: $e");
      return [];
    }
  }

  // Alias for backward compatibility
  static Future<List<dynamic>> getActiveCrops() async {
    return getCrops();
  }

  // 2. Add an expense for a specific crop
  static Future<String?> addExpense({
    required int cropId,
    required String category,
    required double amount,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.expenses,
        data: {
          'crop_id': cropId,
          'category': category,
          'amount': amount,
        },
      );

      if (response.statusCode == 201) {
        return null; // Success (null error)
      }
      return 'Failed to record expense';
    } on DioException catch (e) {
      return e.response?.data['error'] ?? 'Failed to connect to server';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // 3. Fetch all expenses (List of transactions for Pie Chart & List)
  static Future<List<dynamic>?> getExpenses() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.expenses);
      if (response.statusCode == 200) {
        return response.data['expenses'] ?? response.data;
      }
      return null;
    } catch (e) {
      print("DEBUG: [CropService] Error fetching expenses: $e");
      return null;
    }
  }

  // 4. Fetch expense analytics and category breakdown (Pre-calculated by backend)
  static Future<Map<String, dynamic>?> getExpenseSummary() async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.expenses}/summary');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      print("DEBUG: [CropService] API Error in summary: $e");
      return null;
    } catch (e) {
      print("DEBUG: [CropService] Unknown Error in summary: $e");
      return null;
    }
  }

  // 5. Add a new crop to the farmer's profile
  static Future<String?> addCrop({
    required String cropName,
    required double area,
    required String sownDate,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.crops, // Assuming ApiConstants.crops points to '/crops'
        data: {
          'crop_name': cropName,
          'area': area,
          'sown_date': sownDate,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success
      }
      return 'Failed to add crop';
    } on DioException catch (e) {
      return e.response?.data['error'] ?? 'Failed to connect to server';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}