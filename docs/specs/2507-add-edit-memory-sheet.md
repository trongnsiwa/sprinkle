# Refactor Sprinkle's Add/Edit Memory Sheet

## Context

Sprinkle is a Flutter camera-first memory journal (iOS/Android). Design system documented in `docs/design.md` and `docs/project-context.md`:

- **Primary**: `#FF6B6B` (CTAs, accents)
- **Secondary**: `#4ECDC4` (tags)
- **Typography**: SVN‑Gilroy via `AppTypography`
- **Spacing**: 4pt grid; margins 20pt, card padding 16pt
- **Corners**: 30pt (sheets), 20pt (cards), 14pt (buttons), 12pt (chips)
- **Glassmorphism**: backdrop blur for overlays

Current `AddEditView` works but feels utilitarian. Need a **polished, fun, and consistent** modal sheet.

---

## Core Tasks

1. **Refactor `AddEditView`**
   - Use design tokens throughout (`AppColors`, `AppTypography`, spacing, radii).
   - Maintain all existing logic: image picker, location fetch, tags parsing, rating, save.

2. **Extract reusable components** to `lib/widgets/`:
   - `SprinkleTextField` – supports underline (single-line) and outline (multi-line) styles with label, hint, active state.
   - `SprinkleButton` – primary filled button with loading and disabled states.
   - `VibePicker` – emoji rating row with haptic feedback and animated selection.

3. **Apply components globally** where beneficial (e.g., use `SprinkleButton` in other primary actions).

---

## Specific Changes

### Sheet Container

- `borderRadius: 30`, background `AppColors.surface`.
- Keep drag handle, header with title & close icon.

### Image Picker

- 120x120 container, edit icon overlay.
- Add dashed border when empty; show image with `ClipRRect` when selected.
- On tap, show bottom sheet for camera/gallery.

### Input Fields (use `SprinkleTextField`)

| Field | Style     | Label              | Hint                        |
| ----- | --------- | ------------------ | --------------------------- |
| Name  | Underline | PLACE / STORE NAME | e.g., Arabica Coffee        |
| Tags  | Underline | TAGS               | #cafe #coffee #matcha       |
| Notes | Outline   | NOTES              | Add memories, drinks tried… |

- Parse tags on change, display as chips below the field.

### Vibe Check (use `VibePicker`)

- Row of emoji buttons with `AnimatedScale` on selection.
- Show numeric rating below.

### Save Button (use `SprinkleButton`)

- Full-width, height 52pt, `AppTypography.headlineMedium` size 18.
- Loading state with `CircularProgressIndicator`, disabled when invalid/saving.
- On success: confetti burst + snackbar, then dismiss.

### Animations

- Keep `AnimatedScale` for emojis; keep confetti on save.

---

## Reusable Component Specs

### `SprinkleTextField`

Accepts: `label`, `hint`, `controller`, `onChanged`, a `style` enum (underline/outline), `maxLines`, and common `TextField` properties.

- Label uses `AppTypography.labelBold` with 6pt spacing below.
- Hint text uses `AppTypography.bodyLarge` in `AppColors.neutralLight`.
- Active state changes underline/border colour to `AppColors.primary`.

### `SprinkleButton`

Accepts: `onPressed`, `label`, `isLoading`, `isEnabled`.

- Background `AppColors.primary` (disabled: 40% opacity).
- Text white, size 18, bold.
- Height 52pt, `borderRadius: 14`.

### `VibePicker`

Accepts: `rating` (double) and `onRatingChanged` callback.

- Emoji buttons: tap triggers `HapticFeedback.lightImpact()`.
- Selected emoji scales with `AnimatedScale`.

---

## Verification

- [ ] All fields use `SprinkleTextField` with correct styles.
- [ ] Save button is `SprinkleButton` (loading/disabled states work).
- [ ] Emoji picker animates and updates rating.
- [ ] Layout matches design tokens (spacing, colours, typography).
- [ ] Existing functionality (image picker, location, save, edit) remains intact.
- [ ] Confetti plays and sheet dismisses after save.

---

## Instructions for Antigravity

- Create new files in `lib/widgets/` for reusable components.
- Refactor `lib/views/add_edit_view.dart` to use them.
- Update other views that can benefit (e.g., primary buttons in `visit_list_view.dart`).
- Ensure clean code, follow Riverpod patterns, and add comments.
- Run `flutter analyze` to catch lints.

**Goal**: A delightful, cohesive add/edit experience that feels part of a premium memory journal.
