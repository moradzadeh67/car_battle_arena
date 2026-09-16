import 'package:flutter_scene/scene.dart';
import 'package:flutter_scene/physics.dart';
import 'package:vector_math/vector_math.dart';

/// Physics-driven arcade car controller.
///
/// Only *adds* forces/impulses for translation. Steering commands the yaw
/// rate directly instead of torquing the body, because
/// `RigidBody.angularDamping` is a per-step fraction in `[0, 1]` (0 = no
/// damping) and would smear an impulse-based turn into nothing.
class CarController {
  final Node node;
  final RigidBody body;
  final PhysicsWorld world;

  // Inputs (-1.0 to 1.0)
  double throttle = 0;
  double steering = 0;

  // Tuning parameters
  final double accelerationPower = 120.0;
  final double maxSpeed = 30.0;
  final double maxYawRate = 2.0; // rad/s at full steering lock
  final double lateralGrip = 0.9;
  final double autoBrakePower = 3.0;

  CarController({required this.node, required this.body, required this.world});

  void update(double dt) {
    final handle = body.handle;
    if (handle == null) return;

    final sim = world.simulation;

    // Wake up the rigid body if there's any input.
    if (throttle.abs() > 0.05 || steering.abs() > 0.05) {
      sim.wakeBody(handle);
    }

    final transform = node.globalTransform;
    final forward = transform.forward;
    final right = transform.right;

    final velocity = sim.readBodyLinearVelocity(handle);
    final speed = velocity.dot(forward);

    // 1. Throttle / automatic brake.
    if (throttle.abs() > 0.05) {
      if (speed.abs() < maxSpeed) {
        sim.applyForce(handle, forward * (throttle * accelerationPower));
      }
    } else {
      sim.applyForce(handle, -velocity * autoBrakePower);
    }

    // 2. Steering: command the yaw rate directly.
    // The arena is flat, so rotating around world Y is correct, and writing
    // the whole angular velocity each frame also keeps the car from
    // tumbling when it gets bumped.
    if (steering.abs() > 0.05) {
      // Turn harder at speed, but never fully lock out low-speed turning.
      final speedFactor = (velocity.length / 6.0).clamp(0.35, 1.0);
      // Positive steering (joystick pushed right) must yaw the nose to the
      // driver's right, hence the positive sign here.
      sim.setBodyAngularVelocity(handle, Vector3(0.0, steering * maxYawRate * speedFactor, 0.0));
    } else {
      // No steering input: stop rotating so the car cannot spin out.
      sim.setBodyAngularVelocity(handle, Vector3.zero());
    }

    // 3. Lateral friction: cancel sideways velocity so the car grips.
    final lateralVelocity = right * velocity.dot(right);
    sim.applyImpulse(handle, -lateralVelocity * (body.mass ?? 1.0) * lateralGrip);
  }
}

extension NodeTransformUtils on Matrix4 {
  Vector3 get forward => Vector3(storage[8], storage[9], storage[10]).normalized();
  Vector3 get right => Vector3(storage[0], storage[1], storage[2]).normalized();
  Vector3 get up => Vector3(storage[4], storage[5], storage[6]).normalized();
}
