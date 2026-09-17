import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'network_transport.dart';

class TcpTransport implements NetworkTransport {
  ServerSocket? _server;
  final List<Socket> _clients = [];
  Socket? _socketToHost;
  bool _isHost = false;

  final _messageController = StreamController<Uint8List>.broadcast();
  final _peerController = StreamController<PeerEvent>.broadcast();

  @override
  Stream<Uint8List> get messageStream => _messageController.stream;

  @override
  Stream<PeerEvent> get peerStream => _peerController.stream;

  @override
  Future<void> host(int port) async {
    _isHost = true;
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _server!.listen((client) {
      _clients.add(client);
      _peerController.add(PeerEvent(client.remoteAddress.address, PeerStatus.connected));

      client.listen(
        (data) {
          _messageController.add(Uint8List.fromList(data));
          // If host receives from a client, it should ideally relay to others in a real game,
          // but for MVP 1v1, we just emit it.
        },
        onDone: () {
          _clients.remove(client);
          _peerController.add(PeerEvent(client.remoteAddress.address, PeerStatus.disconnected));
        },
        onError: (_) {
          _clients.remove(client);
          _peerController.add(PeerEvent(client.remoteAddress.address, PeerStatus.disconnected));
        },
      );
    });
  }

  @override
  Future<void> connect(String address, int port) async {
    _isHost = false;
    _socketToHost = await Socket.connect(address, port);
    _peerController.add(PeerEvent(address, PeerStatus.connected));

    _socketToHost!.listen(
      (data) {
        _messageController.add(Uint8List.fromList(data));
      },
      onDone: () {
        _peerController.add(PeerEvent(address, PeerStatus.disconnected));
      },
      onError: (_) {
        _peerController.add(PeerEvent(address, PeerStatus.disconnected));
      },
    );
  }

  @override
  void broadcast(Uint8List data) {
    if (_isHost) {
      for (final client in _clients) {
        client.add(data);
      }
    } else {
      _socketToHost?.add(data);
    }
  }

  @override
  Future<void> dispose() async {
    await _server?.close();
    for (final c in _clients) {
      await c.close();
    }
    await _socketToHost?.close();
    await _messageController.close();
    await _peerController.close();
  }
}
