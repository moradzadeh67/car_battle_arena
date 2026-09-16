import 'package:flutter_scene_rapier/flutter_scene_rapier.dart';

// 1. Create a physics world
final physicsWorld = PhysicsWorld(
gravity: Vector3(0, -9.81, 0),
);

// 2. Add a rigid body (e.g., a car)
final carBody = RigidBody(
type: RigidBodyType.Dynamic,
position: Vector3(0, 1, 0),
children: [
Collider.box(size: Vector3(2, 1, 4)),
],
);

// 3. Add a static collider (e.g., ground)
final groundBody = RigidBody(
type: RigidBodyType.Static,
position: Vector3.zero(),
children: [
Collider.box(size: Vector3(100, 1, 100)),
],
);