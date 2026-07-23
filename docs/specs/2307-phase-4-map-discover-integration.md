### 📋 Prompt for Antigravity: Phase 4 – Map & Discovery Integration

**Goal:** Replace the placeholder "Feed" tab with an interactive map that pins every saved memory. Users can see all their visited places on a map, turning the app into a visual travel journal.

---

### Instructions

1. **Add Dependencies**
   - Add `google_maps_flutter: ^2.11.0` to `pubspec.yaml`.
   - Run `flutter pub get`.
   - **Note:** A Google Maps API key is required. Add it to `AndroidManifest.xml` and `Info.plist` (refer to the plugin documentation).

2. **Extend `VisitRecord` Model**
   - Open `lib/models/visit_record.dart`.
   - Add two new nullable fields: `double? latitude` and `double? longitude`.
   - Run `flutter pub run build_runner build` to regenerate the Isar schema.

3. **Auto‑Capture Location on Save**
   - In `lib/viewmodels/add_edit_viewmodel.dart`, inside the `save()` method:
     - Use the `geocoding` package (already added in Phase 2).
     - If the record has an `address` or `name`, use `placemarkFromAddress()` to get coordinates.
     - Assign the results to `record.latitude` and `record.longitude`.
     - If coordinates cannot be fetched, proceed with saving anyway (just skip the pin).

4. **Create the Map View**
   - Create `lib/views/explore_map_view.dart`.
   - Build a `ConsumerWidget` that:
     - Watches `visitStreamProvider` to get all records.
     - Displays a `GoogleMap` with:
       - `initialCameraPosition` centered on the user's last captured place (or a default city center).
       - `markers`: a list of `Marker` widgets for each record with valid `latitude`/`longitude`.
         - Pin title = `record.name`, snippet = `record.address` or `"${record.rating}⭐"`.
     - Use a dark or custom map style for a cohesive look.
     - Add a floating action button (or app bar button) to **"Center on my location"** using the `geolocator` plugin.

5. **Update Navigation (`MainTabView`)**
   - Replace the `FriendsPlaceholderView` with the new `ExploreMapView` for the Feed tab (index 0).

---

### Keep Unchanged

- `CameraView`, `VisitListView`, capture logic, haptics, and confetti.

---

### Verification Checklist

- [ ] Saving a memory now stores `latitude` and `longitude`.
- [ ] The Feed tab shows a map with pins for all saved memories.
- [ ] Tapping a pin displays the place name and rating.
- [ ] Camera and Memories tabs continue to work normally.

---

**End of Prompt.**
