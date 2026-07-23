### 📋 Prompt for Antigravity: Phase 3 – Social & Discovery (Mini Social Ecosystem)

**Goal:** Transform Sprinkle from a solo journal into a **social discovery app** by adding streaks (gamification), a live activity badge, a swipeable feed of friends' spots, and a heatmap ring around the camera icon—making the app feel alive and community‑driven.

**Constraints (Strict):**

- **DO NOT** break the existing camera capture, save, or memory list flows.
- **DO NOT** modify `CameraViewModel`, `DatabaseService`, or `VisitRecord` schema unless explicitly instructed.
- **DO** use **mock data** for friends and nearby spots (we'll replace with real API later).
- **DO** keep all new state in dedicated Riverpod providers.

---

### 📦 Step 1: Add Required Dependencies

**File:** `pubspec.yaml`

```yaml
dependencies:
  # ... existing ...
  shared_preferences: ^2.5.2 # For streak persistence
  card_swiper: ^3.0.1 # For Tinder‑style swipe cards
```

Run `flutter pub get`.

---

### 🔥 Part A: Streak Counter (Gamification)

**Goal:** Show a "🔥 X‑day streak" badge in the top‑right corner (next to settings) to encourage daily use.

**Files to Create/Modify:**

1. **Create:** `lib/services/streak_service.dart` – Manages streak logic using `SharedPreferences`.

2. **Create:** `lib/viewmodels/streak_viewmodel.dart` – Riverpod provider for streak state.

3. **Modify:** `lib/views/camera_view.dart` – Display the streak badge in `_TopBar`.

---

**File:** `lib/services/streak_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _lastActiveKey = 'last_active_date';
  static const String _streakKey = 'streak_count';

  /// Get the current streak count
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Update streak based on today's activity
  static Future<int> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = _dateToString(today);

    final lastActiveString = prefs.getString(_lastActiveKey);
    final currentStreak = prefs.getInt(_streakKey) ?? 0;

    // If already active today, return current streak
    if (lastActiveString == todayString) {
      return currentStreak;
    }

    // If last active was yesterday, increment streak
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayString = _dateToString(yesterday);

    int newStreak;
    if (lastActiveString == yesterdayString) {
      newStreak = currentStreak + 1;
    } else {
      // Gap detected → reset streak
      newStreak = 1;
    }

    await prefs.setString(_lastActiveKey, todayString);
    await prefs.setInt(_streakKey, newStreak);
    return newStreak;
  }

  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
```

---

**File:** `lib/viewmodels/streak_viewmodel.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/streak_service.dart';

final streakProvider = FutureProvider<int>((ref) async {
  return await StreakService.getStreak();
});

final updateStreakProvider = FutureProvider<int>((ref) async {
  return await StreakService.updateStreak();
});
```

---

**File:** `lib/views/camera_view.dart` (modify `_TopBar`)

**Action:** Add a streak badge to the right of the settings gear.

```dart
// Inside _TopBar, after the settings gear, add:
Consumer(
  builder: (context, ref, child) {
    final streakAsync = ref.watch(streakProvider);
    return streakAsync.when(
      data: (streak) {
        if (streak == 0) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: AppTypography.badgeNumber.copyWith(color: Colors.white),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  },
),
```

**Note:** Call `ref.read(updateStreakProvider.notifier).state` when the app launches or when a memory is saved. (Add this in `main.dart` or inside the save success block.)

---

### 🟢 Part B: Live Activity Badge (Replace "1x")

**Goal:** Replace the removed "1x" badge with a dynamic "👀 X spots today" badge that feels social and alive.

**File:** `lib/widgets/square_preview.dart`

**Action:** Add a new `Positioned` badge in the top‑right corner (where the "1x" used to be) that shows the number of spots saved today.

**New Provider (create in `lib/viewmodels/stats_viewmodel.dart`):**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

final todaySpotsProvider = FutureProvider<int>((ref) async {
  final visits = await DatabaseService.instance.getAllVisits();
  final today = DateTime.now();
  return visits.where((v) =>
    v.timestamp.year == today.year &&
    v.timestamp.month == today.month &&
    v.timestamp.day == today.day
  ).length;
});
```

**Modify `square_preview.dart`:**

```dart
// Inside the Stack, add this Positioned after the Flash Toggle:
Positioned(
  top: 12,
  right: 12,
  child: Consumer(
    builder: (context, ref, child) {
      final spotsAsync = ref.watch(todaySpotsProvider);
      return spotsAsync.when(
        data: (count) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👀', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$count spots today',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      );
    },
  ),
),
```

---

### 🃏 Part C: Swipe to Explore (Tinder‑Style Cards)

**Goal:** Add a new **"Explore"** view accessible by swiping up from the bottom (or via a new "Discover" button). It shows a stack of places recommended by "friends" (mock data) that users can swipe right to save to a wishlist or left to skip.

**New Files:**

1. `lib/models/spot.dart` – Simple model for a recommended spot.
2. `lib/viewmodels/explore_viewmodel.dart` – Provides mock spots and handles swipe actions.
3. `lib/views/explore_view.dart` – The Tinder‑style card stack.

---

**File:** `lib/models/spot.dart`

```dart
class Spot {
  final String id;
  final String name;
  final String? imageUrl; // Placeholder, we'll use generated colors or random images
  final double rating;
  final String friendName;
  final String friendAvatar; // Emoji or initial

  Spot({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.rating,
    required this.friendName,
    required this.friendAvatar,
  });
}
```

---

**File:** `lib/viewmodels/explore_viewmodel.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spot.dart';

final exploreSpotsProvider = StateNotifierProvider<ExploreViewModel, List<Spot>>((ref) {
  return ExploreViewModel();
});

class ExploreViewModel extends StateNotifier<List<Spot>> {
  ExploreViewModel() : super(_generateMockSpots());

  static List<Spot> _generateMockSpots() {
    return [
      Spot(
        id: '1',
        name: 'The Coffee Collective',
        rating: 4.8,
        friendName: 'Alex',
        friendAvatar: '🧑‍🎤',
      ),
      Spot(
        id: '2',
        name: 'Hanoi Social Club',
        rating: 4.6,
        friendName: 'Taylor',
        friendAvatar: '🧑‍💻',
      ),
      Spot(
        id: '3',
        name: 'Craft Beer Pub',
        rating: 4.3,
        friendName: 'Jordan',
        friendAvatar: '🧑‍🍳',
      ),
      Spot(
        id: '4',
        name: 'Hidden Speakeasy',
        rating: 4.9,
        friendName: 'Sam',
        friendAvatar: '🧑‍🎓',
      ),
      Spot(
        id: '5',
        name: 'Sunset Rooftop',
        rating: 4.7,
        friendName: 'Morgan',
        friendAvatar: '🧑‍✈️',
      ),
    ];
  }

  void swipeRight(String id) {
    // For now, just log – later we can save to a wishlist
    print('💚 Saved to wishlist: $id');
    _removeSpot(id);
  }

  void swipeLeft(String id) {
    print('💔 Skipped: $id');
    _removeSpot(id);
  }

  void _removeSpot(String id) {
    state = state.where((spot) => spot.id != id).toList();
  }

  // Reset when user reopens explore
  void reset() {
    state = _generateMockSpots();
  }
}
```

---

**File:** `lib/views/explore_view.dart`

**Goal:** A draggable card stack using `card_swiper`. Use the `Swiper` widget with `SwiperLayout.TINDER`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../viewmodels/explore_viewmodel.dart';

class ExploreView extends ConsumerWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots = ref.watch(exploreSpotsProvider);
    final viewModel = ref.read(exploreSpotsProvider.notifier);

    if (spots.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text(
                'All caught up!',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new spots from friends.',
                style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Back to Camera'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '👥 DISCOVER',
          style: AppTypography.sectionTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: viewModel.reset,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Swiper(
          itemCount: spots.length,
          layout: SwiperLayout.TINDER,
          itemWidth: MediaQuery.of(context).size.width - 40,
          itemHeight: MediaQuery.of(context).size.height * 0.65,
          onSwipe: (index, direction) {
            final spot = spots[index];
            if (direction == SwiperDirection.right) {
              viewModel.swipeRight(spot.id);
            } else if (direction == SwiperDirection.left) {
              viewModel.swipeLeft(spot.id);
            }
          },
          itemBuilder: (context, index) {
            final spot = spots[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    Colors.purple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Card Content (Placeholder image + info)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spot.name,
                                style: AppTypography.headlineLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '⭐ ${spot.rating.toStringAsFixed(1)}',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '👤 ${spot.friendName}',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  '${spot.friendAvatar} visited',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Swipe Hint Overlay (optional)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swipe_rounded, color: Colors.white70, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Swipe',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

**Modify `lib/views/camera_view.dart`:** Add a gesture to open `ExploreView` on swipe‑up (or a button).

```dart
// Inside _CameraViewState, add:
void _openExplore() {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const ExploreView()),
  );
}

