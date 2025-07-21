# 💡 WhisprNet - Talk in Light

**Offline • Anonymous • Anywhere**

WhisprNet is a revolutionary mobile app that enables completely offline, anonymous, secure device-to-device communication using visible light communication (VLC) with Manchester encoding. Send messages using screen flickers and receive them through camera-based decoding.

## 🌟 Features

### 🔁 Core Communication
- **Screen Flicker Transmission**: Converts text to binary and transmits using white/black screen flickers
- **Camera Reception**: Uses device camera to detect brightness changes and decode messages
- **Manchester Encoding**: Reliable encoding scheme (0→10, 1→01) for better signal integrity
- **Sync Pattern Detection**: Automatic message framing with start/end patterns
- **Real-time Processing**: Live brightness detection and bit decoding

### 🛡️ Security & Privacy
- **Completely Offline**: No internet connection required
- **Anonymous Communication**: No user accounts or tracking
- **Optional Encryption**: AES-128 encryption support (ready for implementation)
- **Local Processing**: All data processing happens on-device

### 📱 User Experience
- **Intuitive Interface**: Clean, modern design with emoji-enhanced buttons
- **Dark/Light Themes**: Automatic theme switching support
- **Real-time Feedback**: Live transmission progress and reception status
- **Message History**: Local storage of sent/received messages
- **Analytics Dashboard**: Transmission statistics and performance metrics

### ⚙️ Technical Features
- **Adjustable Speed**: Configurable flicker speed (50ms-1000ms per bit)
- **Error Detection**: Manchester encoding validation and error reporting
- **Brightness Calibration**: Automatic brightness threshold adjustment
- **Performance Optimization**: Efficient camera processing and battery management

## 🚀 Quick Start

### Installation
1. Download the APK from releases or build from source
2. Install on Android device (requires Android 6.0+)
3. Grant camera permissions when prompted
4. Start communicating!

### Basic Usage

#### Sending Messages
1. Open WhisprNet and tap "🚀 Send Message"
2. Type your message in the text field
3. Position receiving device 1-3 feet away
4. Tap "Send Message" to start transmission
5. Keep screen visible to receiver until complete

#### Receiving Messages
1. Tap "📥 Receive Message" from home screen
2. Point camera at sending device screen
3. Align the scan area with the flicker source
4. Tap "Start Receiving" and wait for transmission
5. Message will appear when successfully decoded

## 🔧 Technical Specifications

