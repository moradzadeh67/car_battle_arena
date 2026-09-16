# Task-by-Task Plan

## Rule
هر بار فقط یک Task را انجام می‌دهیم. بعد از اجرا، نتیجه یا خطا بررسی می‌شود. بدون حدس زدن از روی خطا جلو نمی‌رویم.

---

## T00 — Environment Audit
**خروجی:**
- Flutter version
- Dart version
- Android Studio version
- Android SDK
- connected device
- flutter doctor

**وضعیت:** ✅ تکمیل شد

---

## T01 — Empty Project
**کارها:**
- ساخت پروژه خالی Flutter با نام `car_battle_arena`
- اجرای اولیه روی Android
- Git init
- README اولیه
- ایجاد ساختار پوشه‌ها طبق `04_ARCHITECTURE.md`:
    - `lib/core/` (math, logging, config)
    - `lib/game/` (models, physics, combat, match, vehicles)
    - `lib/rendering/` (scene, camera, effects)
    - `lib/network/` (models, protocol, transport, lobby, synchronization)
    - `lib/features/` (home, lobby, gameplay, result)
    - `lib/ui/` (widgets, hud)
    - `assets/` (models/cars, models/arena, materials, textures, environments, audio/sfx, ui/icons)
- ایجاد پوشه `references/` با مستندات فنی

**خروجی:** پروژه خالی با ساختار معماری کامل که روی گوشی Android اجرا می‌شود.

**وضعیت:** ✅ تکمیل شد

---

## T02 — 3D Technical Spike ⚠️ CRITICAL
**هدف:** تأیید فنی `flutter_scene` + `flutter_scene_rapier` روی Android واقعی

### Dependencies
- اضافه کردن `flutter_scene: ^0.23.0`
- اضافه کردن `flutter_scene_rapier: ^0.5.1`
- ثبت نسخه‌های استفاده‌شده در README

**Baseline فعلی:**
```yaml
dependencies:
  flutter_scene: ^0.23.0
  flutter_scene_rapier: ^0.5.1
```
**وضعیت:** ✅ تکمیل شد و روی دستگاه اندروید واقعی تایید گردید

---

## T03 — Car Controller & Follow Camera
**کارها:**
- پیاده‌سازی `CarController` مبتنی بر فیزیک Rapier
- شبیه‌سازی گاز، ترمز و فرمان
- اعمال اصطکاک جانبی (Lateral Friction)
- پیاده‌سازی دوربین تعقیب‌کننده نرم (Smooth Follow Camera)
- اتصال جوی‌استیک لمسی به کنترلر

**خروجی:** یک ماشین قابل رانندگی با دوربین تعقیب‌کننده در آرنا.

**وضعیت:** ✅ تکمیل شد

---

## T05 — Core Combat Mechanics (Weapons & Health System)
**کارها:**
- پیاده‌سازی `WeaponSystem` (شلیک گلوله فیزیکی)
- پیاده‌سازی `HealthSystem` (مدیریت HP و صدمه)
- نمایش نوار سلامتی (Health Bar) در HUD
- ساخت هدف تمرینی (Training Dummy) و تشخیص برخورد گلوله
- اضافه کردن دکمه شلیک به رابط کاربری

**خروجی:** امکان شلیک به هدف تمرینی و کاهش HP آن.

**وضعیت:** ✅ تکمیل شد و روی دستگاه اندروید واقعی تایید گردید

---

## T06 — Network Transport Layer (Wi-Fi Discovery & Sync)
**کارها:**
- UDP Discovery
- TCP Socket / Transport interface
- MessageCodec

**وضعیت:** 🔒 Locked

---

## T07 — Multiplayer Integration & Authority Validation
**کارها:**
- Host authority
- Remote car interpolation
- Damage validation

**وضعیت:** 🔒 Locked

---

## T08 — Polish, Audio & Visual Effects
**کارها:**
- SFX
- Particles
- Final UI

**وضعیت:** 🔒 Locked