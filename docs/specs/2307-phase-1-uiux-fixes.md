### 📋 Prompt for Antigravity: Phase 1 – UI/UX Fixes (Post-Screenshot Review)

**Goal:** Fix the 5 critical visual issues identified in the latest screenshot so Sprinkle looks vibrant, fun, and polished—not flat or "developer‑like".

**Constraints (Strict):**

- **DO NOT** change any `viewmodels/`, `services/`, `models/`, or database logic.
- **DO NOT** alter camera capture, flash, permissions, or save flows.
- **DO** keep existing `Key`s and widget structures.
- **DO** use only the existing `AppColors` and `AppTypography` tokens.

---

### 🔴 Fix 1: Background Gradient is Invisible (Was Flat Black)

**File:** `lib/views/camera_view.dart`  
**Issue:** The dark vignette overlay (`alpha: 0.45`) is drowning out the vibrant gradient, and the old `Color(0xFF1C1C1E)` container is still present.

**Action:**

1. Locate the `Positioned.fill` that contains the `AnimatedBuilder` for the background gradient (added in Phase 1). Ensure it is placed **before** the vignette overlay.
2. Find the "Dark vignette overlay" `Positioned.fill` and change its opacity from `0.45` to `0.15`.

**Exact Code Snippet for the overlay:**

```dart
// BEFORE (current):
color: const Color(0xFF1C1C1E).withValues(alpha: 0.45),

// AFTER (fixed):
color: Colors.black.withValues(alpha: 0.15), // Let the purple/blue gradient shine through
```

---

### 🔴 Fix 2: Shutter Button is Flat (Missing Gradient)

**File:** `lib/widgets/custom_shutter.dart`  
**Issue:** The inner circle is still a solid `AppColors.primary` color instead of the sunset gradient.

**Action:** Replace the inner `Container`'s `decoration` with a `LinearGradient` using `AppColors.primaryGradient`.

**Exact Code Snippet:**

```dart
// Inside the build method, find the inner Container (width: 68, height: 68)
child: Container(
  width: 68,
  height: 68,
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.6),
        blurRadius: 24,
        spreadRadius: 4,
      ),
    ],
  ),
),
```

---

### 🟡 Fix 3: Remove the "1x" Zoom Badge (Kills the Fun Vibe)

**File:** `lib/widgets/square_preview.dart`  
**Issue:** The technical "1x" badge in the top-right corner makes the app look like a developer tool, not a social Gen‑Z app.

**Action:** **Delete entirely** the `Positioned` widget that renders the "1x" badge (approximately lines 191–209 in your current file).

**Exact Code to Delete:**

```dart
// DELETE this entire block:
// Positioned(
//   top: 12,
//   right: 12,
//   child: Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(
//       color: Colors.black.withValues(alpha: 0.35),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: const Text(
//       '1x',
//       style: TextStyle(
//         color: Colors.white,
//         fontSize: 11,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   ),
// ),
```

---

### 🟡 Fix 4: Replace "DEV MOCK" with a Subtle "BETA" Tag

**File:** `lib/views/camera_view.dart`  
**Issue:** The white semi-transparent "DEV MOCK" badge in the top-right looks heavy and unpolished.

**Action:** Replace it with a smaller, darker "BETA" tag positioned inside the preview area (bottom‑right corner).

**Exact Code Snippet:**

```dart
if (cameraState.isMockMode)
  Positioned(
    bottom: MediaQuery.of(context).padding.bottom + 160, // Adjust to sit inside preview
    right: 24,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        'BETA',
        style: AppTypography.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    ),
  ),
```

---

### 🟢 Fix 5: Floating Nav Bar Icons Are Too Small

**File:** `lib/views/camera_view.dart` (inside `_FloatingNavBar`)  
**Issue:** The Feed and Memories icons at `size: 22` feel lost and lack "dopamine" visual weight.

**Action:** Increase the icon size from `22` to `26` for all three icons in the floating nav bar.

**Exact Code Snippet:**

```dart
// Inside _FloatingNavBar build method, update the Icon sizes:
// Left Tab (Feed):
Icon(Icons.people_alt_rounded, size: 26, color: ...),

// Center Tab (Camera) – inside the Container:
Icon(Icons.camera_alt_rounded, size: 26, color: Colors.white),

// Right Tab (Memories):
Icon(Icons.grid_view_rounded, size: 26, color: ...),
```

---

### ✅ Verification Checklist (Run this after implementation)

1. Run the app in **mock mode** (`kUseMockCamera = true`).
2. Confirm the background now shows a **visible purple/blue gradient** (not flat black).
3. Confirm the shutter button inner circle has a **sunset gradient** and a stronger glow.
4. Confirm the **"1x" badge is completely gone** from the preview.
5. Confirm the mock badge now says **"BETA"** in small, dark letters.
6. Confirm the floating nav bar icons are **larger and more prominent**.
7. Confirm **capture, gallery picker, and add‑edit sheet still work** perfectly.

---

**End of Prompt.**
