# Sprinkle – Project Context (Flutter)

## App Overview

Sprinkle is a modern Flutter camera‑first memory journal available on iOS and Android. Users capture photos of cafes, restaurants, or stores, then save them with a name, rating, notes, and tags. The design is minimal, premium, and inspired by the Locket social app.

**Platform:** Flutter (iOS & Android)  
**Language:** Dart  
**UI Framework:** Flutter Widgets  
**State Management:** Riverpod (`flutter_riverpod`)  
**Persistence:** Isar Database (`VisitRecord` collection)  
**Camera:** `camera` plugin  
**Permissions:** `permission_handler`  
**Image Processing:** `image` package + `path_provider`  
**Font:** SVN‑Gilroy (registered in `pubspec.yaml`, supports Vietnamese)

---

## Design System (Minimalist Premium)

### Colors

| Role                | Hex       | Usage                                                   |
| ------------------- | --------- | ------------------------------------------------------- |
| Primary             | `#FF6B6B` | Shutter fill, active tab tint, key CTAs – use liberally |
| On‑Primary          | `#FFFFFF` | White text/icons on primary                             |
| Secondary           | `#4ECDC4` | Tags, subtle accents – use sparingly                    |
| On‑Secondary        | `#FFFFFF` | White text on secondary                                 |
| Neutral             | `#1A1A1A` | Primary text (dark, not pure black)                     |
| Neutral Light       | `#8E8E93` | Secondary text, placeholder text                        |
| Neutral Ultra Light | `#F2F2F7` | Backgrounds, dividers                                   |
| Surface             | `#FFFFFF` | Cards, sheets, list items                               |
| Star Gold           | `#FF9500` | Star ratings                                            |
| Error               | `#BA1A1A` | Destructive actions                                     |
| Error Container     | `#FFDAD6` | Light error background                                  |

### Typography (SVN‑Gilroy)

| Style           | Size | Weight         | Letter Spacing | Usage                     |
| --------------- | ---- | -------------- | -------------- | ------------------------- |
| Display Large   | 34pt | Bold (700)     | -0.5px         | Large titles ("Memories") |
| Headline Large  | 28pt | Bold (700)     | 0              | Section headers           |
| Headline Medium | 20pt | Semibold (600) | 0              | Card titles               |
| Body Large      | 17pt | Regular (400)  | 0              | Body text, forms          |
| Body Small      | 15pt | Regular (400)  | 0              | Secondary text            |
| Label Bold      | 13pt | Semibold (600) | +0.2px         | Tags, buttons             |
| Caption         | 12pt | Regular (400)  | 0              | Meta info, dates          |

### Shapes & Spacing

| Token                   | Value                        |
| ----------------------- | ---------------------------- |
| Corner Radius (Large)   | 20–30pt (sheets, cards)      |
| Corner Radius (Small)   | 12–16pt (images, thumbnails) |
| Corner Radius (Capsule) | 9999px (tags, chips)         |
| Spacing Unit            | 4pt (base)                   |
| Standard Margins        | 20pt (left/right)            |
| Card Padding            | 16pt                         |
| Safe Area Buffer        | 40–50pt (floating controls)  |

### Elevation & Shadows

| Level       | Style                                        | Usage                            |
| ----------- | -------------------------------------------- | -------------------------------- |
| 0 (Base)    | Flat                                         | Backgrounds, surfaces            |
| 1 (Card)    | `BoxShadow(#000000 8% opacity, blur 6, Y 4)` | Cards, list items                |
| 2 (Overlay) | `BackdropFilter` glass blur                  | Tab bar, floating controls       |
| 3 (Primary) | `BoxShadow(#FF6B6B 40% opacity, blur 12)`    | Shutter button glow              |

---

## Navigation Structure (3‑Tab Bar)

| Tab | Icon              | Label    | Content                          |
| --- | ----------------- | -------- | -------------------------------- |
| 1   | `people_alt`      | Friends  | Placeholder (future feed)        |
| 2   | `camera_alt`      | Camera   | Full‑screen camera (main screen) |
| 3   | `grid_view`       | Memories | Grouped timeline                 |

**Tab Bar Style:** Translucent glassmorphism (`BackdropFilter`).  
**Active Tint:** Primary (`#FF6B6B`).  
**Inactive Tint:** Neutral Light (`#8E8E93`).

