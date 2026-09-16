# LAN Network Basics for MVP

## Architecture
- **Host**: Creates the room, authoritative for game state (HP, Match result).
- **Client**: Joins the room, sends inputs, receives state.
- **Transport**: Local Wi-Fi (UDP for frequent data, TCP for reliable events).

## Key Dart Classes
- `ServerSocket` / `Socket` (from `dart:io`)
- `DatagramSocket` (for UDP)

## Message Types
- **Reliable (TCP)**: Join, Ready, Attack, MatchEnd.
- **Frequent (UDP)**: Position, Rotation, Velocity (Interpolated on client).

## Synchronization Strategy
1. Client sends Input to Host.
2. Host simulates physics and game logic.
3. Host sends Snapshot (Position, HP, etc.) to all clients.
4. Clients interpolate remote players' positions for smoothness.