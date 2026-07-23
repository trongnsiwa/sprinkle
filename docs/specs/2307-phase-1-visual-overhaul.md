# 🎨 Prompt for Antigravity: Phase 1 – Visual Overhaul (Gen‑Z Aesthetic)

**Goal:** Transform Sprinkle’s UI from “clean but cold” into a **fun, vibrant, and “happy”** experience using gradient accents, dynamic backgrounds, squircle shapes, playful typography, and a pulsating glow—without touching a single Riverpod provider or database call.

**Rules:**

- **DO NOT** change `CameraViewModel`, `DatabaseService`, or any capture/save logic.
- **DO NOT** remove existing functionality (flash, zoom, shutter, gallery picker).
- **DO** use the existing `AppColors` and `AppTypography` as a base—extend them, don’t replace them.
- **DO** keep all `Key`s and widget identities stable to avoid unnecessary rebuilds.

---

## 1. New Color System (Extend `AppColors`)

**File:** `lib/utils/colors.dart`

Replace the static `primary`/`secondary` with **gradient getters**, and add a new **vibrant background palette**.

```dart
import 'dart:ui' show Color;

abstract class AppColors {
  // --- Legacy (keep for backward compatibility) ---
  static const Color primary = Color(0xFFFF6B6B);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color neutral = Color(0xFF1A1A1A);
  static const Color neutralLight = Color(0xFF8E8E93);
  static const Color neutralUltraLight = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color starGold = Color(0xFFFF9500);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // --- NEW: Gradient Accents (Sunset ➔ Teal) ---
  static const List<Color> primaryGradient = [
    Color(0xFFFF512F), // Vibrant Orange-Red
    Color(0xFFDD2475), // Deep Pink
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF00C9FF), // Bright Cyan
    Color(0xFF92FE9D), // Mint Green
  ];

  // --- NEW: Deep Space Background Gradient (for Camera & Lists) ---
  static const List<Color> backgroundGradient = [
    Color(0xFF0B0C10), // Almost black
    Color(0xFF1F2833), // Deep slate blue
  ];
  static const List<Color> backgroundGradientVibrant = [
    Color(0xFF0F172A), // Midnight
    Color(0xFF2E1065), // Plum
    Color(0xFF4C1D95), // Deep purple (optional bottom accent)
  ];

  // --- NEW: Glassmorphism tokens ---
  static const Color glassBorder = Color(0x26FFFFFF); // 15% white
  static const Color glassBackground = Color(0x0DFFFFFF); // 5% white
}
```

---

## 2. Playful Typography (Update `AppTypography`)

**File:** `lib/utils/typography.dart`

Add **all‑caps, wide‑spaced** styles and an **expanded number** style for badges.

```dart
abstract class AppTypography {
  static const String fontFamily = 'SVN-Gilroy';

  // ... (keep existing styles: displayLarge, headlineLarge, etc.)

  // --- NEW: Fashion‑Magazine Caps ---
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w800,
    letterSpacing: 2.5,
    height: 1.2,
    color: AppColors.neutralLight,
  );

  // --- NEW: Bold, playful number for badges ---
  static const TextStyle badgeNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
    height: 1.0,
    color: Colors.white,
  );
}
```

---

## 3. Squircle & Breathing Glow (`SquarePreview`)

**File:** `lib/widgets/square_preview.dart`

**Changes:**

- Increase corner radius to `32` (closer to squircle).
- Add a **breathing glow** (rainbow‑shift) using an `AnimationController`.

**Implementation:**

```dart
// Inside _SquarePreviewState, add:
late AnimationController _glowColorController;
late Animation<Color?> _glowColorAnimation;

@override
void initState() {
  super.initState();
  // ... existing scale controller ...
  _glowColorController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);
  _glowColorAnimation = ColorTween(
    begin: AppColors.primary,
    end: AppColors.secondary,
  ).animate(_glowColorController);
}

@override
void dispose() {
  _glowColorController.dispose();
  // ...
}

// In the build method, replace the BoxShadow with:
boxShadow: [
  BoxShadow(
    color: _glowColorAnimation.value?.withOpacity(0.25) ?? AppColors.primary.withOpacity(0.25),
    blurRadius: 30,
    spreadRadius: 4,
    offset: Offset.zero,
  ),
  // ... keep the soft black shadow ...
]
```

