import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DiscoveredService {
  final String address;
  final String name;
  final int port;
  final DateTime lastSeen;

  DiscoveredService({required this.address, required this.name, required this.port})
    : lastSeen = DateTime.now();
}

class WifiDiscovery {
  final int discoveryPort;
  final String serviceName;
  RawDatagramSocket? _socket;
  final _controller = StreamController<List<DiscoveredService>>.broadcast();
  final Map<String, DiscoveredService> _discovered = {};
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;

  WifiDiscovery({this.discoveryPort = 4545, this.serviceName = "CarBattleArena"});

  Stream<List<DiscoveredService>> get discoveredServices => _controller.stream;

  /// Start looking for other hosts and broadcasting self if [isHost] is true.
  Future<void> start({bool isHost = false, int? hostPort}) async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, discoveryPort);
    _socket!.broadcastEnabled = true;

    _socket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _socket!.receive();
        if (dg == null) return;

        try {
          final data = jsonDecode(utf8.decode(dg.data));
          if (data['service'] == serviceName) {
            final service = DiscoveredService(
              address: dg.address.address,
              name: data['name'] ?? "Unknown",
              port: data['port'] ?? 0,
            );
            _discovered[service.address] = service;
            _controller.add(_discovered.values.toList());
          }
        } catch (_) {}
      }
    });

    if (isHost) {
      _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        final info = {'service': serviceName, 'name': Platform.localHostname, 'port': hostPort};
        _socket!.send(
          utf8.encode(jsonEncode(info)),
          InternetAddress("255.255.255.255"),
          discoveryPort,
        );
      });
    }

    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final now = DateTime.now();
      final beforeCount = _discovered.length;
      _discovered.removeWhere((key, service) => now.difference(service.lastSeen).inSeconds > 10);
      if (_discovered.length != beforeCount) {
        _controller.add(_discovered.values.toList());
      }
    });
  }

  void stop() {
    _broadcastTimer?.cancel();
    _cleanupTimer?.cancel();
    _socket?.close();
  }
}
