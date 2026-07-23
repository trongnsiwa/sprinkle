# Camera UI Redesign – Locket‑inspired Circular Preview

**Date:** 2026-07-22  
**Status:** Implemented (UI layout only)  
**Next steps:** Define additional features (place search, ratings, social feed)

---

## Overview

The home camera screen has been redesigned to match the **Locket** app’s minimalist, circular‑preview layout.  
This change shifts the focus to the subject (e.g., a café, restaurant, or store) by framing it inside a clean circle, removing visual clutter from the surroundings.

---

## Layout Details

| Element             | Specification                                                                                                                                                                                                      |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Background**      | Pure black (`#000000`)                                                                                                                                                                                             |
| **Camera Preview**  | 300pt diameter circle with a 4pt white border and a soft primary‑coloured glow (blur 20pt, opacity 30%)                                                                                                            |
| **Preview Mask**    | `ClipOval` + `FittedBox` with `BoxFit.cover` to fill the circle while preserving aspect ratio                                                                                                                      |
| **Top‑Left**        | 40pt circular avatar (primary at 20% opacity) + "Friends" label (caption, white 70%) – tap navigates to Friends tab                                                                                                |
| **Top‑Right**       | Flash toggle icon (20pt) – white (off) / yellow (on)                                                                                                                                                               |
| **Bottom Controls** | Left: 50pt circular thumbnail (last captured image with white border) – tap opens Memories tab <br> Center: 80pt outer ring + 68pt primary shutter (existing `CustomShutter`) <br> Right: 50pt spacer for symmetry |
| **Spacing**         | 40pt between thumbnail and shutter; 40pt from bottom safe area                                                                                                                                                     |

---

## Rationale

- **Circular preview** creates a “cute” framing that isolates the subject, aligning with the user’s desire to capture storefronts without extra sky or unrelated surroundings.
- The **glow** around the preview subtly draws attention to the capture area.
- The **thumbnail** provides quick access to the last memory, preserving the original Locket behaviour.
- The layout remains **functional** – permissions, flash, shutter, and add‑edit flow work exactly as before.

---

## Future Directions (Ideas)

- **Shape detection / automatic cropping:** Explore using ML or image analysis to detect building outlines and crop the image to the storefront automatically.
- **Place search:** Allow users to search for a place (e.g., via Google Places API) and pre‑fill the name/address when saving.
- **Social feed:** Expand the “Friends” tab to show shared memories from connected users.
- **Rating & review aggregation:** Show average ratings and reviews from other users for a place.
- **Interactive map integration:** Pin memories on a map for a visual timeline.

---

## Next Steps

1. Gather user feedback on the new camera UI.
2. Decide which of the future features to implement first (likely place search + ratings).
3. Design and build the corresponding UI/state layers.

---

## References

- Design system: `docs/design.md`
- Project context: `docs/project-context.md`
- Original Locket app (inspiration)
