import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/signaling_service.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  _TeacherHomeScreenState createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final SignalingService _signalingService = SignalingService();
  bool isSharing = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
  }

  Future<void> _initializeRenderer() async {
    await _signalingService.initializeRenderers();
  }

  Future<void> _startScreenShare() async {
    try {
      await _signalingService.startScreenShare();
      await _signalingService.startServer();
      setState(() {
        isSharing = true;
      });
    } catch (e) {
      debugPrint("Error starting screen share: $e");
    }
  }

  Future<void> _stopScreenShare() async {
    await _signalingService.stopServer();
    setState(() {
      isSharing = false;
    });
  }

  @override
  void dispose() {
    _signalingService.disposeRenderers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Home')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: RTCVideoView(_signalingService.localRenderer)),
          ElevatedButton(
            onPressed: isSharing ? _stopScreenShare : _startScreenShare,
            child: Text(isSharing ? 'Stop Sharing' : 'Start Sharing'),
          ),
        ],
      ),
    );
  }
}
