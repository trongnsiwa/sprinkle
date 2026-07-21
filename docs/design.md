# Sprinkle – Design System

**Version:** 2.0  
**Last Updated:** 2026  
**Platform:** Flutter (iOS & Android)  
**Primary Font:** SVN‑Gilroy

---

## Brand & Style

Sprinkle is a camera‑first memory journal. The design philosophy is **Minimalist Premium** – clean, airy, and polished, inspired by the Locket app. Every element should feel intentional, joyful, and non‑intrusive.

**Key principles:**

- **Simplicity** – remove anything unnecessary.
- **Consistency** – reuse colours, spacing, and typography religiously.
- **Depth through glass** – use translucent materials and background blurs for overlays.
- **Softness** – high corner radii, no sharp edges.
- **Vibrancy with restraint** – one primary colour used boldly, everything else stays neutral.

---

## Colors

### Brand Colours (Primary & Secondary)

| Role             | Hex       | Name                  | Usage                                                                |
| ---------------- | --------- | --------------------- | -------------------------------------------------------------------- |
| **Primary**      | `#FF6B6B` | `AppColors.primary`   | Shutter fill, active tab tint, key CTAs, accents – use **liberally** |
| **On‑Primary**   | `#FFFFFF` | –                     | White text/icons on primary surfaces                                 |
| **Secondary**    | `#4ECDC4` | `AppColors.secondary` | Tags, subtle accents – use **sparingly**                             |
| **On‑Secondary** | `#FFFFFF` | –                     | White text on secondary surfaces                                     |

### Neutral & Support Colours

| Role                    | Hex       | Name                         | Usage                                       |
| ----------------------- | --------- | ---------------------------- | ------------------------------------------- |
| **Neutral**             | `#1A1A1A` | `AppColors.neutral`          | Primary text (dark, not pure black)         |
| **Neutral Light**       | `#8E8E93` | `AppColors.neutralLight`     | Secondary text, placeholder, inactive icons |
| **Neutral Ultra Light** | `#F2F2F7` | `AppColors.neutralUltraLight`| Backgrounds, dividers                       |
| **Surface**             | `#FFFFFF` | `AppColors.surface`          | Cards, sheets, list items                   |
| **Star Gold**           | `#FF9500` | `AppColors.starGold`         | Star ratings (unchanged)                    |
| **Error**               | `#BA1A1A` | `AppColors.error`            | Destructive actions                         |
| **Error Container**     | `#FFDAD6` | `AppColors.errorContainer`   | Light error background                      |

### Semantic Aliases

- `AppColors.background` → `AppColors.neutralUltraLight`
- `AppColors.onBackground` → `AppColors.neutral`
- `AppColors.outline` → `AppColors.neutralLight` (at 30% opacity)

---

## Typography

**Font Family:** SVN‑Gilroy (supports Vietnamese, clean geometric sans‑serif with rounded terminals)

### Text Styles

| Style               | Size | Weight         | Letter Spacing | Line Height | Usage                                                 |
| ------------------- | ---- | -------------- | -------------- | ----------- | ----------------------------------------------------- |
| **Display Large**   | 34pt | Bold (700)     | -0.5px         | 41px        | Large titles (e.g., "Memories" in the navigation bar) |
| **Headline Large**  | 28pt | Bold (700)     | 0              | 34px        | Section headers (e.g., "June 2026")                   |
| **Headline Medium** | 20pt | Semibold (600) | 0              | 25px        | Card titles, sheet titles                             |
| **Body Large**      | 17pt | Regular (400)  | 0              | 22px        | Body text, form inputs, notes                         |
| **Body Small**      | 15pt | Regular (400)  | 0              | 20px        | Secondary text, descriptions                          |
| **Label Bold**      | 13pt | Semibold (600) | +0.2px         | 18px        | Tags, buttons, small labels                           |
| **Caption**         | 12pt | Regular (400)  | 0              | 16px        | Meta info, dates, timestamps                          |

### Font Usage Guidelines

- Use **Bold** for titles and headers.
- Use **Semibold** for section headings and emphasised labels.
- Use **Regular** for all body content.
- Always register and load SVN‑Gilroy via `pubspec.yaml` to match the aesthetic.

---

## Shapes & Corners

| Token                        | Value  | Usage                             |
| ---------------------------- | ------ | --------------------------------- |
| **Rounded‑xl (extra large)** | 30pt   | Large sheets, modal presentations |
| **Rounded‑lg (large)**       | 20pt   | Cards, main containers            |
| **Rounded‑md (medium)**      | 14pt   | Buttons, input fields             |
| **Rounded‑sm (small)**       | 12pt   | Images, thumbnails                |
| **Rounded‑full**             | 9999px | Tags, chips, circular elements    |

**Note:** All surfaces should have rounded corners – no sharp edges.

---

## Spacing & Layout

### Spacing Scale (based on 4pt unit)

| Token   | Value | Usage                                   |
| ------- | ----- | --------------------------------------- |
| **xs**  | 4pt   | Minimal spacing between inline elements |
| **sm**  | 8pt   | Spacing between related elements        |
| **md**  | 16pt  | Card padding, section spacing           |
| **lg**  | 24pt  | Spacing between sections                |
| **xl**  | 32pt  | Large spacing (e.g., between sections)  |
| **xxl** | 48pt  | Section breaks                          |

### Layout Margins

- **Standard horizontal margin:** 20pt (left and right of screen).
- **Card padding:** 16pt (inside cards).
- **Safe area buffer:** 40–50pt for floating elements (shutter, thumbnail).
- **Spacing between shutter and thumbnail:** 40pt.

