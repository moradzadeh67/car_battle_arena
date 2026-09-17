import 'dart:async';
import 'dart:typed_data';

/// Common interface for network communication.
/// Abstracted so we can switch between LAN, Bluetooth, or WebSockets later.
abstract class NetworkTransport {
  /// Emits when a new message is received.
  Stream<Uint8List> get messageStream;

  /// Emits when a peer connects or disconnects.
  Stream<PeerEvent> get peerStream;

  /// Starts hosting a session.
  Future<void> host(int port);

  /// Connects to a specific host.
  Future<void> connect(String address, int port);

  /// Sends a message to all connected peers (or the server if client).
  void broadcast(Uint8List data);

  /// Disconnects and cleans up resources.
  Future<void> dispose();
}

enum PeerStatus { connected, disconnected }

class PeerEvent {
  final String id;
  final PeerStatus status;
  PeerEvent(this.id, this.status);
}
