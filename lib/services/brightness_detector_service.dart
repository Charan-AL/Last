import 'dart:typed_data';
import 'package:camera/camera.dart';

class BrightnessDetectorService {
  double detectBrightness(CameraImage image) {
    try {
      // Get image dimensions
      int width = image.width;
      int height = image.height;
      
      // Calculate center region (100x100 pixels)
      int centerX = width ~/ 2;
      int centerY = height ~/ 2;
      int regionSize = 50; // 50 pixels in each direction from center
      
      // Get Y plane (luminance) from YUV420 format
      Uint8List yPlane = image.planes[0].bytes;
      int yRowStride = image.planes[0].bytesPerRow;
      
      double totalBrightness = 0.0;
      int pixelCount = 0;
      
      // Sample pixels in center region
      for (int y = centerY - regionSize; y < centerY + regionSize; y++) {
        if (y < 0 || y >= height) continue;
        
        for (int x = centerX - regionSize; x < centerX + regionSize; x++) {
          if (x < 0 || x >= width) continue;
          
          int pixelIndex = y * yRowStride + x;
          if (pixelIndex < yPlane.length) {
            totalBrightness += yPlane[pixelIndex];
            pixelCount++;
          }
        }
      }
      
      if (pixelCount == 0) return 0.0;
      
      // Normalize brightness to 0-1 range
      double averageBrightness = totalBrightness / pixelCount;
      return averageBrightness / 255.0;
      
    } catch (e) {
      print('Brightness detection error: $e');
      return 0.0;
    }
  }
  
  // Alternative method using RGB if needed
  double detectBrightnessRGB(List<int> rgbPixels, int width, int height) {
    int centerX = width ~/ 2;
    int centerY = height ~/ 2;
    int regionSize = 50;
    
    double totalBrightness = 0.0;
    int pixelCount = 0;
    
    for (int y = centerY - regionSize; y < centerY + regionSize; y++) {
      if (y < 0 || y >= height) continue;
      
      for (int x = centerX - regionSize; x < centerX + regionSize; x++) {
        if (x < 0 || x >= width) continue;
        
        int pixelIndex = (y * width + x) * 3; // RGB = 3 bytes per pixel
        if (pixelIndex + 2 < rgbPixels.length) {
          int r = rgbPixels[pixelIndex];
          int g = rgbPixels[pixelIndex + 1];
          int b = rgbPixels[pixelIndex + 2];
          
          // Calculate luminance using standard formula
          double luminance = 0.299 * r + 0.587 * g + 0.114 * b;
          totalBrightness += luminance;
          pixelCount++;
        }
      }
    }
    
    if (pixelCount == 0) return 0.0;
    
    return (totalBrightness / pixelCount) / 255.0;
  }
}
