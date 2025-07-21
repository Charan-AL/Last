import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/camera_receiver_service.dart';
import '../services/encoder_decoder_service.dart';
import '../main.dart';

class ReceiverScreen extends StatefulWidget {
  @override
  _ReceiverScreenState createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  CameraController? _cameraController;
  CameraReceiverService? _receiverService;
  final EncoderDecoderService _encoderService = EncoderDecoderService();
  
  bool _isReceiving = false;
  String _statusMessage = 'Initializing camera...';
  String _receivedBits = '';
  String _decodedMessage = '';
  double _brightness = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _receiverService?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      setState(() {
        _statusMessage = 'No cameras available';
      });
      return;
    }

    try {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      _receiverService = CameraReceiverService(_cameraController!);
      
      setState(() {
        _statusMessage = 'Camera ready - Tap to start receiving';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Camera initialization failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📥 Receive Message'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera Preview
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              child: _cameraController?.value.isInitialized == true
                  ? Stack(
                      children: [
                        CameraPreview(_cameraController!),
                        // Detection Area Overlay
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isReceiving ? Colors.green : Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'SCAN\nAREA',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Brightness Indicator
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Brightness: ${(_brightness * 100).toInt()}%',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(_statusMessage),
                        ],
                      ),
                    ),
            ),
          ),
          
          // Controls and Status
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Status
                Container(
                  width: double.infinity,
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
                          Icon(
                            _isReceiving ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: _isReceiving ? Colors.green : Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _statusMessage,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (_receivedBits.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          'Bits: ${_receivedBits.length > 50 ? _receivedBits.substring(0, 50) + '...' : _receivedBits}',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Control Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cameraController?.value.isInitialized == true
                        ? (_isReceiving ? _stopReceiving : _startReceiving)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isReceiving ? Colors.red : Color(0xFF00C853),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isReceiving ? Icons.stop : Icons.play_arrow),
                        SizedBox(width: 8),
                        Text(_isReceiving ? 'Stop Receiving' : 'Start Receiving'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Received Messages
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(20),
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
                    'Received Messages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: Consumer<AppProvider>(
                      builder: (context, provider, child) {
                        if (provider.lastReceivedMessage.isEmpty) {
                          return Center(
                            child: Text(
                              'No messages received yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        }
                        
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF00C853).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Color(0xFF00C853).withOpacity(0.3)),
                                ),
                                child: Text(
                                  provider.lastReceivedMessage,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 12),
                              ...provider.messageHistory
                                  .where((msg) => msg.startsWith('📥'))
                                  .take(5)
                                  .map((msg) => Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          msg,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      )),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startReceiving() async {
    if (_receiverService == null) return;

    setState(() {
      _isReceiving = true;
      _statusMessage = 'Scanning for light signals...';
      _receivedBits = '';
      _decodedMessage = '';
    });

    try {
      await _receiverService!.startReceiving(
        onBrightnessChange: (brightness) {
          setState(() {
            _brightness = brightness;
          });
        },
        onBitReceived: (bit) {
          setState(() {
            _receivedBits += bit;
            _statusMessage = 'Receiving... ${_receivedBits.length} bits';
          });
        },
        onMessageDecoded: (message) {
          final provider = Provider.of<AppProvider>(context, listen: false);
          provider.addReceivedMessage(message);
          
          setState(() {
            _decodedMessage = message;
            _statusMessage = 'Message received successfully!';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Message received: $message'),
              backgroundColor: Color(0xFF00C853),
            ),
          );
        },
        onError: (error) {
          setState(() {
            _statusMessage = 'Error: $error';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Reception error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to start receiving: $e';
        _isReceiving = false;
      });
    }
  }

  void _stopReceiving() {
    _receiverService?.stopReceiving();
    setState(() {
      _isReceiving = false;
      _statusMessage = 'Reception stopped';
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📖 How to Receive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Point camera at the sending device screen'),
            SizedBox(height: 8),
            Text('2. Keep 1-3 feet distance for best results'),
            SizedBox(height: 8),
            Text('3. Align the scan area with the flicker source'),
            SizedBox(height: 8),
            Text('4. Tap "Start Receiving" and wait for transmission'),
            SizedBox(height: 8),
            Text('5. Keep steady until message is complete'),
            SizedBox(height: 16),
            Text(
              '💡 Tip: Avoid bright ambient light and keep the camera steady',
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
