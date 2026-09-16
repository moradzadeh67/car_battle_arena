import 'package:flutter_scene/scene.dart';
import 'package:flutter_scene/physics.dart';
import 'package:vector_math/vector_math.dart';

class Bullet {
  final Node node;
  final RigidBody body;
  final Vector3 velocity;
  double lifetime = 3.0; // Seconds before removal
  bool launched = false;

  Bullet(this.node, this.body, this.velocity);
}

class WeaponSystem {
  final Scene scene;
  final PhysicsWorld world;
  final List<Bullet> activeBullets = [];

  final double bulletSpeed = 50.0;

  WeaponSystem({required this.scene, required this.world});

  void shoot(Node shooterNode) {
    final transform = shooterNode.globalTransform;
    final forward = Vector3(
      transform.storage[8],
      transform.storage[9],
      transform.storage[10],
    ).normalized();

    // Spawn point: slightly in front of the car
    final spawnPos = transform.getTranslation() + (forward * 2.5) + Vector3(0, 0.5, 0);

    final bulletNode = Node(name: 'Bullet', localTransform: Matrix4.translation(spawnPos));

    final bulletBody = RigidBody(
      type: BodyType.dynamic_,
      mass: 0.1,
      useGravity: false, // Straight-flying projectiles
    );
    bulletNode.addComponent(bulletBody);
    bulletNode.addComponent(Collider(shape: SphereShape(radius: 0.15)));

    // Visual
    final bulletMaterial = UnlitMaterial()..baseColorFactor = Vector4(1.0, 1.0, 0.0, 1.0);
    bulletNode.mesh = Mesh(SphereGeometry(radius: 0.15), bulletMaterial);

    scene.add(bulletNode);
    activeBullets.add(Bullet(bulletNode, bulletBody, forward * bulletSpeed));
  }

  /// Removes the currently-active bullet backed by [node], if any.
  /// Called from the collision handler so a spent projectile is cleaned up
  /// immediately instead of lingering on the target.
  void removeBulletForNode(Node node) {
    activeBullets.removeWhere((bullet) {
      if (bullet.node != node) return false;
      scene.remove(bullet.node);
      return true;
    });
  }

  void update(double dt) {
    for (int i = activeBullets.length - 1; i >= 0; i--) {
      final bullet = activeBullets[i];

      // The body handle is only available once the body is mounted in the
      // scene, so launch the projectile on the first tick where it exists.
      if (!bullet.launched) {
        final handle = bullet.body.handle;
        if (handle != null) {
          world.simulation.setBodyLinearVelocity(handle, bullet.velocity);
          bullet.launched = true;
        }
      }

      bullet.lifetime -= dt;
      if (bullet.lifetime <= 0) {
        scene.remove(bullet.node);
        activeBullets.removeAt(i);
      }
    }
  }
}