---

## Camera Tab – Exact Layout (Locket‑inspired)

### 1. Status Bar

- Transparent background with white status bar elements on camera preview.

### 2. Top‑Left – Profile

- Avatar: 40pt circle – Primary (`#FF6B6B`) at 20% opacity with a white person icon (24pt).
- Label: "Friends" – white, 13pt, 70% opacity, 4pt below avatar.

### 3. Top‑Right – Flash

- Icon: `flash_off` (off) / `flash_on` (on).
- Size: 20pt.
- Color: White (off) / Yellow `#FFCC00` (on).
- Plain icon (no background circle).

### 4. Bottom Controls (Centered Group)

- Left – Thumbnail: 50pt circle – shows last captured image with 2pt white border. If empty, show placeholder icon.
- Center – Shutter: Outer ring (80pt, white, 4pt stroke) + Inner circle (68pt, Primary `#FF6B6B` solid fill).
- Right – Empty: 50pt spacer for layout balance.
- Spacing: 40pt between thumbnail and shutter.
- Padding from bottom safe area: 40pt.

### 5. Camera Preview Background

- Pure black (`#000000`).

---

## Project File Structure & Responsibilities

```
sprinkle/
├── assets/
│   └── fonts/                         – SVN-Gilroy font files
├── docs/
│   ├── design.md                      – Design system specification
│   └── project-context.md             – Project context & guidelines
├── lib/
│   ├── main.dart                      – App entry point, Isar init, Riverpod scope
│   ├── models/
│   │   ├── visit_record.dart          – Isar @collection data model
│   │   └── visit_record.g.dart        – Generated Isar schema code
│   ├── services/
│   │   ├── database_service.dart      – Isar database wrapper & CRUD operations
│   │   ├── permission_service.dart    – Camera & gallery permission handling
│   │   └── image_service.dart         – Image compression, saving, & deletion
│   ├── viewmodels/
│   │   ├── camera_viewmodel.dart      – Camera controller, capture, & thumbnail state
│   │   ├── visit_list_viewmodel.dart  – Memory records fetching & deletion logic
│   │   └── add_edit_viewmodel.dart    – Form state, image picker, & validation
│   ├── views/
│   │   ├── main_tab_view.dart         – 3-tab navigation root & glass tab bar
│   │   ├── camera_view.dart           – Locket-inspired full-screen camera
│   │   ├── visit_list_view.dart       – Memories card timeline
│   │   ├── add_edit_view.dart        – Modal form sheet for adding/editing
│   │   └── visit_detail_view.dart     – Detailed view of a single memory
│   ├── widgets/
│   │   ├── custom_shutter.dart        – 80pt Locket-style shutter button
│   │   ├── custom_thumbnail.dart      – Circular/rounded async thumbnail widget
│   │   └── star_rating.dart           – 5-star interactive & display rating bar
│   ├── utils/
│   │   ├── colors.dart                – Semantic color design tokens
│   │   ├── typography.dart            – SVN-Gilroy text styles
│   │   └── date_formatter.dart        – DateTime extensions for friendly strings
│   └── extensions/
│       └── context_extensions.dart    – BuildContext utility extensions
├── pubspec.yaml                       – Dependencies & asset registrations
└── README.md
```

---

## Architecture Rules (Best Practices)

1. **Separation of Concerns:** Views = layout + Riverpod consumers. ViewModels (`StateNotifier` / `Notifier`) = state management & business logic.
2. **Concurrency:** Use `async`/`await` for asynchronous file and database operations.
3. **Error Handling:** `try-catch` blocks with UI feedback.
4. **Isar Operations:** Perform database writes inside `writeTxn`.
5. **Image Storage:** Always use `ImageService` for saving, resizing, and deleting local images.
6. **Permissions:** Check `PermissionService` before requesting camera or gallery access.
7. **No Force‑Unwrapping:** Handle nullable parameters safely with guard checks or default values.

---

## Current Implementation Goal

We redesigned the camera tab and core memory system for Flutter to match the Locket camera layout (minimal, premium, polished).
The app features:

- Full-screen camera preview on pure black background.
- Top-left profile avatar + "Friends" label.
- Top-right flash toggle.
- Bottom-centered thumbnail + shutter button.
- Memory timeline list, interactive form sheet, detail view, and Isar database persistence.
