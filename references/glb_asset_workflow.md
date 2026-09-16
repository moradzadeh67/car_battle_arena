


```markdown
# GLB Asset Workflow

## Source
- **Prototype**: Kenney.nl (CC0 license), Sketchfab (CC Attribution).
- **Final**: Pars3D.com (Iranian cars), optimized in Blender.

## Pipeline
1. **Download/Model**: Get a .blend, .fbx, or .obj file.
2. **Optimize (Blender)**:
   - Reduce polygons (Decimate modifier) to <10k for mobile.
   - Bake textures into a single atlas if possible.
   - Ensure scale is correct (1 unit = 1 meter).
3. **Export**: Export as `.glb` (binary glTF).
4. **Import**: Place in `assets/models/` and register in `pubspec.yaml`.
5. **Load**: Use `GltfNode` in `flutter_scene`.

## Naming Convention
- `car_player_a.glb`
- `car_player_b.glb`
- `arena_01.glb`