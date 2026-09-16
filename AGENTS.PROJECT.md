# Project-Specific Rules: 3D Car Battle Arena

## 1. Project Overview
A mobile 3D Low-Poly Car Combat game built with Flutter/Dart.
MVP Goal: 2-player local Wi-Fi multiplayer battle in a single Arena.
Inspiration: Classic Battle Mode / Twisted Metal (but with 100% original IP, assets, and visual identity).

## 2. Technology Stack
- **Framework**: Flutter / Dart (Channel stable)
- **3D Rendering**: `flutter_scene` (^0.23.0)
- **Physics Backend**: `flutter_scene_rapier` (^0.5.1)
- **Target Platform**: Android (Primary for MVP)
- **Network MVP**: LAN Wi-Fi (Host/Client architecture)

## 3. Source of Truth (Project Files)
When working on this project, prioritize these files in this exact order:

1. `05_TASK_PLAN.md` (The absolute source for what to build next)
2. `04_ARCHITECTURE.md` (Folder structure and system design)
3. `references/` (Technical documentation and guides)
    - `flutter_scene_guide.md`
    - `flutter_scene_rapier_guide.md`
    - `glb_asset_workflow.md`
    - `lan_network_basics.md`
4. `02_REQUIREMENTS.md` (MVP functional/non-functional requirements)
5. `06_ASSET_PLAN.md` (Asset sources, naming conventions, and pipeline)
6. `07_NETWORK_DESIGN.md` (Protocol, message types, and authority rules)
7. `03_ROADMAP.md` (High-level phases)
8. `01_PROJECT_BRIEF.md` (Core concept and goals)
9. `00_MASTER_PLAN.docx` (Overall roadmap)

## 4. Critical Rule: Technical Spike First (T02)
Before building complex features, T02 (3D Technical Spike) MUST succeed on a real Android device.
We must verify:
- `flutter_scene` rendering and GLB model loading
- `flutter_scene_rapier` physics, colliders, and collision events
- Camera follow and touch input responsiveness
- Acceptable FPS and memory usage on a mid-range Android phone
- Flutter GPU / Impeller compatibility

If T02 fails, we stop, diagnose, and fix the stack compatibility before proceeding to T03.

## 5. Asset Strategy (Prototype vs. Final)
- **For Prototype (Speed)**: Use 100% free, legal assets from **Kenney.nl** (CC0 license) or Sketchfab (CC Attribution). Low-poly cars, simple arena, basic SFX/VFX.
- **For Final Release**: Replace with original Iranian car models (e.g., Pride, Paykan, Samand) sourced from Pars3D.com and optimized (decimated) in Blender to Low-Poly GLB format.
- Never use copyrighted assets without proper licensing.
- All assets must be documented in `06_ASSET_PLAN.md`.

## 6. Network & Architecture Principles
- **Decoupling**: Game Logic MUST be strictly separated from Network Transport.
- **MVP Topology**: Phone A (Host/Authority) ↔ Wi-Fi LAN ↔ Phone B (Client).
- **Future-Proofing**: The `NetworkTransport` interface must be designed so it can be swapped from Local Wi-Fi to an Authoritative Internet Server later without rewriting Game Logic.
- **Authority**: In MVP LAN, the Host is the source of truth for Match State, HP, and Damage validation.
- Details in `07_NETWORK_DESIGN.md`.

## 7. Workflow Enforcement
- We work **strictly one task at a time** from `05_TASK_PLAN.md`.
- Current Status: **T00 (Environment Audit) ✅** and **T01 (Empty Project) ✅** are COMPLETE.
- Next Step: **T02 (3D Technical Spike)**.
- The agent must NEVER jump ahead to T03 or network coding until T02 is explicitly approved by the user.

## 8. Language & Code Style
- Explanations to the user: Persian (Farsi).
- All code, variables, classes, file names, and comments: English.
- Keep Persian/RTL text strictly outside of Dart code blocks to prevent rendering/formatting issues.

## 9. Definition of Done for MVP
Two Android phones on the same Wi-Fi:
- One creates a Room, the other joins.
- Both players become Ready.
- Match starts.
- Both phones see both cars in the scene.
- Movement and attacks sync with acceptable latency.
- Damage/HP is consistent on both devices.
- When HP reaches zero, the Match ends.
- Result is identical on both devices.
- Players can start a new Match.

## 10. What We Are NOT Building (Yet)
- Login / Account system
- Ranking / Leaderboards
- Shop / IAP / Ads
- Online matchmaking
- Chat system
- Battle Pass
- Multiple maps (MVP: 1 Arena)
- Complex upgrade system
- Bots (Phase 6+)