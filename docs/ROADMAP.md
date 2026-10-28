# Flightcraft implementation roadmap

This repo is an incremental implementation of the supplied Flightcraft v1.0 specification.

## M1 — Foundation (current prototype, partial)
- [x] Godot project and Android export workflow
- [x] Seeded procedural terrain prototype
- [x] First-person walking, running and jumping controller
- [x] Basic day/night light movement, sky and water plane
- [x] Experimental flight toggle and low-poly plane silhouette
- [ ] True voxel chunks (16×16×128), greedy meshing and threaded generation
- [ ] Robust mobile joystick and dedicated control layout

## M2 — Visual world
- [x] Starter sky / water shaders
- [ ] Waterfalls, better reflections, biome transitions and quality presets

## M3 — Water
- [ ] Surface swimming, dive controls, underwater fog and particles

## M4 — Plane
- [ ] Independent parked plane entity, enter/exit, arcade aerodynamics, landing on terrain/water, plane audio

## M5 — Atmosphere
- [ ] Rain, thunderstorms, snow, valley fog, ambient audio and music crossfade

## M6 — Life
- [ ] Fish schools, birds, deer/fox/rabbit wandering and biome-based spawning

## M7 — Release polish
- [ ] World save slots, deterministic seed browser, settings, FPS limiter and graphics presets
- [ ] Device profiling, memory/chunk pooling, crash testing and Android release signing

Features not implemented are listed explicitly rather than being represented as finished.
