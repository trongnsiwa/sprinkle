# Task: Refactor CameraView to Match the Locket‑Inspired Camera‑First Design

## Overview

We are redesigning the camera screen (`CameraView`) to be a camera‑first experience, inspired by the Locket app. The camera should be the center of attention, displayed as a **square rounded rectangle** that fills most of the screen. The bottom controls are repositioned to show **social feed** (left) and **memories** (right) icons flanking the shutter button. The top bar includes a profile avatar (left), a button to open a friends activity sheet (center), and a more options button (right). A user name and timestamp should appear below the preview **only after a photo is taken** (displaying the captured image’s metadata).

This refactor should **preserve all existing functionality**: camera permissions, flash toggle, capture, saving to database, and the add/edit sheet. Mock mode (`kUseMockCamera`) should still work for simulator testing.

---

## Design Specifications

### 1. Preview Shape and Layout

- **Shape:** Square (1:1 aspect ratio) with rounded corners.
- **Size:** Full width of the screen (minus horizontal padding of, say, 16pt, or just fill the width). The preview should be horizontally centered and vertically positioned with some margin from the top and bottom bars.
- **Corner radius:** Large (e.g., 24pt or 30pt) – use `BorderRadius.circular(24.0)`.
- **Decoration:** A white border (4pt) and a soft glow (primary color at 20% opacity, blur 20) around the preview container.
- **Content:** The camera preview (or placeholder in mock mode) should fill the square and be clipped to the rounded rectangle using `ClipRRect`.

### 2. Top Bar (Positioned at the top, inside SafeArea)

