### 📋 Prompt for Antigravity: Phase 2 – Micro-Interactions (Dopamine Hits)

**Goal:** Add playful, satisfying micro‑interactions that trigger on key user actions (shutter tap, save, and rating) to make Sprinkle feel alive, responsive, and genuinely "happy" to use.

**Constraints (Strict):**

- **DO NOT** break existing capture, save, or database flows.
- **DO** keep all Riverpod providers and Isar operations unchanged.
- **DO** add new packages only where explicitly instructed.
- **DO** keep animations performant (use `AnimationController` where needed, avoid heavy rebuilds).

---

### 📦 Step 1: Add Required Dependencies

**File:** `pubspec.yaml`

Add these two packages under `dependencies`:

```yaml
dependencies:
  # ... existing ...
  confetti: ^0.7.0 # For burst of sparks on save
  geolocator: ^13.0.1 # For location (auto‑place name – Phase 2.5, optional)
  geocoding: ^3.0.0 # For reverse geocoding (Phase 2.5)
```

Run `flutter pub get` after adding.

---

### 🎉 Fix 1: Confetti Burst on Successful Save

**File:** `lib/views/add_edit_view.dart`

**Goal:** When the user taps "Save" and the record is successfully persisted, trigger a celebratory confetti explosion.

**Action:**

1. Add a `ConfettiController` (from the `confetti` package) to `_AddEditViewState`.
2. Initialize it in `initState` and dispose in `dispose`.
3. After `viewModel.save()` succeeds, trigger the confetti for ~2 seconds.

**Exact Code Snippet:**

```dart
// At the top of the file:
import 'package:confetti/confetti.dart';

// Inside _AddEditViewState:
late ConfettiController _confettiController;

@override
void initState() {
  super.initState();
  _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  // ... existing init code ...
}

@override
void dispose() {
  _confettiController.dispose();
  // ... existing dispose ...
  super.dispose();
}

// Inside the save button's onPressed, right after saving successfully:
final savedRecord = await viewModel.save();
if (savedRecord != null && context.mounted) {
  _confettiController.play(); // 🎉 Burst of joy!
  ref.read(visitListViewModelProvider.notifier).fetchVisits();
  // Optionally wait a moment before popping to let the confetti show
  await Future.delayed(const Duration(milliseconds: 400));
  if (mounted) Navigator.of(context).pop(savedRecord);
}

// Add the ConfettiWidget somewhere in the widget tree (e.g., at the top of the Stack):
return Stack(
  children: [
    // ... your existing form content ...
    ConfettiWidget(
      controller: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      colors: const [
        AppColors.primary,
        AppColors.secondary,
        Color(0xFFFFD700),
        Color(0xFFFF6B6B),
        Color(0xFF4ECDC4),
      ],
      numberOfParticles: 30,
      gravity: 0.2,
    ),
  ],
);
```

---

### 📳 Fix 2: Haptic Feedback on Shutter Tap

**File:** `lib/views/camera_view.dart` (inside `_CameraViewState`)

**Goal:** When the user taps the shutter button, provide a satisfying tactile response.

**Action:** Add `HapticFeedback.mediumImpact()` inside the shutter's `onTap` callback, right before capturing.

**Exact Code Snippet:**

```dart
// Inside _CameraViewState, find the onShutterTap callback:
onShutterTap: () async {
  // 🎯 Add haptic feedback immediately
  HapticFeedback.mediumImpact();

  _triggerShutterFlash();
  final capturedPath = await viewModel.capturePhoto();
  if (capturedPath != null) {
    _openAddSheet(capturedPath);
  }
},
```

---

### 😍 Fix 3: "Vibe Check" Emoji Row (Replace Numeric Rating Slider)

**File:** `lib/views/add_edit_view.dart`

**Goal:** Replace the current `StarRating` (or numeric slider) with a row of large, tappable emoji pills that instantly set the rating in a fun, Gen‑Z way.

**Emoji Mapping:**

- 🤯 = 5.0 (Mind‑blowing)
- 😍 = 4.0 (Love it)
- 😐 = 3.0 (Mid)
- 🤮 = 1.0 (Trash)

**Action:**

1. Remove the current `StarRating` widget from the form.
2. Add a new `_VibeCheckRow` widget (can be a method inside the same file).
3. Highlight the selected emoji with a glow or scale animation.
4. Connect to `viewModel.setRating()`.

**Exact Code Snippet:**

```dart
// Inside _AddEditViewState, add this method:
Widget _buildVibeCheck() {
  final vibes = [
    {'emoji': '🤯', 'value': 5.0},
    {'emoji': '😍', 'value': 4.0},
    {'emoji': '😐', 'value': 3.0},
    {'emoji': '🤮', 'value': 1.0},
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('VIBE CHECK', style: AppTypography.sectionTitle),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: vibes.map((vibe) {
          final isSelected = state.rating == vibe['value'];
          return GestureDetector(
            onTap: () => ref.read(addEditViewModelProvider.notifier).setRating(vibe['value'] as double),
            child: AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Text(
                  vibe['emoji'] as String,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      if (state.rating > 0)
        Center(
          child: Text(
            '${state.rating.toStringAsFixed(1)} / 5.0',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  );
}

// Then, in the build method, replace the old Rating section with:
_buildVibeCheck(),
```

---

### ✨ Fix 4: "Collected!" SnackBar with Icon (Quick Win)

**File:** `lib/views/add_edit_view.dart`

**Goal:** After saving, immediately show a cheerful confirmation.

**Action:** Inside the save success block, after `_confettiController.play()`, show a `SnackBar` with a checkmark and "Collected! ✨".

**Exact Code Snippet:**

```dart
// Inside the onPressed after successful save:
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white),
          SizedBox(width: 8),
          Text('Collected! ✨'),
        ],
      ),
      backgroundColor: AppColors.primary,
      duration: Duration(milliseconds: 800),
    ),
  );
}
```

---

### ✅ Verification Checklist (Run after implementation)

1. Run the app in **mock mode**.
2. Tap the shutter → feel the **haptic feedback** (on a real device) and see the flash.
3. Capture a photo → the Add/Edit sheet opens.
4. Tap an emoji in the **Vibe Check** row → the rating updates and the emoji scales up.
5. Fill in a name and tap **Save** → confetti bursts from the center of the screen.
6. The "Collected!" SnackBar appears at the bottom.
7. The sheet closes and the new memory appears in the list.
8. **All existing functionality** (permissions, gallery picker, editing existing records) still works.

---

### 📌 Optional Enhancement (Phase 2.5 – Location Auto‑fill)

If you want to go further, add reverse geocoding to auto‑fill the place name:

**File:** `lib/views/add_edit_view.dart` (in `initState` or when the sheet opens)

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Inside _AddEditViewState:
Future<void> _fetchLocation() async {
  try {
    final position = await Geolocator.getCurrentPosition();
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final name = '${place.name}, ${place.locality}';
      // Only set if user hasn't typed anything
      if (_nameController.text.isEmpty) {
        _nameController.text = name;
        ref.read(addEditViewModelProvider.notifier).setName(name);
      }
    }
  } catch (_) {}
}

// Call this in initState (after a short delay to avoid blocking UI):
WidgetsBinding.instance.addPostFrameCallback((_) {
  _fetchLocation();
});
```

---

**End of Prompt.**
