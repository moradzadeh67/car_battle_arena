# Technical Architecture

## پیشنهاد معماری

```text
lib/
  core/
    math/
    logging/
    config/

  game/
    models/
    physics/
    combat/
    match/
    vehicles/

  rendering/
    scene/
    camera/
    effects/

  network/
    models/
    protocol/
    transport/
    lobby/
    synchronization/

  features/
    home/
    lobby/
    gameplay/
    result/

  ui/
    widgets/
    hud/

  main.dart
```

## 3D Technology Architecture

راهکار 3D پروژه بر پایه دو لایه مکمل ساخته می‌شود:

```text
                Flutter / Dart
                      │
                      ▼
               flutter_scene
                      │
          ┌───────────┴───────────┐
          │                       │
          ▼                       ▼
     3D Rendering            Scene / Nodes
          │                       │
          └───────────┬───────────┘
                      │
                      ▼
            flutter_scene_rapier
                      │
                      ▼
                  Rapier 3D
                      │
          ┌───────────┼───────────┐
          │           │           │
          ▼           ▼           ▼
       Bodies     Colliders    Queries
```

### flutter_scene

مسئول بخش‌های زیر است:

- Scene Graph
- 3D Rendering
- Camera
- glTF / GLB
- PBR Materials
- Lighting
- Shadows
- Animation
- Particles
- 3D Asset Pipeline
- ارتباط Scene با Flutter UI

### flutter_scene_rapier

مسئول Physics simulation است:

- Rigid Bodies
- Colliders
- Collision Events
- Physics Queries
- Raycast
- Shape Cast
- Overlap Queries
- Joints در صورت نیاز
- Fixed timestep
- Transform interpolation
- Snapshot / Restore برای نیازهای آینده Multiplayer

### اصل مهم

`flutter_scene_rapier` جایگزین `flutter_scene` نیست.

این دو در پروژه کنار هم استفاده می‌شوند:

```text
flutter_scene
      +
flutter_scene_rapier
```

در نتیجه در کد پروژه باید وابستگی Rendering و Physics تا حد امکان از Game Logic جدا نگه داشته شود.

---

## 3D Technical Spike

قبل از توسعه بخش‌های بزرگ بازی باید موارد زیر روی Android واقعی تأیید شوند:

```text
Flutter
  ↓
flutter_scene
  ↓
flutter_scene_rapier
  ↓
Android Device
```

### Rendering

- Scene initialization
- Arena rendering
- GLB model loading
- Camera
- Lighting
- Shadows
- PBR
- Frame rate

### Physics

- Physics World
- Static Arena collider
- Dynamic vehicle body
- Vehicle collider
- Collision detection
- Fixed timestep
- Transform interpolation

### Device

- Android build
- Flutter GPU
- GPU performance
- CPU usage
- Memory
- FPS
- Touch input

تا زمانی که این Spike موفق نشده است، نباید تعداد زیادی Feature روی این Stack ساخته شود.

---

## Asset Pipeline

مدل‌های 3D پروژه ترجیحاً به صورت:

```text
GLB / glTF
```

نگهداری می‌شوند.

برای Assetهایی که همراه برنامه منتشر می‌شوند، pipeline خود `flutter_scene` استفاده می‌شود.

ساختار اولیه:

```text
assets/
  models/
    cars/
    arena/
  materials/
  textures/
  environments/
```

---

## اصل معماری Multiplayer

Game State:

- MatchState
- PlayerState
- VehicleState
- HealthState
- AttackEvent

Network:

- NetworkTransport
- HostTransport
- ClientTransport
- MessageCodec
- NetworkClock
- SnapshotBuffer

### MVP ساده

برای شروع می‌توان از Host/Client روی LAN استفاده کرد.

اما API داخلی شبکه باید شبیه این مفهوم باشد:

```text
connect()
createRoom()
joinRoom()
send()
onMessage()
disconnect()
```

تا بعداً Transport اینترنتی جایگزین شود.

---

## Synchronization

برای MVP:

- position
- rotation
- velocity/state
- HP
- attack event
- match state

برای حرکت Remote Player بهتر است به جای نمایش مستقیم هر packet، از interpolation استفاده شود تا حرکت روان‌تر شود.

در صورت استفاده از قابلیت‌های شبکه‌ای اختصاصی `flutter_scene` در آینده، `flutter_scene_net` می‌تواند برای replication و interpolation بررسی شود؛ اما Network abstraction پروژه نباید مستقیماً به آن وابسته باشد.

---

## Authority

از ابتدا باید مشخص باشد چه کسی تصمیم نهایی می‌گیرد.

### MVP LAN

- Host می‌تواند authority اصلی Match باشد.

### نسخه Online

- Dedicated Server باید authority اصلی gameplay باشد.

این تصمیم جلوی بازطراحی سنگین بعدی را می‌گیرد.

---

## Flutter GPU

`flutter_scene` بر پایه Flutter GPU / Impeller ساخته شده است.

برای Android باید Flutter GPU فعال شود.

در Technical Spike باید این مورد به‌صورت واقعی تست شود و صرفاً بر اساس Emulator تصمیم‌گیری نشود.

همچنین چون `flutter_scene` هنوز pre-1.0 است، نسخه Flutter و نسخه پکیج‌ها باید در شروع پروژه ثبت شوند تا تغییرات آینده قابل ردیابی باشند.

---

## Dependency Baseline

نسخه‌های بررسی‌شده در زمان تهیه این سند:

```yaml
dependencies:
  flutter_scene: ^0.23.0
  flutter_scene_rapier: ^0.5.1
```

این نسخه‌ها Baseline مربوط به Technical Spike هستند، نه تعهد دائمی برای نسخه نهایی.

قبل از شروع Production باید:

```text
flutter pub get
flutter analyze
flutter build apk
flutter run --enable-flutter-gpu
```

و تست واقعی Android انجام شود.

اگر Compatibility مشکل داشت، اول نسخه‌ها را اصلاح می‌کنیم و بعد توسعه ادامه پیدا می‌کند.