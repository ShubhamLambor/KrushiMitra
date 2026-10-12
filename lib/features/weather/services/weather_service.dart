// lib/features/weather/services/weather_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static final Dio _dio = Dio();
  static const String _apiKey = '7d69ff60eda8e8032e0551fec7ee1221';

  // Helper to get current device position with fallback to Pune (18.5204, 73.8567)
  static Future<Position> _determinePosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _defaultPunePosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _defaultPunePosition();
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _defaultPunePosition();
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      debugPrint('[Weather] Error obtaining position: $e');
      return _defaultPunePosition();
    }
  }

  static Position _defaultPunePosition() {
    return Position(
      latitude: 18.5204,
      longitude: 73.8567,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  // Fetch live weather from OpenWeatherMap and map keys for the UI
  static Future<Map<String, dynamic>?> getWeather() async {
    try {
      Position position = await _determinePosition();

      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': position.latitude,
          'lon': position.longitude,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Map OpenWeatherMap nested JSON to match dashboard keys cleanly
        return {
          'temperature_2m': data['main']?['temp'],
          'relative_humidity_2m': data['main']?['humidity'],
          'precipitation': data['rain']?['1h'] ?? data['rain']?['3h'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      debugPrint('[Weather] API Error: $e');
      return null;
    }
  }

  // Agronomic advisory generator
  static String getAdvisory(num? temp, num? precip, num? humidity) {
    if (precip != null && precip.toDouble() > 0.1) {
      return 'Rain detected ($precip mm). Hold off on fertilizer and pesticide spraying.';
    }
    if (temp != null && temp.toDouble() > 35) {
      return 'High temperature (${temp}°C). Ensure adequate irrigation for your crops.';
    }
    if (humidity != null && humidity.toDouble() > 85) {
      return 'High humidity (${humidity}%). Watch out for fungal risks in crops.';
    }
    return 'Weather conditions are favorable for field activities and irrigation.';
  }
}