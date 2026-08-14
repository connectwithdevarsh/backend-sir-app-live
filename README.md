# AIPE LAB

**Artificial Intelligence with Prompt Engineering**  
**Subject Code**: DI05016011  
**Program**: Diploma Engineering  
**Branch**: Department of Information Technology  
**Semester**: 5th Semester  

---

## 🌟 Application Overview

**AIPE LAB** is a premium educational mobile application engineered in Flutter for Diploma Information Technology students. It provides a complete digital laboratory dashboard, syllabus material explorer, and academic mentor profile.

### ✨ Key Features

1. **Phase 1 — Premium Splash Screen**:
   - Animated vector logo with prompt cursor (`>_`) and gold sparkles.
   - Staggered entrance animation sequence (3.6s) with ambient neural background painter.

2. **Phase 2 — Home & 12 GTU Practical Experiments**:
   - Complete 100% coverage of official GTU practical outcomes.
   - Live category filter chips (`AI Tools`, `NLP`, `LLM`, `Prompt Engineering`, `AI Applications`).
   - Instant search bar filtering practical titles and objectives.
   - Expandable cards displaying aims, demo prompts, monospace code editor, local execution runner (`▶ RUN`), terminal output console, copy button with SnackBar, reset button, and completion progress tracker.

3. **Phase 3 — GTU 5-Unit Material & Resources**:
   - Full coverage of 5 syllabus units (45 Hours).
   - Topic and subtopic breakdown with learning notes.
   - Reference textbook cards and online resource links.

4. **Phase 4 — Faculty Profile**:
   - Professional instructor portfolio header with vector avatar and glowing halo.
   - Academic status badge (`FACULTY • INFORMATION TECHNOLOGY`).
   - Qualifications, teaching experience, subject highlights, and contact information.

5. **Phase 5 — Floating Premium Bottom Navigation**:
   - Glassmorphic pill container (`PremiumBottomNav`) with cyan glow borders.
   - Micro-animations for icon scaling, label fading, and selection pill container.
   - State preservation via `IndexedStack`.
   - Android back button interception using `PopScope`.

6. **Phase 6 — Centralized Design System**:
   - Reusable theme tokens (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppTheme`).
   - Material 3 `darkTheme` and `lightTheme` support.

---

## 🛠️ Technical Stack & Dependencies

- **Framework**: Flutter 3.x / Dart 3.x
- **Typography**: `google_fonts: ^6.1.0` (`Space Grotesk`, `Inter`, `Fira Code`)
- **Link Handling**: `url_launcher: ^6.3.2`
- **Iconography**: `cupertino_icons: ^1.0.8`

---

## 🚀 How to Run Locally

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Static Analysis**:
   ```bash
   flutter analyze
   ```

3. **Run Debug Application**:
   ```bash
   flutter run -d chrome
   ```
   or for Android desktop:
   ```bash
   flutter run -d windows
   ```

4. **Build Production Release APK**:
   ```bash
   flutter build apk --release
   ```
   Generated APK location:
   `build/app/outputs/flutter-apk/app-release.apk`
