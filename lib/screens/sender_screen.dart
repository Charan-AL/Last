import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/screen_flicker_service.dart';
import '../services/encoder_decoder_service.dart';

class SenderScreen extends StatefulWidget {
  @override
  _SenderScreenState createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScreenFlickerService _flickerService = ScreenFlickerService();
  final EncoderDecoderService _encoderService = EncoderDecoderService();
  
  bool _isTransmitting = false;
  double _progress = 0.0;
  String _statusMessage = 'Ready to send';

  @override
  void dispose() {
    _messageController.dispose();
    _flickerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🚀 Send Message'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Message Input
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your message:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Transmission Controls
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.speed, color: Color(0xFF0077FF)),
                          SizedBox(width: 8),
                          Text('Speed: ${provider.flickerSpeed}ms/bit'),
                          Spacer(),
                          if (provider.isEncryptionEnabled)
                            Row(
                              children: [
                                Icon(Icons.lock, color: Color(0xFF00C853), size: 16),
                                Text(' Encrypted', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (_isTransmitting) ...[
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0077FF)),
                        ),
                        SizedBox(height: 8),
                        Text(_statusMessage, style: TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                );
              },
            ),
            
            SizedBox(height: 30),
            
            // Send Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isTransmitting ? null : _sendMessage,
                child: _isTransmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Transmitting...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('Send Message'),
                        ],
                      ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Message History
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Message History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            if (provider.messageHistory.isNotEmpty)
                              TextButton(
                                onPressed: provider.clearHistory,
                                child: Text('Clear'),
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: provider.messageHistory.isEmpty
                              ? Center(
                                  child: Text(
                                    'No messages sent yet',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: provider.messageHistory.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        provider.messageHistory[index],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() {
      _isTransmitting = true;
      _progress = 0.0;
      _statusMessage = 'Encoding message...';
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      String message = _messageController.text.trim();
      
      // Encode message
      String encodedBits = _encoderService.encodeMessage(message);
      
      setState(() {
        _statusMessage = 'Starting transmission...';
      });

      // Start transmission
      await _flickerService.transmitMessage(
        encodedBits,
        provider.flickerSpeed,
        context: context,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
            _statusMessage = 'Transmitting... ${(progress * 100).toInt()}%';
          });
        },
      );

      // Add to history
      provider.addSentMessage(message);
      
      setState(() {
        _statusMessage = 'Transmission complete!';
      });

      // Show success feedback
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Message sent successfully!'),
          backgroundColor: Color(0xFF00C853),
        ),
      );

      // Clear input
      _messageController.clear();

    } catch (e) {
      setState(() {
        _statusMessage = 'Transmission failed: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Transmission failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTransmitting = false;
      });
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📖 How to Send'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Type your message in the text field'),
            SizedBox(height: 8),
            Text('2. Position the receiving device 1-3 feet away'),
            SizedBox(height: 8),
            Text('3. Ensure good lighting conditions'),
            SizedBox(height: 8),
            Text('4. Tap "Send Message" to start transmission'),
            SizedBox(height: 8),
            Text('5. Keep the screen visible to the receiver'),
            SizedBox(height: 16),
            Text(
              '💡 Tip: Use slower speeds (higher ms/bit) for better reliability',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
