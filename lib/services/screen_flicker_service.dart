import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenFlickerService {
  OverlayEntry? _overlayEntry;
  bool _isTransmitting = false;

  Future<void> transmitMessage(
    String binaryData,
    int bitDuration,
    {Function(double)? onProgress}
  ) async {
    if (_isTransmitting) return;
    
    _isTransmitting = true;
    
    try {
      // Create fullscreen overlay
      _createFlickerOverlay();
      
      // Transmit each bit
      for (int i = 0; i < binaryData.length; i++) {
        if (!_isTransmitting) break;
        
        String bit = binaryData[i];
        await _flickerBit(bit, bitDuration);
        
        // Update progress
        onProgress?.call((i + 1) / binaryData.length);
      }
      
      // Final black screen
      await _flickerBit('0', bitDuration);
      
    } finally {
      _removeFlickerOverlay();
      _isTransmitting = false;
    }
  }

  Future<void> _flickerBit(String bit, int duration) async {
    Color color = bit == '1' ? Colors.white : Colors.black;
    
    _updateFlickerColor(color);
    await Future.delayed(Duration(milliseconds: duration));
  }

  void _createFlickerOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => FlickerOverlay(),
    );
    
    // We need to get the overlay from the current context
    // This is a simplified version - in a real app you'd need proper context management
  }

  void _updateFlickerColor(Color color) {
    // Update the overlay color
    // This would need to be implemented with proper state management
  }

  void _removeFlickerOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void dispose() {
    _isTransmitting = false;
    _removeFlickerOverlay();
  }
}

class FlickerOverlay extends StatefulWidget {
  @override
  _FlickerOverlayState createState() => _FlickerOverlayState();
}

class _FlickerOverlayState extends State<FlickerOverlay> {
  Color _currentColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: _currentColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb,
                size: 64,
                color: _currentColor == Colors.white ? Colors.black : Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Transmitting...',
                style: TextStyle(
                  fontSize: 24,
                  color: _currentColor == Colors.white ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Keep this screen visible to receiver',
                style: TextStyle(
                  fontSize: 16,
                  color: _currentColor == Colors.white ? Colors.black54 : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateColor(Color color) {
    setState(() {
      _currentColor = color;
    });
  }
}
