class ApiConstants {

  static const String baseUrl = 'https://krushimitra-backend-732m.onrender.com/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String fcmToken = '/auth/fcm-token'; // NEW
  static const String logout = '/auth/logout'; // NEW
  static const String crops = '/crops';
  static const String expenses = '/expenses';
  static const String weather = '/weather';
  static const String marketplace = '/marketplace';
  static const String enquiries = '/enquiries';
}

class AppStrings {
  static const String appName = 'KrushiMitra';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
}