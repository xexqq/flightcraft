# Flightcraft — Android prototype

Relaxed first-person exploration in a procedurally generated low-poly world. Godot 4.x / GDScript.

## Current prototype features

- Seeded procedural terrain with multi-octave Simplex noise and terrain color bands.
- Basic walk/run/jump controller, first-person mouse/touch camera look.
- Experimental arcade flight mode and a simple low-poly plane silhouette (`F` / on-screen button).
- Water plane, procedural sky, directional sun cycle, bloom, lightweight tree silhouettes.
- Pause overlay and regenerate-world button.
- GitHub Actions workflow that exports a debug Android APK and stores it as a downloadable artifact.

## Important scope note

This is the **first playable foundation**, not the complete v1.0 described in `docs/ROADMAP.md`. The current terrain is a continuous heightfield prototype rather than true 16×16×128 voxel chunks. Swimming, proper plane enter/exit and landing, chunk streaming/greedy meshing, full biomes, animal AI, weather/audio, save slots and production-grade graphics presets remain follow-up work. Do not treat the target FPS figures as verified until profiled on-device.

## Open and run

1. Install Godot 4.4.x (Compatibility renderer).
2. Import this folder via `project.godot`.
3. Press F6/F5 to run. Desktop: WASD, mouse look, Space jump, Shift run, F flight, Esc pause. On Android, swipe the right side to look and use the on-screen flight/jump buttons; desktop keyboard movement is currently the primary movement input.

## Build APK on GitHub

1. Create a new empty repository on GitHub named `Flightcraft` (do not add a README/license there).
2. Upload the contents of this ZIP to the repository root, preserving `.github/workflows/build-android.yml`.
3. Open **Actions → Build Android APK → Run workflow** (or push a change to `main`).
4. Open the completed run and download artifact **Flightcraft-Android-debug**. Extract it to get `Flightcraft.apk`.

The workflow uses the Godot CI container and exports a debug APK. First build may fail if the selected container image does not contain a compatible Android export template/SDK; if so, inspect the log and update the workflow/container or configure Android export dependencies. The APK is unsigned for store distribution (debug signing only).

## Seed and performance

A seed is currently stored in the generated world node and can be regenerated from the pause panel. World generation is intentionally simple for the first prototype and is not yet streamed in worker threads. Performance depends on device/Godot version and has not been benchmarked.