- Change `borderRadius` parameter default to `32.0` (or pass `32.0` from `CameraView`).

---

## 4. Dynamic Gradient Background (`CameraView`)

**File:** `lib/views/camera_view.dart`

Replace the static `Color(0xFF1C1C1E)` background with a **rich animated gradient**.

**Add this inside `_CameraViewState`:**

```dart
late AnimationController _bgController;
late Animation<Alignment> _bgAlignment;

@override
void initState() {
  super.initState();
  _bgController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat(reverse: true);
  _bgAlignment = AlignmentTween(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ).animate(_bgController);
}

@override
void dispose() {
  _bgController.dispose();
  super.dispose();
}
```

**Replace the root `Container`'s `decoration` with:**

```dart
decoration: BoxDecoration(
  gradient: AnimatedBuilder(
    animation: _bgAlignment,
    builder: (context, child) {
      return LinearGradient(
        begin: _bgAlignment.value ?? Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.backgroundGradientVibrant,
        stops: const [0.0, 0.6, 1.0],
      );
    },
  ),
),
```

**Remove** the `RadialGradient` that currently exists—it will be replaced by this smoother gradient.

---

### 5. Glassmorphism + Gradient Borders (Floating Nav Bar & Top Bar)

**File:** `lib/views/camera_view.dart` (update `_FloatingNavBar` and `_TopBar`)

- Change background to `AppColors.glassBackground`.
- Add a **gradient border** using a `Container` with a `BoxDecoration` that uses a `LinearGradient` for the border.

**Use this wrapper for the Nav Bar:**

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.primaryGradient,
    ),
    borderRadius: BorderRadius.circular(30),
  ),
  child: Container(
    margin: const EdgeInsets.all(1.5), // creates the gradient border
    decoration: BoxDecoration(
      color: AppColors.glassBackground,
      borderRadius: BorderRadius.circular(30),
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ... existing icons ...
        ],
      ),
    ),
  ),
)
```

- Apply the **same gradient‑border technique** to the `_TopBar`’s Friends pill, so it looks like a glowing chip.

---

## 6. All‑Caps Section Titles & Emoji Prefixes

**File:** `lib/views/visit_list_view.dart` and `lib/views/camera_view.dart`

- Replace `'Memories'` with `'📸 MEMORIES'`.
- Replace `'Friends Activity'` with `'👥 FRIENDS'`.
- Use `AppTypography.sectionTitle` for these headings.

---

## 7. Shutter Button – Gradient Fill & Glow

**File:** `lib/widgets/custom_shutter.dart`

**Change the inner fill** from solid `AppColors.primary` to **gradient**:

```dart
Container(
  width: 68,
  height: 68,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.5),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  ),
)
```

---

## 8. Testing & Verification Checklist

After implementing the above:

- [ ] Run the app in **mock mode** (`kUseMockCamera = true`).
- [ ] Confirm the background gradient animates smoothly.
- [ ] Confirm the preview border glows with a shifting colour.
- [ ] Confirm the shutter button has a gradient and stronger glow.
- [ ] Confirm the floating nav bar and top pill have gradient borders.
- [ ] Confirm that **permission requests, capture, gallery picker, and add‑edit sheet still work** exactly as before.

---

## 9. Additional Polish (Optional but Recommended)

- **Status Bar:** Set `systemUiOverlayStyle` to `Brightness.light` with a transparent status bar (already done in `main.dart`).
- **Haptic Feedback:** Add a light impact when the shutter is tapped (but that’s Phase 2—skip for now).