// In the body, wrap the Stack with a GestureDetector for swipe-up:
GestureDetector(
  onVerticalDragEnd: (details) {
    if (details.velocity.pixelsPerSecond.dy < -500) {
      _openExplore();
    }
  },
  child: Stack(
    // ... existing content ...
  ),
)
```

---

### 🟣 Part D: Heatmap Nav Ring (Progress Around Camera Icon)

**Goal:** Wrap the center camera icon in the floating nav bar with a circular progress ring that shows "percentage of today's spots discovered" or "friends active."

**File:** `lib/views/camera_view.dart` (modify `_FloatingNavBar`)

```dart
// Inside _FloatingNavBar, replace the current Camera icon Container with:

Stack(
  alignment: Alignment.center,
  children: [
    // Progress Ring (CustomPaint)
    SizedBox(
      width: 52,
      height: 52,
      child: Consumer(
        builder: (context, ref, child) {
          final spotsAsync = ref.watch(todaySpotsProvider);
          return spotsAsync.when(
            data: (count) {
              final progress = (count % 10) / 10.0; // Max out at 10 spots
              return CustomPaint(
                painter: _ProgressRingPainter(
                  progress: progress,
                  color: AppColors.primary,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    ),
    // Camera Icon (same as before)
    Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.camera_alt_rounded,
        color: Colors.white,
        size: 24,
      ),
    ),
  ],
),
```

---

**Add the Custom Painter:**

```dart
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start at top
      2 * pi * progress,
      false,
      paint,
    );

    // Background ring (subtle)
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
```

---

### ✅ Verification Checklist (Run after implementation)

1. Launch the app → the streak badge appears in the top‑right (initially 0 or 1).
2. Save a memory → the streak updates to 🔥 1 (check tomorrow for increment).
3. The "👀 X spots today" badge appears on the preview (top‑right).
4. Swipe up on the camera screen → `ExploreView` opens with Tinder cards.
5. Swipe cards left/right → they disappear and log the action.
6. When all cards are swiped, a "All caught up!" screen appears.
7. The floating nav bar camera icon has a **progress ring** around it (updates with today's spots).
8. **Existing capture, gallery picker, add/edit, and memory list still work perfectly.**

---

### 📌 Future Enhancement (API Integration)

When you're ready to connect real friends and places:

1. Replace the mock `spots` with a real API call (e.g., Firebase or your own backend).
2. Fetch real user data for the streak leaderboard.
3. Add push notifications for "new spots nearby."

---

**End of Prompt.**