### Communication Protocol
\`\`\`
Transmission Format:
[Start Pattern: 11110000] + [Manchester Encoded Message] + [End Pattern: 00001111]

Manchester Encoding:
- Binary 0 → 10
- Binary 1 → 01

Flicker Mapping:
- White Screen = Binary 1
- Black Screen = Binary 0
\`\`\`

### Performance Targets
- **Bitrate**: ~10 characters/second (100ms per bit)
- **Range**: 1-3 feet optimal distance
- **Accuracy**: 90%+ under ideal conditions
- **Frame Rate**: 15-30 FPS camera processing

### System Requirements
- **Android**: 6.0+ (API level 23+)
- **Camera**: Rear-facing camera with autofocus
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 50MB for app installation

## 🛠️ Development

### Project Structure
\`\`\`
lib/
├── main.dart                    # App entry point
├── providers/
│   └── app_provider.dart       # State management
├── screens/
│   ├── home_screen.dart        # Main navigation
│   ├── sender_screen.dart      # Message transmission
│   └── receiver_screen.dart    # Message reception
└── services/
    ├── screen_flicker_service.dart      # Flicker transmission
    ├── camera_receiver_service.dart     # Camera processing
    ├── encoder_decoder_service.dart     # Manchester encoding
    └── brightness_detector_service.dart # Brightness analysis
\`\`\`

### Key Dependencies
- **Flutter**: 3.x framework
- **Provider**: State management
- **Camera**: Camera access and image processing
- **Permission Handler**: Runtime permissions

### Building from Source
\`\`\`bash
# Clone repository
git clone https://github.com/your-repo/whisprnet.git
cd whisprnet

# Install dependencies
flutter pub get

# Run on device
flutter run

# Build APK
flutter build apk --release
\`\`\`

## 📊 Use Cases

### Emergency Communication
- **Power Outages**: Communicate when cellular networks are down
- **Natural Disasters**: Emergency coordination without infrastructure
- **Remote Areas**: Communication in areas with no network coverage
- **Backup Communication**: Secondary channel when primary methods fail

### Privacy & Security
- **Anonymous Messaging**: No digital footprint or metadata
- **Secure Meetings**: Private communication in sensitive environments
- **Whistleblowing**: Secure information transfer without digital traces
- **Journalism**: Protected source communication

### Educational & Research
- **STEM Education**: Teaching optical communication principles
- **Research Projects**: Experimenting with VLC technology
- **Engineering Demos**: Showcasing Manchester encoding concepts
- **Academic Studies**: Analyzing optical communication performance

### Creative & Fun
- **Art Installations**: Interactive light-based communication art
- **Gaming**: Novel communication method for games
- **Social Experiments**: Exploring alternative communication methods
- **Tech Demonstrations**: Showcasing innovative communication technology

## 🔍 Troubleshooting

### Common Issues

#### Transmission Problems
- **Slow/No Transmission**: Increase bit duration (higher ms/bit value)
- **Screen Too Dim**: Ensure maximum brightness on sending device
- **Interrupted Transmission**: Keep screen active and avoid interruptions

#### Reception Problems
- **No Signal Detected**: Check camera permissions and alignment
- **Poor Accuracy**: Improve lighting conditions and reduce ambient light
- **Decoding Errors**: Ensure steady camera position and proper distance

#### Performance Issues
- **Battery Drain**: Use lower frame rates and optimize bit duration
- **App Crashes**: Ensure sufficient RAM and close other apps
- **Slow Processing**: Use newer devices with better camera hardware

### Optimization Tips
1. **Lighting**: Use in moderate ambient light (not too bright/dark)
2. **Distance**: Maintain 1-3 feet between devices
3. **Stability**: Keep both devices steady during transmission
4. **Speed**: Start with slower speeds (200-300ms/bit) for reliability
5. **Alignment**: Ensure camera is centered on flicker area

## 🔮 Future Enhancements

### Planned Features
- **Multi-device Sync**: Broadcast to multiple receivers
- **File Transfer**: Send images and documents via optical channel
- **QR Fallback**: Automatic fallback to QR codes for failed transmissions
- **Advanced Encryption**: Full AES implementation with key exchange
- **Audio Feedback**: Sound indicators for transmission events
- **Gesture Control**: Hand gesture-based transmission control

### Advanced Capabilities
- **Error Correction**: Reed-Solomon or Hamming codes for reliability
- **Compression**: Message compression for faster transmission
- **Protocol Extensions**: Support for different encoding schemes
- **Network Mesh**: Chain multiple devices for extended range
- **IoT Integration**: Control smart devices via light signals

## 🤝 Contributing

We welcome contributions to WhisprNet! Here's how you can help:

### Development
- **Bug Reports**: Submit issues with detailed reproduction steps
- **Feature Requests**: Propose new features with use case descriptions
- **Code Contributions**: Submit pull requests with clean, tested code
- **Documentation**: Improve documentation and tutorials

### Testing
- **Device Testing**: Test on different Android devices and versions
- **Performance Testing**: Benchmark transmission speeds and accuracy
- **User Experience**: Provide feedback on app usability
- **Edge Cases**: Test unusual scenarios and error conditions

### Community
- **Tutorials**: Create video tutorials and guides
- **Use Cases**: Share creative applications and implementations
- **Feedback**: Provide user experience feedback and suggestions
- **Promotion**: Help spread awareness of optical communication

## 📄 License

WhisprNet is released under the MIT License. See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the excellent cross-platform framework
- **Camera Plugin Contributors**: For reliable camera access
- **Manchester Encoding**: Based on established telecommunications standards
- **VLC Research Community**: For visible light communication research
- **Open Source Community**: For inspiration and support

## 📞 Support

### Getting Help
- **Documentation**: Check this README and inline code comments
- **Issues**: Submit bug reports on GitHub Issues
- **Discussions**: Join community discussions for questions
- **Email**: Contact developers for urgent issues

### Known Limitations
- **Android Only**: iOS version planned for future release
- **Camera Quality**: Performance depends on device camera capabilities
- **Ambient Light**: Sensitive to lighting conditions
- **Processing Power**: Requires modern device for optimal performance

---

**WhisprNet** - Revolutionizing communication through light. Talk in light, anywhere, anytime. 💡📱

*"In a world of digital surveillance, sometimes the oldest technologies offer the newest freedoms."*
