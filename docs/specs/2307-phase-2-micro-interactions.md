### 📋 Prompt for Antigravity: Phase 2 – Micro-Interactions (Dopamine Hits)

**Goal:** Add playful, satisfying micro‑interactions to make Sprinkle feel alive and joyful—haptic feedback on shutter, confetti burst on save, a "Vibe Check" emoji row instead of a numeric rating slider, and a cheerful confirmation snackbar.

---

### Instructions

1. **Haptic Feedback on Shutter Tap**
   - In `lib/views/camera_view.dart`, inside the shutter `onTap` callback, add `HapticFeedback.mediumImpact()` right before calling `capturePhoto()`.

2. **Confetti Burst on Successful Save**
   - Add `confetti: ^0.7.0` to `pubspec.yaml` and run `flutter pub get`.
   - In `lib/views/add_edit_view.dart`:
     - Add a `ConfettiController` (duration: 2 seconds) to `_AddEditViewState`, initialize in `initState`, dispose in `dispose`.
     - After `viewModel.save()` succeeds, call `_confettiController.play()`.
     - Add a `ConfettiWidget` at the top of the widget tree (wrapped in a `Stack`) with explosive blast direction and playful colors (coral, mint, yellow, white).

3. **"Vibe Check" Emoji Row (Replace Numeric Rating Slider)**
   - In `lib/views/add_edit_view.dart`, replace the current rating UI (stars or slider) with a row of tappable emojis:
     - 😍 = 5.0 (Love it)
     - 😊 = 4.0 (Great)
     - 😐 = 3.0 (Mid)
     - 🤮 = 1.0 (Trash)
   - When tapped, highlight the emoji with a subtle scale animation or border glow, and call `viewModel.setRating(value)`.

4. **"Collected!" SnackBar**
   - Inside the same save success block, after `_confettiController.play()`, show a `SnackBar` with a checkmark icon and text "Collected! ✨" (duration: 800ms, background: coral).

5. **(Optional) Location Auto‑fill**
   - If you want to reduce friction, use the `geolocator` and `geocoding` packages to auto‑fill the place name when the Add/Edit sheet opens. Only apply if the name field is empty.

---

### Keep Unchanged

- All camera capture, flash, gallery picker, and navigation logic.
- The new bottom nav bar and UI polish from Phase 1–3.

---

### Verification Checklist

- [ ] Tapping the shutter produces a tactile buzz (on real device).
- [ ] Saving a memory triggers confetti explosion from the center.
- [ ] The rating section now shows emoji pills instead of stars/slider.
- [ ] A "Collected! ✨" snackbar appears after save.
- [ ] All existing functionality (capture, gallery, memory list) still works.

---

**End of Prompt.**
