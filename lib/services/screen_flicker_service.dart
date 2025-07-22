import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenFlickerService {
  bool _isTransmitting = false;

  Future<void> transmitMessage(
    String binaryData,
    int bitDuration,
    {Function(double)? onProgress, required BuildContext context}
  ) async {
    if (_isTransmitting) return;
    
    _isTransmitting = true;
    
    try {
      // Navigate to fullscreen flicker view
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlickerScreen(
            binaryData: binaryData,
            bitDuration: bitDuration,
            onProgress: onProgress,
          ),
        ),
      );
      
    } finally {
      _isTransmitting = false;
    }
  }

  void dispose() {
    _isTransmitting = false;
  }
}

class FlickerScreen extends StatefulWidget {
  final String binaryData;
  final int bitDuration;
  final Function(double)? onProgress;

  const FlickerScreen({
    Key? key,
    required this.binaryData,
    required this.bitDuration,
    this.onProgress,
  }) : super(key: key);

  @override
  _FlickerScreenState createState() => _FlickerScreenState();
}

class _FlickerScreenState extends State<FlickerScreen> {
  Color _currentColor = Colors.black;
  int _currentBitIndex = 0;
  bool _isTransmitting = true;

  @override
  void initState() {
    super.initState();
    _startTransmission();
  }

  Future<void> _startTransmission() async {
    // Set screen to maximum brightness
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    for (int i = 0; i < widget.binaryData.length && _isTransmitting; i++) {
      String bit = widget.binaryData[i];
      
      setState(() {
        _currentColor = bit == '1' ? Colors.white : Colors.black;
        _currentBitIndex = i;
      });
      
      await Future.delayed(Duration(milliseconds: widget.bitDuration));
      
      // Update progress
      widget.onProgress?.call((i + 1) / widget.binaryData.length);
    }
    
    // Final black screen
    setState(() {
      _currentColor = Colors.black;
    });
    
    await Future.delayed(Duration(milliseconds: 500));
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _isTransmitting = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentColor,
      body: Container(
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
                'Bit ${_currentBitIndex + 1} of ${widget.binaryData.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: _currentColor == Colors.white ? Colors.black54 : Colors.white70,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Keep screen visible to receiver',
                style: TextStyle(
                  fontSize: 14,
                  color: _currentColor == Colors.white ? Colors.black54 : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