- **Left:** Profile avatar – a 40pt circle with a white person icon (or user's image if available), background `AppColors.primary` with 20% opacity. Tapping should eventually navigate to the user’s profile (for now, just show a snackbar or do nothing).
- **Center:** A button (or GestureDetector) that says "Friends" or shows a chevron/title. Tapping should open a modal sheet showing friends/following activities (for now, just a placeholder sheet with a list of dummy friends).
- **Right:** A "more options" icon (`Icons.more_horiz` or `Icons.settings`) – tapping can open a menu with settings (or a placeholder).

### 3. Camera Preview Container

- Placed in the center of the screen, with the top bar above and bottom controls below.
- Use `MediaQuery` to calculate the available height and set the square width = screen width - 32pt (or just screen width if you prefer full bleed).
- The container should be vertically centered in the remaining space after accounting for top and bottom controls.

### 4. Bottom Controls (Positioned below the preview, above the bottom navigation bar)

- **Row** with three items:
  - **Left:** Social feed icon – `Icons.people_alt` (or a custom icon), 24pt, color `AppColors.neutralLight` (active `AppColors.primary` if selected). On tap, navigate to Friends tab (index 0) or open the feed.
  - **Center:** Shutter button – existing `CustomShutter` (80pt outer ring, 68pt inner filled with primary, with glow).
  - **Right:** Memories icon – `Icons.grid_view` (or a custom icon), 24pt, color `AppColors.neutralLight` (active `AppColors.primary` if selected). On tap, navigate to Memories tab (index 2).
- Spacing: Distribute evenly with `MainAxisAlignment.spaceEvenly` or use fixed spacers. Ensure the shutter is centered.
- Vertical position: Place this row with a reasonable bottom margin (e.g., 20pt above the bottom navigation bar). The bottom navigation bar is always visible, so we need to account for its height (assume 56pt + safe area bottom). We can use `SizedBox(height: bottomBarHeight + 20)` or a `Positioned` with `bottom`.

### 5. User Name and Timestamp

- **Show only after a photo has been captured** and is being displayed in the preview (i.e., when `capturedImagePath` is not null and the add/edit sheet is not yet open? Or after the add/edit sheet is closed? The spec says "only after photo is taken" – we'll show it immediately after capture, before the sheet opens, as a temporary overlay on the preview.
- Position: Below the preview, centered, with `AppTypography.caption` style, white or light color, with a small spacing (4pt).
- Content: "You" and the current time (e.g., "You • 2:30 PM"). This can be hardcoded for now; later we can use the capture timestamp.

### 6. Flash and Camera Switch

- Keep the flash toggle as an icon in the top‑right corner (or integrate it with the more options). For simplicity, keep it at the top‑right of the preview (inside the preview area, like a small icon overlay).
- Alternatively, add a camera switch (front/back) icon next to the flash. For now, just keep the flash toggle.

### 7. Mock Mode

- When `kUseMockCamera` is true:
  - The background should be a blurred sample image (or a gradient) to simulate an immersive feed.
  - The preview should show a sharp placeholder image (e.g., a sample cafe photo).
  - The shutter button opens the image picker (gallery) instead of capturing.
- The layout should be identical to the real camera mode.

### 8. Overlay for Reactions/Activity (Optional)

- Not required for this phase, but we can leave a placeholder or a floating button for future.

---

## Implementation Steps

1. **Update `CameraView` widget:**
   - Change the root `Scaffold` background to `Colors.black` (or a dark gradient for mock).
   - Use a `Stack` with:
     - Background (full‑screen) – either `CameraPreview` (real) or a blurred image (mock).
     - Top bar (`SafeArea` with `Row`).
     - Preview container (square, rounded, with border and glow) – centered.
     - Bottom controls (`Row` with icons and shutter).
     - User name/timestamp overlay (conditionally visible after capture).

2. **Calculate preview size:**
   - Use `MediaQuery.of(context).size.width - 32` (or just `width`) for the square dimension.
   - To center vertically, use `Align` with `alignment: Alignment.center` and adjust with `Transform.translate` if needed.

3. **Bottom controls positioning:**
   - Since the bottom navigation bar is always visible, we need to offset the controls above it. Use:
     ```dart
     Positioned(
       bottom: MediaQuery.of(context).padding.bottom + 56 + 20, // bar height + spacing
       left: 0,
       right: 0,
       child: Row(...),
     )
     ```
   - Or use `SizedBox` at the bottom with `Spacer` to push the preview up.

4. **Top bar layout:**
   - Use `Row` with `mainAxisAlignment: MainAxisAlignment.spaceBetween`.
   - Left: `GestureDetector` with avatar.
   - Center: `GestureDetector` with `Text("Friends")` and a down arrow.
   - Right: `IconButton` with more options.

5. **Conditional timestamp:**
   - After capture, set a state variable `_capturedTime` (or use the existing `capturedImagePath` to trigger visibility). Show a `Text` below the preview.

6. **Mock mode adjustments:**
   - In `CameraView`, if `kUseMockCamera`:
     - Use a `Container` with `DecorationImage` (blurred) for the background.
     - Use a static `Image.asset` for the preview placeholder.
   - Ensure the shutter button calls `_pickImageFromGallery()` instead of `capturePhoto()`.

---

## Code Organization

- Keep `CameraView` as a `ConsumerStatefulWidget` to access the viewmodel.
- Extract the preview container into a private method or a separate widget for clarity.
- Keep the logic in the viewmodel (capture, flash, permissions) untouched.
- Add a new method `_openFriendsSheet()` for the center button (just a placeholder bottom sheet for now).

---

## Deliverables

- Complete updated `lib/views/camera_view.dart` with the new layout.
- Any necessary changes to `lib/utils/constants.dart` (if `kUseMockCamera` is not already defined).
- The new design should match the Locket‑style camera‑first experience.

---

## Acceptance Criteria

1. The camera preview is square and has rounded corners with a white border and glow.
2. The top bar shows avatar (left), "Friends" button (center), and more options (right).
3. The bottom controls show social feed icon (left), shutter (center), and memories icon (right).
4. The user name and timestamp appear below the preview only after a photo is taken.
5. All existing functionality (flash, permissions, capture, add‑edit sheet) works.
6. Mock mode works on simulator with placeholder image and gallery picker.
7. The bottom navigation bar is always visible below the controls.

---

## Testing Instructions

- Run the app on simulator (mock mode) to see the new layout.
- Tap the shutter to open the gallery, select an image, and verify the add‑edit sheet opens.
- After capturing (or selecting), check that the name/timestamp appears below the preview.
- Switch to real device (kUseMockCamera = false) and test camera permissions and capture.

---

## Constraints

- Do not change any viewmodel logic.
- Use `AppColors` and `AppTypography` for styling.
- Keep the code clean and well‑commented.

---

**This is the final specification for the camera view refactor. Please implement it following the steps above, and provide the complete `camera_view.dart` file.**
