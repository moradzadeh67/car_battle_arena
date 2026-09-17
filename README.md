# 3D Car Battle Arena

A mobile 3D Low-Poly Car Combat game built with Flutter and Dart.

## 🚀 MVP Goal
2-player local Wi-Fi multiplayer battle in a single Arena using a Host/Client architecture.

## 🛠️ Technology Stack
- **Framework:** Flutter / Dart (Stable Channel)
- **3D Rendering:** `flutter_scene`
- **Physics Backend:** `flutter_scene_rapier` (Rapier 3D)
- **Target Platform:** Android (Primary for MVP)
- **Network MVP:** LAN Wi-Fi

## 📁 Project Structure Highlights
- `lib/core/`: Common utilities, math, configuration.
- `lib/game/`: Game logic, physics simulation, vehicles, and combat.
- `lib/rendering/`: 3D Scene graphics, camera follow, and visual effects.
- `lib/network/`: LAN transport layers, synchronization protocols.
- `lib/features/`: UI screens (Home, Lobby, Gameplay Arena).
- `assets/models/`: 3D GLB/glTF assets for vehicles and arena.

---

## 📋 Task Checklist & Progress

| Task ID | Description | Status |
| :--- | :--- | :---: |
| **T00** | Environment Audit (Flutter, SDK, Devices) | ✅ Done |
| **T01** | Empty Project Setup & Architecture Folders | ✅ Done |
| **T02** | 3D Technical Spike (`flutter_scene` + `rapier` on Device) | ✅ Done |
| **T03** | Car Controller & Follow Camera (Physics + Input) | ✅ Done |
| **T05** | Core Combat Mechanics (Weapons & Health System) | ✅ Done |
| **T06** | Network Transport Layer (Wi-Fi Discovery & Sync) | ✅ Done |
| **T07** | Multiplayer Integration & Authority Validation | ⏳ Next |
| **T08** | Polish, Audio & Visual Effects | 🔒 Locked |

---
*For development rules and workflows, see [AGENTS.md](AGENTS.md) and [AGENTS.PROJECT.md](AGENTS.PROJECT.md).*
