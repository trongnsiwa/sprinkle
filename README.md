# Sprinkle – Camera-First Memory Journal

**Sprinkle** is a minimal, premium Flutter camera‑first memory journal inspired by the Locket app layout. Capture memories of cafes, restaurants, or places instantly, rate them, tag them, and keep a beautifully organized local journal.

---

## ✨ Features

- 📸 **Locket-Inspired Camera View:** Pure black preview screen, top-left avatar, top-right flash toggle, and custom 80pt glowing shutter button.
- ⚡ **Instant Local Persistence:** Fast, offline-first data storage powered by **Isar NoSQL Database**.
- 🎨 **Minimalist Premium Design System:** Curated color tokens (Primary `#FF6B6B`, Secondary `#4ECDC4`), soft shadows, glassmorphism overlays, and SVN-Gilroy typography.
- 🏷️ **Memories Timeline & Detail View:** Memory list cards with star ratings, timestamp formatters, capsule tag filters, interactive modal sheet, and detailed view with full-size photos.
- 🔒 **Privacy First:** All photos and data are compressed and stored locally on device.

---

## 🛠️ Tech Stack & Architecture

| Layer | Technology | Usage |
| --- | --- | --- |
| **Framework** | Flutter (Dart SDK ^3.12) | Cross-platform UI (iOS & Android) |
| **State Management** | Riverpod (`flutter_riverpod`) | Reactive UI state, providers, state notifiers |
| **Local Database** | Isar (`isar`, `isar_flutter_libs`) | Fast local NoSQL database & live streams |
| **Camera** | `camera` | Full-screen preview, flash mode, photo capture |
| **Permissions** | `permission_handler` | Camera and photo gallery access checks |
| **Image Pipeline** | `image` + `path_provider` | Resize, JPEG compression, and file management |
| **Fonts** | SVN-Gilroy | Custom typography registered in `pubspec.yaml` |

---

## 📁 Directory Structure

```
lib/
├── main.dart                      # App entry point, Isar initialization, ProviderScope
├── models/
│   ├── visit_record.dart          # Isar @collection schema
│   └── visit_record.g.dart        # Generated Isar model code
├── services/
│   ├── database_service.dart      # Isar wrapper & CRUD streams
│   ├── permission_service.dart    # Camera & gallery permission requests
│   └── image_service.dart         # Compression, file saving, & deletion
├── viewmodels/
│   ├── camera_viewmodel.dart      # Camera controller, capture, & thumbnail state
│   ├── visit_list_viewmodel.dart  # Memory list fetching & deletion
│   └── add_edit_viewmodel.dart    # Memory form state & validation
├── views/
│   ├── main_tab_view.dart         # 3-tab layout & glass bottom navigation
│   ├── camera_view.dart           # Locket-style camera preview screen
│   ├── visit_list_view.dart       # Memories timeline view
│   ├── add_edit_view.dart        # Modal form sheet for adding/editing
│   └── visit_detail_view.dart     # Detailed memory view
├── widgets/
│   ├── custom_shutter.dart        # 80pt Locket-style shutter button
│   ├── custom_thumbnail.dart      # Circular & rounded async image thumbnail
│   └── star_rating.dart           # Star rating selector & display bar
├── utils/
│   ├── colors.dart                # Design system color tokens
│   ├── typography.dart            # SVN-Gilroy text styles
│   └── date_formatter.dart        # Friendly DateTime extensions
└── extensions/
    └── context_extensions.dart    # BuildContext helper utilities
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.12.0 or higher)
- CocoaPods (for iOS build)
- Xcode (for iOS device / simulator) or Android Studio (for Android emulator)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/sprinkle.git
   cd sprinkle
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Isar database schemas:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📖 Design System Documentation

Detailed design guidelines and architecture context can be found in the `docs/` folder:
- 🎨 [docs/design.md](docs/design.md): Color tokens, typography hierarchy, component shapes, spacing scale, elevation shadows, and glassmorphism rules.
- 📋 [docs/project-context.md](docs/project-context.md): Comprehensive project architecture context and coding standards.
