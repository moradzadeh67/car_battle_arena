# Flutter Scene Guide

## Overview
`flutter_scene` is a 3D scene graph and rendering engine for Flutter, built on Flutter GPU and Impeller.

## Key Concepts
- **SceneView**: The main widget to render 3D content.
- **SceneNode**: The base class for all objects in the 3D world (like GameObject in Unity).
- **PerspectiveCamera**: A camera that renders the scene.
- **DirectionalLight**: A light source that casts shadows.
- **GltfNode**: A node that loads a .glb or .gltf model.

## Basic Setup
```dart
import 'package:flutter_scene/flutter_scene.dart';

// 1. Create a scene
final scene = Scene(
  children: [
    PerspectiveCamera(
      position: Vector3(0, 5, 10),
      lookAt: Vector3.zero(),
    ),
    DirectionalLight(
      position: Vector3(10, 10, 10),
      color: Color.white,
    ),
    // Add models here
  ],
);

// 2. Render it
SceneView(scene: scene)