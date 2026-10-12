// lib/features/marketplace/services/marketplace_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class MarketplaceService {
  static final DioClient _dioClient = DioClient();

  // Publish a new crop listing for buyers (Updated to use Dio FormData)
  static Future<String?> publishListing({
    required String title,
    required String description,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    required String location,
    File? imageFile, // Accepts an optional image file
  }) async {
    try {
      // Create Dio FormData payload
      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'location': location,
      });

      // Attach image file if it exists
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path, filename: fileName),
        ));
      }

      // Send the request using DioClient
      final response = await _dioClient.dio.post(
        ApiConstants.marketplace,
        data: formData,
      );

      if (response.statusCode == 201) {
        return null; // Success
      } else {
        return response.data['error'] ?? 'Failed to publish listing';
      }
    } on DioException catch (e) {
      return e.response?.data['error'] ?? 'Network error occurred: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Fetch active marketplace listings for buyers (UPDATED: Added Search & Filters)
  static Future<List<dynamic>?> getListings({
    String? search,
    String? location,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.marketplace,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (location != null && location.isNotEmpty) 'location': location,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
        },
      );
      if (response.statusCode == 200) {
        return response.data['listings'] as List<dynamic>;
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  // Fetch listings published specifically by the logged-in farmer
  static Future<List<dynamic>?> getFarmerListings() async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.marketplace}/my-listings');
      if (response.statusCode == 200) {
        if (response.data is Map) {
          return response.data['listings'] ?? [];
        } else if (response.data is List) {
          return response.data;
        }
      }
      return [];
    } catch (e) {
      print("DEBUG: [MarketplaceService] Error fetching farmer listings: $e");
      return [];
    }
  }

  // Send an order/enquiry to a farmer
  static Future<String?> sendEnquiry({
    required int listingId,
    required double quantity,
    required String message,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.enquiries,
        data: {
          'listing_id': listingId,
          'quantity': quantity,
          'message': message,
        },
      );
      if (response.statusCode == 201) return null;
      return 'Failed to send enquiry';
    } on DioException catch (e) {
      return e.response?.data['error'] ?? 'Failed to connect to server';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Fetch incoming enquiries for farmers
  static Future<List<dynamic>?> getFarmerEnquiries() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.enquiries);
      if (response.statusCode == 200) {
        return response.data['enquiries'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update enquiry status (ACCEPTED / REJECTED)
  static Future<String?> updateEnquiryStatus({
    required int enquiryId,
    required String status,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        '${ApiConstants.enquiries}/$enquiryId/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) return null;
      return 'Failed to update status';
    } on DioException catch (e) {
      return e.response?.data['error'] ?? 'Network error occurred';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Fetch orders/enquiries for the logged-in Buyer
  static Future<List<dynamic>?> getBuyerOrders() async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.enquiries}/buyer');
      if (response.statusCode == 200) {
        return response.data['orders'] ?? [];
      }
      return null;
    } catch (e) {
      print("Error fetching buyer orders: $e");
      return null;
    }
  }
}