import 'package:flutter/material.dart' hide BoxShape;
import 'package:flutter/material.dart' as ui show BoxShape;
import 'package:flutter_scene/scene.dart' hide Material;
import 'package:flutter_scene/physics.dart';
import 'package:flutter_scene_rapier/flutter_scene_rapier.dart';
import 'package:vector_math/vector_math.dart' as v;
import 'package:car_battle_arena/ui/widgets/joystick_overlay.dart';
import 'package:car_battle_arena/game/vehicles/car_controller.dart';
import 'package:car_battle_arena/rendering/camera/follow_camera.dart';
import 'package:car_battle_arena/game/combat/weapon_system.dart';
import 'package:car_battle_arena/game/combat/health_system.dart';
import 'package:car_battle_arena/network/transport/tcp_transport.dart';

class GameplayPage extends StatefulWidget {
  final TcpTransport transport;
  final bool isHost;

  const GameplayPage({super.key, required this.transport, required this.isHost});

  @override
  State<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends State<GameplayPage> {
  late Scene scene;
  late RapierWorld rapierWorld;
  late PhysicsWorld physicsWorld;

  late Node carNode;
  late RigidBody carBody;
  late CarController carController;
  late FollowCamera followCamera;
  late WeaponSystem weaponSystem;

  late Node dummyNode;
  late UnlitMaterial dummyMaterial;
  late HealthSystem dummyHealth;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    scene = Scene();

    // 1. Physics Setup
    rapierWorld = RapierWorld(gravity: v.Vector3(0, -9.81, 0));
    physicsWorld = PhysicsWorld(rapierWorld);
    scene.root.addComponent(physicsWorld);

    // 2. Lighting
    final lightNode = Node(name: 'SunLight');
    lightNode.addComponent(
      DirectionalLightComponent(DirectionalLight(intensity: 5.0, castsShadow: true)),
    );
    lightNode.lookAt(v.Vector3(1.0, -2.0, 1.0));
    scene.add(lightNode);

    // 3. Environment
    final groundNode = Node(
      name: 'ArenaFloor',
      localTransform: v.Matrix4.translation(v.Vector3(0, -0.5, 0)),
    );
    groundNode.addComponent(RigidBody(type: BodyType.fixed));
    groundNode.addComponent(Collider(shape: BoxShape(halfExtents: v.Vector3(50.0, 0.5, 50.0))));
    final groundMaterial = UnlitMaterial()..baseColorFactor = v.Vector4(0.1, 0.2, 0.1, 1.0);
    groundNode.mesh = Mesh(CuboidGeometry(v.Vector3(100.0, 1.0, 100.0)), groundMaterial);
    scene.add(groundNode);

    _addWall(v.Vector3(0, 2, 50), v.Vector3(50, 2, 0.5));
    _addWall(v.Vector3(0, 2, -50), v.Vector3(50, 2, 0.5));
    _addWall(v.Vector3(50, 2, 0), v.Vector3(0.5, 2, 50));
    _addWall(v.Vector3(-50, 2, 0), v.Vector3(0.5, 2, 50));

    scene.skybox = Skybox(
      GradientSkySource(
        zenithColor: v.Vector3(0.1, 0.2, 0.4),
        horizonColor: v.Vector3(0.3, 0.4, 0.6),
        groundColor: v.Vector3(0.1, 0.1, 0.1),
      ),
    );

    // 4. Player Car
    carNode = Node(name: 'PlayerCar', localTransform: v.Matrix4.translation(v.Vector3(0, 1.0, 0)));
    carBody = RigidBody(type: BodyType.dynamic_, mass: 1.0);
    carNode.addComponent(carBody);
    carNode.addComponent(Collider(shape: BoxShape(halfExtents: v.Vector3(1.0, 0.5, 2.0))));
    carNode.mesh = Mesh(
      CuboidGeometry(v.Vector3(2.0, 1.0, 4.0)),
      UnlitMaterial()..baseColorFactor = v.Vector4(0.8, 0.1, 0.1, 1.0),
    );

    final frontMarker = Node(localTransform: v.Matrix4.translation(v.Vector3(0, 0.6, 1.8)));
    frontMarker.mesh = Mesh(
      CuboidGeometry(v.Vector3(0.4, 0.1, 0.4)),
      UnlitMaterial()..baseColorFactor = v.Vector4(0.1, 0.4, 0.8, 1.0),
    );
    carNode.add(frontMarker);
    scene.add(carNode);

    // 5. Training Dummy
    dummyNode = Node(name: 'Dummy', localTransform: v.Matrix4.translation(v.Vector3(0, 1.5, 15)));
    dummyNode.addComponent(RigidBody(type: BodyType.fixed));
    final dummyCollider = Collider(shape: BoxShape(halfExtents: v.Vector3(1.5, 1.5, 1.5)));
    dummyNode.addComponent(dummyCollider);
    dummyNode.mesh = Mesh(
      CuboidGeometry(v.Vector3(3, 3, 3)),
      dummyMaterial = UnlitMaterial()..baseColorFactor = v.Vector4(0.5, 0.5, 0.5, 1.0),
    );
    scene.add(dummyNode);

    // 6. Logic Systems
    carController = CarController(node: carNode, body: carBody, world: physicsWorld);
    followCamera = FollowCamera(targetNode: carNode);
    weaponSystem = WeaponSystem(scene: scene, world: physicsWorld);
    dummyHealth = HealthSystem(maxHealth: 100);

    // Collision Listener
    physicsWorld.collisions.listen((event) {
      if (event is! CollisionBegan) return;
      final hitDummy = event.nodeA == dummyNode || event.nodeB == dummyNode;
      if (!hitDummy) return;
      final bulletNode = event.nodeA.name == 'Bullet'
          ? event.nodeA
          : (event.nodeB.name == 'Bullet' ? event.nodeB : null);
      if (bulletNode == null) return;
      weaponSystem.removeBulletForNode(bulletNode);
      setState(() {
        dummyHealth.takeDamage(10);
        _refreshDummyAppearance();
      });
    });
  }

