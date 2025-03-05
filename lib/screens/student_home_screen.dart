import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
  }

  Future<void> _initializeRenderer() async {
    try {
      await _remoteRenderer.initialize();
      setState(() {});
    } catch (e) {
      debugPrint("Error initializing RTCVideoRenderer: $e");
    }
  }

  Future<void> _scanForScreenShare() async {
    try {
      // TODO: Implement WebRTC connection logic
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      debugPrint("Error joining screen session: $e");
    }
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Home')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _scanForScreenShare,
            child: const Text('Join Screen Session'),
          ),
        ],
      ),
    );
  }
}
