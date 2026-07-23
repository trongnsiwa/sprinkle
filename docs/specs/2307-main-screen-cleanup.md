### 📋 Prompt for Antigravity: Main Screen Cleanup – "Simplify & Refine"

**Goal:** Clean up the visual mess on the main `CameraView`—reduce top bar clutter, fix the preview border, eliminate the white edge issue, and simplify the bottom nav bar with a solid, warm background.

**Issues to Fix:**

1. **Top Bar**: Too cluttered (avatar + Friends pill + streak + settings gear). Needs a cleaner, more minimal layout.
2. **Preview Border**: Weird rendering—dashed border looks broken or the shadow is off.
3. **Background**: White/cream edges at the top—gradient is too light and creates a harsh edge against the status bar.
4. **Bottom Nav Bar**: Glassmorphism is overcomplicating it—needs a simple, solid warm background.

**Constraints (Strict):**

- **DO NOT** change any `viewmodels/`, `services/`, or database logic.
- **DO NOT** alter camera capture, flash, or save flows.
- **DO** keep existing `Key`s and widget structures.
- **DO** use `Colors.transparent` where needed to avoid edge artifacts.

---

### 🔴 Fix 1: Clean Up the Top Bar (Reduce Clutter)

**File:** `lib/views/camera_view.dart` (inside `_TopBar`)

**Issues:**

- Streak badge (🔥) is distracting and adds visual noise.
- Settings gear is redundant (can be moved to a future profile screen).
- "Friends" pill is too wide and competes with the avatar.

**Action:** Streamline to **only 2 elements**:

- **Left**: Profile avatar (with a subtle online dot).
- **Center**: "Friends" pill (keep, but simplify—no gradient border, just a light capsule).
- **Right**: Streak badge OR settings gear—**choose one** and remove the other.

**Recommended Layout:**

```dart
// Inside _TopBar build method:
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Left: Avatar (slightly smaller, cleaner)
    GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Icon(
          Icons.person_rounded,
          size: 20,
          color: Colors.white,
        ),
      ),
    ),
    // Center: Friends Pill (simplified, no gradient border)
    GestureDetector(
      onTap: onFriendsTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Friends',
              style: AppTypography.labelBold.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '3',
                style: AppTypography.badgeNumber.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: isFriendsSheetOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    ),
    // Right: Streak badge (ONLY if streak > 0, otherwise empty)
    Consumer(
      builder: (context, ref, child) {
        final streakAsync = ref.watch(streakProvider);
        return streakAsync.when(
          data: (streak) {
            if (streak == 0) return const SizedBox(width: 40); // Placeholder to maintain layout
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: AppTypography.badgeNumber.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(width: 40),
          error: (_, __) => const SizedBox(width: 40),
        );
      },
    ),
  ],
)
```

**Note:** This removes the settings gear entirely (can be accessed via a long‑press on the avatar or a future profile screen). Streak now shows **only when > 0**, keeping the bar minimal.

---

### 🟡 Fix 2: Fix the Preview Border (Remove Broken Dashed Border)

**File:** `lib/widgets/square_preview.dart`

