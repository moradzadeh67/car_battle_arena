import 'dart:convert';
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

enum MessageType { handshake, move, shoot, damage, syncHP }

class GameMessage {
  final MessageType type;
  final Map<String, dynamic> data;

  GameMessage(this.type, this.data);

  Uint8List encode() {
    final payload = {'t': type.index, 'd': data};
    return utf8.encode(jsonEncode(payload));
  }

  factory GameMessage.decode(Uint8List bytes) {
    final payload = jsonDecode(utf8.decode(bytes));
    return GameMessage(MessageType.values[payload['t']], Map<String, dynamic>.from(payload['d']));
  }
}

/// Helper to serialize common game types
class NetworkUtils {
  static Map<String, double> vectorToMap(Vector3 v) => {'x': v.x, 'y': v.y, 'z': v.z};

  static Vector3 mapToVector(Map<String, dynamic> m) =>
      Vector3((m['x'] as num).toDouble(), (m['y'] as num).toDouble(), (m['z'] as num).toDouble());
}
