// lib/core/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib/core/providers/language_provider.dart
const Map<String, Map<String, String>> _translations = {
  'en': {
    'dashboard': 'Farmer Dashboard',
    'weather': 'Live Hyperlocal Weather',
    'active_crops': 'My Active Crops',
    'recent_enquiries': 'Recent Buyer Enquiries',
    'sell_produce': 'Sell Produce',
    'add_expense': 'Add Expense',
    // New Marketplace Keys
    'publish_title': 'Publish Produce for Sale',
    'produce_title_label': 'Produce Title (e.g. Fresh Organic Tomatoes)',
    'quantity_label': 'Quantity',
    'unit_label': 'Unit',
    'price_label': 'Price per Unit (₹)',
    'location_label': 'Location / Market Area',
    'publish_btn': 'Publish to Marketplace',
  },
  'mr': { // Marathi
    'dashboard': 'शेतकरी डॅशबोर्ड',
    'weather': 'थेट हवामान',
    'active_crops': 'माझी सक्रिय पिके',
    'recent_enquiries': 'अलीकडील खरेदीदार चौकशी',
    'sell_produce': 'शेतमाल विका',
    'add_expense': 'खर्च जोडा',
    // New Marketplace Keys
    'publish_title': 'शेतमाल विक्रीसाठी नोंदवा',
    'produce_title_label': 'उत्पादनाचे शीर्षक (उदा. ताजे टोमॅटो)',
    'quantity_label': 'प्रमाण',
    'unit_label': 'युनिट',
    'price_label': 'प्रति युनिट किंमत (₹)',
    'location_label': 'स्थान / बाजार समिती',
    'publish_btn': 'बाजारपेठेत प्रकाशित करा',
  },
  'hi': { // Hindi
    'dashboard': 'किसान डैशबोर्ड',
    'weather': 'लाइव मौसम',
    'active_crops': 'मेरी सक्रिय फसलें',
    'recent_enquiries': 'हाल की खरीदार पूछताछ',
    'sell_produce': 'उपज बेचें',
    'add_expense': 'खर्च जोड़ें',
    // New Marketplace Keys
    'publish_title': 'बिक्री के लिए उपज प्रकाशित करें',
    'produce_title_label': 'उत्पाद शीर्षक (जैसे ताजे टमाटर)',
    'quantity_label': 'मात्रा',
    'unit_label': 'इकाई',
    'price_label': 'प्रति इकाई मूल्य (₹)',
    'location_label': 'स्थान / बाजार क्षेत्र',
    'publish_btn': 'मार्केटप्लेस पर प्रकाशित करें',
  }
};

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en'; // Default language

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String languageCode) {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }
}

// Extension to make calling translations incredibly short in your UI
extension LanguageExtension on BuildContext {
  String tr(String key) {
    return watch<LanguageProvider>().translate(key);
  }
}