**Issue:** The dashed border attempt is rendering weirdly (probably because `Border` doesn't support dashes natively). The multi‑colored shadow is also creating a muddy edge.

**Action:** Replace the border with a **clean, solid 2px border** in a warm, soft color, and use a **single, soft shadow** (not multiple competing colors).

**Exact Code Snippet (replace the `Container` decoration):**

```dart
Container(
  width: targetWidth,
  height: targetHeight,
  decoration: BoxDecoration(
    color: const Color(0xFFF5EDE6), // Warm cream base
    borderRadius: BorderRadius.circular(32.0),
    border: Border.all(
      color: AppColors.warmCoral.withOpacity(0.3),
      width: 2.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        spreadRadius: -2,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  // ... child content
)
```

**If you want a subtle decorative touch**, add a **second thin border** inside using a `ClipRRect` child with a 0.5px border, but **keep it simple**—Gen‑Z aesthetic prefers clean, not busy.

---

### 🟢 Fix 3: Fix the Background White Edge (Gradient Edge Artifact)

**File:** `lib/views/camera_view.dart`

**Issue:** The cream/peach gradient has a white edge at the top because the gradient starts at `Color(0xFFFFF8F0)` (very light cream) and the status bar area isn't covered properly.

**Action:** Extend the gradient **slightly darker** at the top and ensure it fills the entire screen. Also, set the `Scaffold` background to `Colors.transparent` to avoid any underlying white.

**Exact Code Snippet:**

```dart
// 1. Update the gradient to start slightly darker:
Positioned.fill(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF5EDE6), // Warm cream (slightly darker than white)
          const Color(0xFFFFE5D9), // Peach
          const Color(0xFFFFF0ED), // Soft blush
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    ),
  ),
),

// 2. Ensure the Scaffold background is transparent:
// In the build method, update Scaffold:
Scaffold(
  backgroundColor: Colors.transparent, // Was Color(0xFF1C1C1E)
  // ... rest of the widget
)
```

**Also**, remove the `RadialGradient` that was previously in the `Stack`—it's no longer needed and may be causing the edge issue.

---

### 🔵 Fix 4: Redesign Bottom Nav Bar (Simple Solid Background)

**File:** `lib/views/camera_view.dart` (inside `_FloatingNavBar`)

**Issue:** The glassmorphism with gradient borders is overcomplicated and visually messy. It also doesn't fit the "warm, simple" aesthetic.

**Action:** Replace with a **simple, solid‑color capsule** with a soft shadow. Keep the raised camera button but simplify the background.

**Exact Code Snippet:**

```dart
// Inside _FloatingNavBar build method:
@override
Widget build(BuildContext context) {
  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE6).withOpacity(0.7), // Warm cream, slightly transparent
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Feed Button (Simple)
          GestureDetector(
            onTap: onFeedTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    size: 24,
                    color: const Color(0xFF3D2C1E).withOpacity(0.6),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Camera Button (Raised, Bouncy)
          _NavCameraButton(onTap: () {}),
          const SizedBox(width: 8),
          // Memories Button (Simple)
          GestureDetector(
            onTap: onMemoriesTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.grid_view_rounded,
                size: 24,
                color: const Color(0xFF3D2C1E).withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**Keep the `_NavCameraButton`** as defined in the previous prompt (it adds the playful bounce).

---

### 📐 Bonus: Adjust the Column Layout (Better Spacing)

**File:** `lib/views/camera_view.dart`

**Action:** Fine‑tune the vertical spacing to ensure the preview sits perfectly between the top bar and the bottom nav.

**Exact Code Snippet:**

```dart
// Inside the SafeArea → Column:
Column(
  children: [
    const SizedBox(height: 56), // Space for top bar (avatar + Friends pill)
    const Spacer(flex: 1),
    SquarePreview(
      // ... props
    ),
    const SizedBox(height: 24),
    _ShutterControls(
      // ... props
    ),
    const Spacer(flex: 2),
    const SizedBox(height: 20), // Space above bottom nav
    const _FloatingNavBar( // <-- MOVE THIS INSIDE THE COLUMN
      onFeedTap: _openFriendsSheet,
      onMemoriesTap: _openMemories,
    ),
    const SizedBox(height: 16), // Bottom padding
  ],
)
```

**Remove** the `Positioned` that previously held the `_FloatingNavBar`—it's now part of the `Column` layout, which is cleaner and easier to maintain.

---

### ✅ Verification Checklist

1. **Top Bar**: Only avatar + Friends pill + streak badge (if > 0). Settings gear is removed.
2. **Preview Border**: Clean, solid 2px border with a single soft shadow (no weird dashes).
3. **Background**: Warm cream/peach gradient with **no white edge** at the top.
4. **Bottom Nav**: Simple solid‑color capsule with a raised camera button.
5. **Layout**: Preview is centered with proper breathing room.
6. **All existing functionality** (capture, gallery picker, add‑edit) still works.

---

**End of Prompt.**
