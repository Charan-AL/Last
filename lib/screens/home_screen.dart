import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'sender_screen.dart';
import 'receiver_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 28),
            SizedBox(width: 8),
            Text('WhisprNet', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: provider.toggleDarkMode,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0077FF), Color(0xFF00C853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Talk in Light',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Offline • Anonymous • Anywhere',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Mode Selection
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Choose Communication Mode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // Send Mode Button
                  _buildModeCard(
                    context,
                    icon: Icons.send,
                    title: '🚀 Send Message',
                    subtitle: 'Transmit using screen flickers',
                    color: Color(0xFF0077FF),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SenderScreen()),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Receive Mode Button
                  _buildModeCard(
                    context,
                    icon: Icons.camera_alt,
                    title: '📥 Receive Message',
                    subtitle: 'Decode using camera detection',
                    color: Color(0xFF00C853),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReceiverScreen()),
                    ),
                  ),
                ],
              ),
            ),
            
            // Analytics Summary
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Messages', provider.analytics['totalMessages'].toString()),
                      _buildStat('Success Rate', '${((provider.analytics['successfulTransmissions'] / (provider.analytics['totalMessages'] == 0 ? 1 : provider.analytics['totalMessages'])) * 100).toInt()}%'),
                      _buildStat('Speed', '${provider.flickerSpeed}ms/bit'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0077FF),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚙️ Settings'),
        content: Consumer<AppProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text('🔒 Encryption'),
                  subtitle: Text('Enable AES-128 encryption'),
                  value: provider.isEncryptionEnabled,
                  onChanged: (value) => provider.toggleEncryption(),
                ),
                SizedBox(height: 16),
                Text('Flicker Speed: ${provider.flickerSpeed}ms/bit'),
                Slider(
                  value: provider.flickerSpeed.toDouble(),
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  onChanged: (value) => provider.setFlickerSpeed(value.toInt()),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