  void _refreshDummyAppearance() {
    final t = dummyHealth.percentage;
    dummyMaterial.baseColorFactor = v.Vector4(0.5 + (1.0 - t) * 0.4, 0.5 * t, 0.5 * t, 1.0);
  }

  void _addWall(v.Vector3 pos, v.Vector3 halfExtents) {
    final wall = Node(name: 'Wall', localTransform: v.Matrix4.translation(pos));
    wall.addComponent(RigidBody(type: BodyType.fixed));
    wall.addComponent(Collider(shape: BoxShape(halfExtents: halfExtents)));
    wall.mesh = Mesh(
      CuboidGeometry(halfExtents * 2.0),
      UnlitMaterial()..baseColorFactor = v.Vector4(0.22, 0.24, 0.30, 1.0),
    );
    scene.add(wall);
  }

  void _resetCar() {
    setState(() {
      carNode.localTransform = v.Matrix4.translation(v.Vector3(0, 2, 0));
      if (carBody.handle != null) {
        rapierWorld.setBodyLinearVelocity(carBody.handle!, v.Vector3.zero());
        rapierWorld.setBodyAngularVelocity(carBody.handle!, v.Vector3.zero());
      }
      dummyHealth.currentHealth = dummyHealth.maxHealth;
      dummyHealth.isDead = false;
      _refreshDummyAppearance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: SceneView(
              scene,
              cameraBuilder: (elapsed) => followCamera.update(1.0 / 60.0),
              onTick: (elapsed, deltaSeconds) {
                carController.update(deltaSeconds);
                weaponSystem.update(deltaSeconds);
                scene.update(deltaSeconds);
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isHost ? "HOST MODE" : "CLIENT MODE",
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("TARGET: ", style: TextStyle(color: Colors.white, fontSize: 12)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: dummyHealth.percentage,
                        backgroundColor: Colors.red.withValues(alpha: 0.3),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 30,
            child: JoystickOverlay(
              onChanged: (x, y) {
                carController.steering = x;
                carController.throttle = y;
              },
            ),
          ),
          Positioned(
            bottom: 50,
            right: 120,
            child: GestureDetector(
              onTap: () => weaponSystem.shoot(carNode),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.6),
                  shape: ui.BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.gps_fixed, color: Colors.white, size: 40),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 40,
            child: FloatingActionButton(
              onPressed: _resetCar,
              mini: true,
              backgroundColor: Colors.amber,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}
