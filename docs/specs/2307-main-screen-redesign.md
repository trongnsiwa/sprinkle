### 📋 Prompt for Antigravity: Main Screen Redesign – "Cream & Candy" (Warm, Playful, Aesthetic)

**Goal:** Redesign the main `CameraView` layout, colors, shapes, and decorative elements to feel **warm, soft, playful, and aesthetically pleasing**—like a cute travel journal, not a futuristic gadget.

**Core Visual Principles:**

1. **Warm Pastel Palette** – Replace all dark/neon colors with cream, peach, coral, and mint.
2. **Squishy Shapes** – Use squircle capsules, dashed borders, and soft multi‑colored shadows.
3. **Playful Details** – Add a wavy underline, a bouncing emoji, and a dotted arrow to guide the user.
4. **Frosted White Glass** – Not dark grey. Light, airy, and translucent.

**Constraints:**

- **DO NOT** change `CameraViewModel`, `DatabaseService`, or capture/save logic.
- **DO NOT** break haptics, confetti, or existing navigation.
- **DO** keep all `Key`s and widget identities stable.
- **DO** use `Icons.rounded` for all icons.

---

### 🎨 Step 1: New Color Palette (Warm & Simple)

**File:** `lib/utils/colors.dart`

**Action:** Add these new warm, soft color tokens. **Do not delete** the existing ones (to avoid breaking other views), but update `CameraView` to use these.

```dart
// Add these to AppColors:
static const Color warmBackground = Color(0xFFFFF8F0);   // Soft cream
static const Color warmPeach = Color(0xFFFFE5D9);        // Light peach
static const Color warmCoral = Color(0xFFFF6B6B);        // Keep primary coral
static const Color warmMint = Color(0xFF9AD0C2);         // Soft mint accent
static const Color warmYellow = Color(0xFFFED766);       // Playful yellow
static const Color warmShadow = Color(0x33FF6B6B);       // Coral at 20% for shadows
```

---

### 🌸 Step 2: Decorative Background (Cream → Peach Gradient + Dotted Grid)

**File:** `lib/views/camera_view.dart`

**Action:** Replace the `Positioned.fill` background with a **warm gradient** and overlay a **subtle dotted pattern** (to give it a "map/aesthetic" feel).

**Exact Code Snippet:**

```dart
// 1. Background Gradient (warm and soft)
Positioned.fill(
  child: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF8F0), // Cream top
          Color(0xFFFFE5D9), // Peach middle
          Color(0xFFFFF0ED), // Soft blush bottom
        ],
      ),
    ),
  ),
),

// 2. Decorative Dotted Grid (aesthetic map feel)
Positioned.fill(
  child: CustomPaint(
    painter: _DottedGridPainter(),
  ),
),
```

**Add the Custom Painter at the bottom of the file:**

