# Beyond Widgets Demo

A Flutter demo app showcasing techniques for building camera-driven,
AR-like UI experiences.

## Demos

| # | Demo | Description |
|---|------|-------------|
| 01 | Naive Overlay | `CameraPreview` + `Stack` with plain `scaleX`/`scaleY` scaling — breaks under rotation and `BoxFit.contain` |
| 02 | Coordinate Transform | Same UI, corrected via a Detect → Normalize → Rotate → Scale → Offset pipeline |
| 03 | Camera Pipeline & Sync | Per-frame processing (unbounded queue/latency growth) vs. Latest Frame + Back Pressure |
| 04 | Rendering Performance | `setState()` on every frame vs. `Listenable` + `CustomPainter`, with measured frame build times |
| 05 | Interactive Overlay | Bidirectional coordinate transform: tap → inverse-transformed into image space for hit testing |

Demos 01, 02, and 05 include a "Real ML Kit OCR" toggle to switch between
deterministic mock detection and on-device OCR
(`google_mlkit_text_recognition`), so they can be verified even without a
camera. Demos 03 and 04 are timer-driven simulations with no camera
dependency and run fully on an emulator.

## Setup

```bash
flutter pub get
flutter run
```
