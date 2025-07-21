import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'brightness_detector_service.dart';
import 'encoder_decoder_service.dart';

class CameraReceiverService {
  final CameraController _cameraController;
  final BrightnessDetectorService _brightnessDetector = BrightnessDetectorService();
  final EncoderDecoderService _encoderDecoder = EncoderDecoderService();
  
  StreamSubscription? _imageStreamSubscription;
  bool _isReceiving = false;
  String _receivedBits = '';
  String _lastBit = '';
  int _bitCount = 0;
  DateTime _lastBitTime = DateTime.now();
  
  // Sync pattern detection
  final String _startPattern = '11110000';
  final String _endPattern = '00001111';
  bool _syncDetected = false;
  bool _messageStarted = false;

  CameraReceiverService(this._cameraController);

  Future<void> startReceiving({
    required Function(double) onBrightnessChange,
    required Function(String) onBitReceived,
    required Function(String) onMessageDecoded,
    required Function(String) onError,
  }) async {
    if (_isReceiving) return;
    
    _isReceiving = true;
    _receivedBits = '';
    _syncDetected = false;
    _messageStarted = false;
    _bitCount = 0;

    try {
      await _cameraController.startImageStream((CameraImage image) {
        if (!_isReceiving) return;
        
        _processImage(
          image,
          onBrightnessChange: onBrightnessChange,
          onBitReceived: onBitReceived,
          onMessageDecoded: onMessageDecoded,
          onError: onError,
        );
      });
    } catch (e) {
      onError('Failed to start camera stream: $e');
      _isReceiving = false;
    }
  }

  void _processImage(
    CameraImage image, {
    required Function(double) onBrightnessChange,
    required Function(String) onBitReceived,
    required Function(String) onMessageDecoded,
    required Function(String) onError,
  }) {
    try {
      // Extract brightness from center region (100x100 pixels)
      double brightness = _brightnessDetector.detectBrightness(image);
      onBrightnessChange(brightness);
      
      // Convert brightness to bit
      String currentBit = brightness > 0.5 ? '1' : '0';
      
      // Debounce bit changes
      DateTime now = DateTime.now();
      if (currentBit != _lastBit && now.difference(_lastBitTime).inMilliseconds > 50) {
        _lastBit = currentBit;
        _lastBitTime = now;
        _receivedBits += currentBit;
        onBitReceived(currentBit);
        
        // Check for sync patterns
        if (!_syncDetected && _receivedBits.contains(_startPattern)) {
          _syncDetected = true;
          _messageStarted = true;
          // Remove everything before start pattern
          int startIndex = _receivedBits.lastIndexOf(_startPattern);
          _receivedBits = _receivedBits.substring(startIndex + _startPattern.length);
          onBitReceived('SYNC_START');
        }
        
        if (_syncDetected && _messageStarted && _receivedBits.contains(_endPattern)) {
          // Message complete
          int endIndex = _receivedBits.indexOf(_endPattern);
          String messageBits = _receivedBits.substring(0, endIndex);
          
          try {
            String decodedMessage = _encoderDecoder.decodeMessage(messageBits);
            onMessageDecoded(decodedMessage);
          } catch (e) {
            onError('Failed to decode message: $e');
          }
          
          // Reset for next message
          _receivedBits = '';
          _syncDetected = false;
          _messageStarted = false;
        }
        
        // Prevent buffer overflow
        if (_receivedBits.length > 10000) {
          _receivedBits = _receivedBits.substring(_receivedBits.length - 1000);
        }
      }
    } catch (e) {
      onError('Image processing error: $e');
    }
  }

  void stopReceiving() {
    _isReceiving = false;
    _cameraController.stopImageStream();
    _imageStreamSubscription?.cancel();
  }

  void dispose() {
    stopReceiving();
  }
}
