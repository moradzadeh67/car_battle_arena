import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

class FollowCamera {
  final Node targetNode;
  final double distance;
  final double height;
  final double smoothSpeed;

  Vector3 _currentPosition = Vector3.zero();
  Vector3 _currentLookAt = Vector3.zero();

  FollowCamera({
    required this.targetNode,
    this.distance = 8.0,
    this.height = 4.0,
    this.smoothSpeed = 5.0,
  }) {
    // Initial position to avoid jumping
    final targetPos = targetNode.globalTransform.getTranslation();
    _currentPosition = targetPos - Vector3(0, 0, distance) + Vector3(0, height, 0);
    _currentLookAt = targetPos;
  }

  PerspectiveCamera update(double dt) {
    final targetTransform = targetNode.globalTransform;
    final targetPos = targetTransform.getTranslation();

    // Get forward vector of the target
    final forward = Vector3(
      targetTransform.storage[8],
      targetTransform.storage[9],
      targetTransform.storage[10],
    ).normalized();

    // Calculate desired position behind the target
    final desiredPosition = targetPos - (forward * distance) + Vector3(0, height, 0);
    final desiredLookAt = targetPos + Vector3(0, 1.0, 0); // Look slightly above the car

    // Smooth transition
    final t = (smoothSpeed * dt).clamp(0.0, 1.0);
    _currentPosition = _currentPosition + (desiredPosition - _currentPosition) * t;
    _currentLookAt = _currentLookAt + (desiredLookAt - _currentLookAt) * t;

    return PerspectiveCamera(position: _currentPosition, target: _currentLookAt);
  }
}