```dart
class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

### 🟣 Step 3: Redesign the Camera Preview (Squircle + Dashed Border + Soft Shadow)

**File:** `lib/widgets/square_preview.dart`

**Action:** Replace the glowing neon border with a **dashed coral border** and a **soft multi‑colored shadow**.

**Exact Code Snippet (update the `Container` decoration):**

```dart
// Inside the build method, update the Container decoration:
Container(
  width: targetWidth,
  height: targetHeight,
  decoration: BoxDecoration(
    color: const Color(0xFFFDF6F0), // Soft cream base
    borderRadius: BorderRadius.circular(32.0),
    border: Border.all(
      color: AppColors.warmCoral.withOpacity(0.4),
      width: 2.5,
      // Flutter doesn't support dashed border directly on BoxDecoration.
      // Use a CustomPaint or a simple solid border + a dashed overlay.
      // For simplicity, keep solid but add a soft colored shadow:
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.warmCoral.withOpacity(0.2),
        blurRadius: 30,
        spreadRadius: -5,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.warmMint.withOpacity(0.15),
        blurRadius: 25,
        spreadRadius: -8,
        offset: const Offset(-4, 4),
      ),
    ],
  ),
  // ... rest of the widget
)
```

_Note: For a true dashed border, wrap the Container with a `CustomPaint` overlay, but a solid soft border with multi‑colored shadows is a simpler, highly aesthetic alternative that feels "designer"._

---

### 📍 Step 4: Redesign the Empty State (Wobbly Pin + Wavy Text + Dotted Arrow)

**File:** `lib/widgets/square_preview.dart` (inside the `Stack`)

**Action:** Replace the current "Your city is waiting!" text with a **playful, animated empty state** featuring a wobbling pin, wavy‑underlined headline, and a dotted path.

**Exact Code Snippet:**

```dart
// Inside the Stack, when isMockMode is true:
if (widget.isMockMode)
  Positioned.fill(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Wobbling Map Pin (AnimatedScale)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: const Text('📍', style: TextStyle(fontSize: 56)),
              );
            },
          ),
          const SizedBox(height: 12),
          // 2. Wavy Underlined Text
          _WavyUnderlineText(
            text: 'Your city is waiting!',
            style: AppTypography.headlineMedium.copyWith(
              color: const Color(0xFF3D2C1E), // Warm dark brown
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the shutter to drop your first pin ✨',
            style: AppTypography.bodyLarge.copyWith(
              color: const Color(0xFF8B7355).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          // 3. Dotted Arrow pointing down (aesthetic guide)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(8, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.warmCoral.withOpacity(0.5 - (index * 0.05)),
                    shape: BoxShape.circle,
                  ),
                );
              }),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_downward_rounded,
                color: AppColors.warmCoral.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    ),
  ),
```

**Add the `_WavyUnderlineText` helper widget** at the bottom of the file (or inside the same file):

```dart
class _WavyUnderlineText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _WavyUnderlineText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavyUnderlinePainter(),
      child: Text(text, style: style),
    );
  }
}

class _WavyUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.warmCoral.withOpacity(0.4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.25, size.height + 6, size.width * 0.5, size.height)
      ..quadraticBezierTo(size.width * 0.75, size.height - 6, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

### 🪟 Step 5: Redesign the Floating Nav Bar (Soft White Capsule + Raised Camera)

**File:** `lib/views/camera_view.dart` (inside `_FloatingNavBar`)

**Action:** Make the bar **light and airy** (frosted white), with **individual squircle buttons** and a **raised camera icon** that bounces.

**Exact Code Snippet:**

```dart
// Replace the current _FloatingNavBar with this:
@override
Widget build(BuildContext context) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmCoral.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Feed Button (Squircle)
              _NavButton(
                icon: Icons.people_alt_rounded,
                label: 'Feed',
                onTap: onFeedTap,
                badge: '3',
              ),
              const SizedBox(width: 8),
              // Camera Button (Raised + Bouncy)
              _NavCameraButton(onTap: () {}), // No-op, just visual
              const SizedBox(width: 8),
              // Memories Button (Squircle)
              _NavButton(
                icon: Icons.grid_view_rounded,
                label: 'Memories',
                onTap: onMemoriesTap,
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

**Add these helper widgets inside the same file:**

```dart
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final bool isActive;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.warmCoral.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 24, color: const Color(0xFF3D2C1E).withOpacity(0.7)),
            if (badge != null)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavCameraButton extends StatefulWidget {
  final VoidCallback onTap;
  const _NavCameraButton({required this.onTap});

  @override
  State<_NavCameraButton> createState() => _NavCameraButtonState();
}

class _NavCameraButtonState extends State<_NavCameraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounce.value,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warmCoral.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}
```

---

### ✅ Verification Checklist

1. Run the app → background is **warm cream/peach** (not dark).
2. Preview has a **soft coral/mint shadow** and a **dashed‑style border**.
3. Empty state shows a **wobbling 📍 pin**, **wavy‑underlined text**, and a **dotted arrow** pointing down.
4. Floating nav bar is **frosted white**, not dark grey.
5. Camera button **bounces slightly** (raised above the bar).
6. Feed and Memories buttons have **soft squircle shapes** with tiny badges.
7. **Capture, gallery picker, and add‑edit sheet still work perfectly.**

---

**End of Prompt.**
