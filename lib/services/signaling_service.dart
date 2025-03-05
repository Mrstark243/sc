import 'dart:convert';
import 'dart:io';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SignalingService {
  static const int PORT = 8080;
  HttpServer? _server;
  RTCPeerConnection? _peerConnection;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  List<RTCIceCandidate> _iceCandidates = [];

  Future<void> initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> startServer() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, PORT);
    print('Teacher is sharing screen on ${_server!.address.address}:$PORT');

    _server!.listen((HttpRequest request) async {
      if (request.method == 'POST') {
        var jsonStr = await utf8.decoder.bind(request).join();
        var data = json.decode(jsonStr);

        if (data['type'] == 'offer') {
          await _handleOffer(data['sdp'], request.response);
        } else if (data['type'] == 'candidate') {
          await _handleCandidate(data);
        }
      }
    });
  }

  Future<void> _handleOffer(String sdp, HttpResponse response) async {
    _peerConnection = await _createPeerConnection();

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(sdp, 'offer'),
    );

    var answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    response.headers.contentType = ContentType.json;
    response.write(json.encode({'type': 'answer', 'sdp': answer.sdp}));
    await response.close();

    for (var candidate in _iceCandidates) {
      _sendCandidate(candidate);
    }
  }

  Future<void> _handleCandidate(Map<String, dynamic> data) async {
    if (_peerConnection != null) {
      var candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    } else {
      _iceCandidates.add(
        RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        ),
      );
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };
    var connection = await createPeerConnection(config);

    connection.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    connection.onIceCandidate = (RTCIceCandidate candidate) {
      _sendCandidate(candidate);
    };

    return connection;
  }

  void _sendCandidate(RTCIceCandidate candidate) {
    print("Sending ICE candidate: ${candidate.toMap()}");
  }

  Future<void> stopServer() async {
    await _server?.close();
    _server = null;
    await _peerConnection?.close();
    disposeRenderers();
    print('Screen sharing stopped.');
  }

  Future<void> startScreenShare() async {
    await _localRenderer.initialize();
    var stream = await navigator.mediaDevices.getDisplayMedia({'video': true});
    _localRenderer.srcObject = stream;

    _peerConnection = await _createPeerConnection();
    stream.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, stream);
    });
  }

  void disposeRenderers() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;
}