---

## Elevation & Depth

### Shadow System

| Level           | Style                                                               | Usage                              |
| --------------- | ------------------------------------------------------------------- | ---------------------------------- |
| **0 (Base)**    | None (flat)                                                         | Backgrounds, surfaces              |
| **1 (Card)**    | Drop shadow: `color: #000000`, opacity 8%, blur 6px, Y‑offset 4px   | Cards, list items, detail surfaces |
| **2 (Overlay)** | Glass blur backdrop filter                                          | Tab bar, floating glass controls   |
| **3 (Primary)** | Drop shadow: `color: #FF6B6B`, opacity 40%, blur 12px, Y‑offset 0px | Shutter button (glow)              |

**Guidelines:**

- Avoid harsh black shadows – always soft and diffused.
- For glass elements, rely on backdrop material blur rather than heavy shadows.
- The shutter glow is the only coloured shadow – used sparingly.

---

## Components

### Buttons

#### Shutter Button (Primary Action)

- **Outer ring:** 80pt diameter, 4pt stroke, pure white (`#FFFFFF`).
- **Inner fill:** 68pt diameter, solid `Primary` (`#FF6B6B`).
- **Glow:** Level 3 shadow (`#FF6B6B` at 40% opacity, 12px blur).
- **Position:** Centered horizontally, 40pt from bottom safe area.

#### Glass Buttons (Secondary Controls)

- **Size:** 44pt diameter.
- **Background:** Translucent glass container with backdrop blur filter.
- **Icon:** 20pt system icon, white (or yellow for flash on).
- **Shadow:** Level 2.
- **Usage:** Flash toggle, profile avatar.

### Tags & Chips

- **Height:** 28pt.
- **Corner radius:** Capsule (`9999px`).
- **Padding:** Horizontal 12pt, vertical 4pt.
- **Background:** `Secondary` (`#4ECDC4`) at 20% opacity.
- **Text:** `Label Bold` (`13pt`, Semibold, `#4ECDC4`).
- **Spacing between tags:** 8pt.

### Cards (Memory Items)

- **Background:** `Surface` (`#FFFFFF`).
- **Corner radius:** `rounded‑lg` (`20pt`).
- **Padding:** `md` (`16pt`).
- **Shadow:** Level 1.
- **Content:** Thumbnail (left, 60x60pt, rounded‑sm), title, rating, date.

### Input Fields (Forms)

- **Style:** Borderless with a bottom divider (`Neutral Light` at 30% opacity).
- **Height:** 44pt (minimum touch target).
- **Font:** `Body Large` (`17pt`, Regular).
- **Placeholder color:** `Neutral Light`.
- **Active state:** Bottom divider becomes `Primary`.

### Tab Bar

- **Style:** Translucent glassmorphism (`BackdropFilter`), blurred overlay.
- **Height:** Standard navigation bar height (approx 83pt including safe area).
- **Tabs:** 3 items – Friends, Camera, Memories.
- **Active Tint:** `Primary` (`#FF6B6B`).
- **Inactive Tint:** `Neutral Light` (`#8E8E93`).
- **Icons:** Material / Cupertino icons (`people`, `camera`, `grid_view`).
- **Labels:** Sentence case, `Caption` (`12pt`, Regular).

---

## Camera Tab – Specific Layout

| Element                       | Specification                                                                                                                                 |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **Status Bar**                | Transparent background, white text/icons                                                                                                      |
| **Top‑Left Avatar**           | 40pt circle, background `Primary` at 20% opacity, white person icon, 24pt. Label "Friends" below, white, 13pt, 70% opacity                    |
| **Top‑Right Flash**           | 20pt icon (`flash_off` or `flash_on`), no background circle. White (off) / Yellow `#FFCC00` (on)                                              |
| **Bottom‑Left Thumbnail**     | 50pt circle. Shows last captured image with 2pt white border. Empty state: white camera icon at 30% opacity                                   |
| **Bottom‑Center Shutter**     | Outer ring: 80pt, white, 4pt stroke. Inner: 68pt, `Primary` solid fill. Glow: `#FF6B6B` 40% opacity, 12px blur                                |
| **Camera Preview Background** | Pure black (`#000000`)                                                                                                                        |

---

## Flutter Implementation Equivalents

- **Color Tokens:** Defined in `AppColors` (`lib/utils/colors.dart`) using `Color(0xFF...)`.
- **Typography:** Defined in `AppTypography` (`lib/utils/typography.dart`) using `TextStyle(fontFamily: 'SVN-Gilroy', ...)`.
- **Cards & Surfaces:** Constructed with `Container`, `DecorationBox`, or `Card` with `BorderRadius.circular()`.
- **Shadows:** Constructed using `BoxShadow(color: ..., blurRadius: ..., offset: ...)`.
- **Glass Effect:** Constructed using `BackdropFilter` with `ImageFilter.blur(sigmaX: 20, sigmaY: 20)`.

---

## Design Checklist

- [x] All colours map to the defined `AppColors` tokens.
- [x] SVN‑Gilroy is the primary font; registered in `pubspec.yaml`.
- [x] Corner radii follow the rounded scale (30pt, 20pt, 14pt, 12pt, 9999px).
- [x] Shadows are soft and consistent across cards and buttons.
- [x] Translucent glass blur is used for bottom navigation overlays.
- [x] The Camera tab has pure black background and Locket-inspired minimal controls.
- [x] The shutter button uses `Primary` `#FF6B6B` fill with 12px blur glow.
- [x] The thumbnail displays the latest memory image.
