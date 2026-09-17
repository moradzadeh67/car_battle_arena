import 'package:flutter/material.dart';
import 'package:car_battle_arena/network/transport/wifi_discovery.dart';
import 'package:car_battle_arena/network/transport/tcp_transport.dart';

class NetworkMenu extends StatefulWidget {
  final Function(TcpTransport transport, bool isHost) onStartGame;

  const NetworkMenu({super.key, required this.onStartGame});

  @override
  State<NetworkMenu> createState() => _NetworkMenuState();
}

class _NetworkMenuState extends State<NetworkMenu> {
  final WifiDiscovery _discovery = WifiDiscovery();
  final TcpTransport _transport = TcpTransport();
  List<DiscoveredService> _hosts = [];
  bool _isHosting = false;

  @override
  void initState() {
    super.initState();
    _discovery.discoveredServices.listen((hosts) {
      if (mounted) setState(() => _hosts = hosts);
    });
    _discovery.start();
  }

  @override
  void dispose() {
    _discovery.stop();
    super.dispose();
  }

  Future<void> _startHosting() async {
    setState(() => _isHosting = true);
    await _transport.host(8888);
    await _discovery.start(isHost: true, hostPort: 8888);
    widget.onStartGame(_transport, true);
  }

  Future<void> _joinHost(DiscoveredService host) async {
    await _transport.connect(host.address, host.port);
    widget.onStartGame(_transport, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "CAR BATTLE ARENA",
                style: TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isHosting ? null : _startHosting,
                icon: const Icon(Icons.dns),
                label: Text(_isHosting ? "HOSTING..." : "CREATE ROOM (HOST)"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 60),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 24),
              const Text("AVAILABLE ROOMS:", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Expanded(
                child: _hosts.isEmpty
                    ? const Center(
                        child: Text(
                          "Searching for rooms...",
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _hosts.length,
                        itemBuilder: (context, index) {
                          final host = _hosts[index];
                          return Card(
                            color: Colors.white10,
                            child: ListTile(
                              title: Text(host.name, style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                host.address,
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber),
                              onTap: () => _joinHost(host),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
