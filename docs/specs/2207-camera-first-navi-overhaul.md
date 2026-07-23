# Task: Camera‑First Navigation Overhaul – Remove Bottom Nav Bar, Add Custom Camera Controls

## Overview

We are pivoting to a **camera‑first** architecture. The app now launches directly to the full‑screen camera view, which is the home screen. The previous three‑tab (Friends, Camera, Memories) bottom navigation bar is **removed entirely**.

Instead, the camera screen includes a **custom bottom bar** with three controls:

- **Left:** Social Feed icon – opens the Friends/feed view (as an overlay, bottom sheet, or push).
- **Center:** Record button – triggers photo capture (or gallery picker in mock mode).
- **Right:** Memories icon – opens the user’s memory list (as a push or modal).

This design matches your vision: the camera is always the focal point; other sections are accessed via these dedicated buttons, not via a persistent tab bar.

---

## Required Changes

### 1. Remove Global Bottom Navigation

- **Delete** the `BottomNavigationBar` from `MainTabView`.
- `MainTabView` will now simply display `CameraView` as its only child (or we can eliminate `MainTabView` and set `CameraView` as the home directly).  
  **Option A:** Keep `MainTabView` but remove the IndexedStack and bottom bar. Set `home: const CameraView()` in `main.dart`.  
  **Option B:** Remove `MainTabView` entirely and use `CameraView` as the root.

We’ll go with **Option A** for minimal disruption – we can later remove the file.

### 2. CameraView – New Layout

- **Background:** Full‑screen, dark (black). For mock mode, use a blurred sample image as the background.
- **Camera Preview:** Square rounded rectangle (as previously specified) with white border and glow, centered in the screen.
- **Top bar:** Profile avatar (left), Friends sheet button (center), More options (right) – same as before.
- **Custom bottom bar:** A row placed above the bottom safe area, containing:
  - **Left:** Social feed icon (`Icons.people_alt` or similar) – 24pt, color `Colors.white` (or `AppColors.neutralLight`), with a label "Friends" below? (Optional: just icon, no label for minimalism).
  - **Center:** Record button – `CustomShutter` (80pt outer, 68pt inner), glowing.
  - **Right:** Memories icon (`Icons.grid_view` or similar) – 24pt, color `Colors.white`.
- **User name & timestamp:** Appear below the preview after capture (only if a photo is present).

### 3. Navigation Logic for Icons

- **Social Feed icon (left):** On tap, open a bottom sheet or push a page that shows the friends’ feed (currently a placeholder). For now, use `showModalBottomSheet` with a simple “Friends Feed” text, or push a `FriendsView` page (if already created).
- **Memories icon (right):** On tap, push `VisitListView` (the memories list) onto the navigation stack, so the user can go back to camera with a back button.

We need to ensure these navigations work without the tab bar.

### 4. Mock Mode Adjustments

- In mock mode, the background is a blurred sample image.
- The preview shows a sharp placeholder (e.g., a cafe photo).
- The shutter opens the image picker.

### 5. Background Color Fix

- The user disliked the secondary color (likely the glassmorphism background of the previous bottom bar). Since we are removing the bottom bar, the background of the camera screen should be pure black (`Colors.black`), and the custom bottom row should be transparent with white icons.

### 6. Preserve All Existing Functionality

- Permissions, flash, capture, add‑edit sheet, saving to database, etc., must remain unchanged.

---

## Implementation Steps

1. **Update `main.dart`:** Change `home` to `const CameraView()` (wrapped in `ProviderScope`). We can remove `MainTabView` or keep it as a placeholder, but set the home to `CameraView`.

2. **Update `CameraView`:**
   - Remove any reference to `MainTabView` or tab switching.
   - Add a custom bottom row using `Positioned` or `Align` with `bottom: 20 + MediaQuery.padding.bottom`.
   - Use `Row` with `MainAxisAlignment.spaceEvenly` or custom spacing.
   - Left icon: `GestureDetector` with `onTap: () => _openFriendsSheet()`.
   - Center: `CustomShutter`.
   - Right icon: `GestureDetector` with `onTap: () => _openMemories()`.

3. **Create helper methods:**
   - `_openFriendsSheet()`: shows a modal bottom sheet with a placeholder list of friends or a message.
   - `_openMemories()`: uses `Navigator.push` to go to `VisitListView`.

4. **Remove `MainTabView` (or keep but not used).** If we keep it, we can rename it or delete it later.

5. **Update `FriendsView` (if exists) or create a placeholder** for the friends sheet.

6. **Ensure the bottom row styling matches the design system:** icons should be white, with no background. The shutter button remains unchanged.

7. **Test on simulator (mock mode) and real device (real camera) to ensure navigation works and the camera still functions.**

---

## Deliverables

- Updated `lib/main.dart` to launch `CameraView` directly.
- Updated `lib/views/camera_view.dart` with the custom bottom bar and navigation logic.
- (Optional) Updated `lib/views/main_tab_view.dart` – either deleted or left unused.
- A clear description of the new navigation flow.

---

## Acceptance Criteria

1. The app starts directly on the camera screen with a square rounded preview.
2. The bottom bar shows only three items: social feed (left), shutter (center), memories (right).
3. Tapping social feed opens a modal sheet (or page) showing friends' activity.
4. Tapping memories navigates to the memory list with a back button to return to camera.
5. All camera functionality (permissions, flash, capture) works as before.
6. Mock mode works with placeholder and gallery picker.
7. The background is dark/black, no secondary color applied.

---

## Testing Instructions

- Run the app on simulator (mock mode) to see the new layout.
- Tap the left icon to open the friends sheet.
- Tap the right icon to go to memories, then use the back button to return.
- Tap the shutter to capture/select a photo and verify the add‑edit sheet opens.
- On real device, test camera permissions and real capture.

---

## Constraints

- Do not alter the existing camera viewmodel logic.
- Use `AppColors` and `AppTypography` for all styling.
- Keep the code clean and modular.
- Avoid introducing new dependencies.

---

**This prompt defines the full scope of the camera‑first navigation overhaul. Please implement all changes as described, providing the updated files and a summary of the new navigation flow.**
