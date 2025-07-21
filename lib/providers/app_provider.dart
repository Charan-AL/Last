import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isEncryptionEnabled = false;
  int _flickerSpeed = 200; // milliseconds per bit
  String _lastReceivedMessage = '';
  List<String> _messageHistory = [];
  Map<String, dynamic> _analytics = {
    'totalMessages': 0,
    'successfulTransmissions': 0,
    'averageBitrate': 0.0,
    'lastTransmissionTime': 0,
  };

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isEncryptionEnabled => _isEncryptionEnabled;
  int get flickerSpeed => _flickerSpeed;
  String get lastReceivedMessage => _lastReceivedMessage;
  List<String> get messageHistory => _messageHistory;
  Map<String, dynamic> get analytics => _analytics;

  // Setters
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleEncryption() {
    _isEncryptionEnabled = !_isEncryptionEnabled;
    notifyListeners();
  }

  void setFlickerSpeed(int speed) {
    _flickerSpeed = speed.clamp(50, 1000);
    notifyListeners();
  }

  void addReceivedMessage(String message) {
    _lastReceivedMessage = message;
    _messageHistory.insert(0, '📥 ${DateTime.now().toString().substring(11, 19)}: $message');
    _analytics['totalMessages']++;
    notifyListeners();
  }

  void addSentMessage(String message) {
    _messageHistory.insert(0, '📤 ${DateTime.now().toString().substring(11, 19)}: $message');
    _analytics['totalMessages']++;
    _analytics['successfulTransmissions']++;
    notifyListeners();
  }

  void updateAnalytics(Map<String, dynamic> data) {
    _analytics.addAll(data);
    notifyListeners();
  }

  void clearHistory() {
    _messageHistory.clear();
    notifyListeners();
  }
}
