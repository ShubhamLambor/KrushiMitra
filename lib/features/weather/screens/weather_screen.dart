// lib/features/weather/screens/weather_screen.dart
import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await WeatherService.getWeather();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (data != null) {
        _weatherData = data;
      } else {
        _errorMessage = "Could not fetch weather data. Please check your connection.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Farm Weather',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeather,
          ),
        ],
      ),
      body: _buildBody(primaryColor),
    );
  }

  Widget _buildBody(Color primaryColor) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            const Text("Locating your farm...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchWeather,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    if (_weatherData == null) return const SizedBox.shrink();

    // Parse OpenWeatherMap JSON
    final cityName = _weatherData!['name'] ?? 'Unknown Location';
    final temp = _weatherData!['main']['temp'];
    final humidity = _weatherData!['main']['humidity'];
    final description = _weatherData!['weather'][0]['description'].toString().toUpperCase();
    final iconCode = _weatherData!['weather'][0]['icon'];

    // OpenWeatherMap puts rain in a nested object if it exists
    final rainData = _weatherData!['rain'];
    final precip = rainData != null ? (rainData['1h'] ?? rainData['3h'] ?? 0.0) : 0.0;

    // Generate smart advisory
    final advisoryText = WeatherService.getAdvisory(temp, precip, humidity);

    return RefreshIndicator(
      onRefresh: _fetchWeather,
      color: primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Main Weather Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  cityName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://openweathermap.org/img/wn/$iconCode@4x.png',
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.wb_sunny, size: 80, color: Colors.amber),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${temp.round()}°C',
                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Smart Advisory Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agronomic Advisory',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        advisoryText,
                        style: TextStyle(color: Colors.blue.shade800, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Detail Cards
          Row(
            children: [
              _buildDetailCard(Icons.water_drop, 'Humidity', '$humidity%', Colors.blue),
              const SizedBox(width: 16),
              _buildDetailCard(Icons.umbrella, 'Rain (1h)', '${precip}mm', Colors.indigo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }
}