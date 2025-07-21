import 'dart:convert';
import 'dart:typed_data';

class EncoderDecoderService {
  // Sync patterns
  static const String START_PATTERN = '11110000';
  static const String END_PATTERN = '00001111';
  
  /// Encodes a text message into Manchester-encoded binary with sync patterns
  String encodeMessage(String message) {
    try {
      // Convert message to UTF-8 bytes
      List<int> messageBytes = utf8.encode(message);
      
      // Convert bytes to binary string
      String binaryMessage = '';
      for (int byte in messageBytes) {
        binaryMessage += byte.toRadixString(2).padLeft(8, '0');
      }
      
      // Apply Manchester encoding
      String manchesterEncoded = _manchesterEncode(binaryMessage);
      
      // Add sync patterns
      String fullMessage = START_PATTERN + manchesterEncoded + END_PATTERN;
      
      return fullMessage;
    } catch (e) {
      throw Exception('Encoding failed: $e');
    }
  }
  
  /// Decodes Manchester-encoded binary back to text message
  String decodeMessage(String encodedBits) {
    try {
      // Remove sync patterns if present
      String cleanBits = encodedBits;
      if (cleanBits.startsWith(START_PATTERN)) {
        cleanBits = cleanBits.substring(START_PATTERN.length);
      }
      if (cleanBits.endsWith(END_PATTERN)) {
        cleanBits = cleanBits.substring(0, cleanBits.length - END_PATTERN.length);
      }
      
      // Decode Manchester encoding
      String binaryMessage = _manchesterDecode(cleanBits);
      
      // Convert binary to bytes
      List<int> messageBytes = [];
      for (int i = 0; i < binaryMessage.length; i += 8) {
        if (i + 8 <= binaryMessage.length) {
          String byteBinary = binaryMessage.substring(i, i + 8);
          int byteValue = int.parse(byteBinary, radix: 2);
          messageBytes.add(byteValue);
        }
      }
      
      // Convert bytes to UTF-8 string
      String decodedMessage = utf8.decode(messageBytes);
      
      return decodedMessage;
    } catch (e) {
      throw Exception('Decoding failed: $e');
    }
  }
  
  /// Manchester encoding: 0 -> 10, 1 -> 01
  String _manchesterEncode(String binaryData) {
    String encoded = '';
    for (int i = 0; i < binaryData.length; i++) {
      if (binaryData[i] == '0') {
        encoded += '10';
      } else {
        encoded += '01';
      }
    }
    return encoded;
  }
  
  /// Manchester decoding: 10 -> 0, 01 -> 1
  String _manchesterDecode(String manchesterData) {
    String decoded = '';
    
    // Ensure even length
    if (manchesterData.length % 2 != 0) {
      manchesterData = manchesterData.substring(0, manchesterData.length - 1);
    }
    
    for (int i = 0; i < manchesterData.length; i += 2) {
      if (i + 1 < manchesterData.length) {
        String pair = manchesterData.substring(i, i + 2);
        if (pair == '10') {
          decoded += '0';
        } else if (pair == '01') {
          decoded += '1';
        } else {
          // Invalid Manchester pair - try to recover
          // This could be due to transmission errors
          print('Invalid Manchester pair: $pair at position $i');
          // Skip this pair or use error correction
        }
      }
    }
    
    return decoded;
  }
  
  /// Validates if a binary string is valid Manchester encoding
  bool isValidManchesterEncoding(String data) {
    if (data.length % 2 != 0) return false;
    
    for (int i = 0; i < data.length; i += 2) {
      if (i + 1 < data.length) {
        String pair = data.substring(i, i + 2);
        if (pair != '10' && pair != '01') {
          return false;
        }
      }
    }
    
    return true;
  }
  
  /// Calculates expected transmission time in milliseconds
  int calculateTransmissionTime(String message, int bitDurationMs) {
    String encoded = encodeMessage(message);
    return encoded.length * bitDurationMs;
  }
  
  /// Estimates bitrate for given settings
  double calculateBitrate(int bitDurationMs) {
    return 1000.0 / bitDurationMs; // bits per second
  }
  
  /// Adds error correction bits (simple parity)
  String addErrorCorrection(String data) {
    // Simple even parity bit for each byte
    String corrected = '';
    for (int i = 0; i < data.length; i += 8) {
      if (i + 8 <= data.length) {
        String byte = data.substring(i, i + 8);
        int ones = byte.split('1').length - 1;
        String parityBit = (ones % 2 == 0) ? '0' : '1';
        corrected += byte + parityBit;
      }
    }
    return corrected;
  }
  
  /// Checks and corrects errors using parity bits
  String checkErrorCorrection(String data) {
    String corrected = '';
    for (int i = 0; i < data.length; i += 9) {
      if (i + 9 <= data.length) {
        String byteWithParity = data.substring(i, i + 9);
        String byte = byteWithParity.substring(0, 8);
        String parityBit = byteWithParity.substring(8, 9);
        
        int ones = byte.split('1').length - 1;
        String expectedParity = (ones % 2 == 0) ? '0' : '1';
        
        if (parityBit == expectedParity) {
          corrected += byte;
        } else {
          print('Parity error detected in byte: $byte');
          // Could implement error correction here
          corrected += byte; // For now, just use the byte as-is
        }
      }
    }
    return corrected;
  }
}
