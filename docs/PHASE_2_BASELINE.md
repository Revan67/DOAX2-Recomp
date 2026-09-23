# Phase 2 Emulator Baseline

## Oracle

- Xenia Canary binary release: `02d2cb5`
- Reported build: `canary_experimental@02d2cb5cc`, March 24, 2026
- Windows archive SHA-256:
  `1adbb2c1c69cbd5fabadb43d03b4c407db3b245de922e11aba699867c68d0796`
- Game manifest: `doax2-disc-base-5a642963`
- Backend reported by the window: Direct3D 12 RTV/DSV and XAudio2
- Title update: none
- Runtime state: isolated portable directory under ignored local evidence

The official Canary source repository had newer source-only releases when this
baseline was captured, but its separately maintained binary-release repository
provided `02d2cb5` as the latest downloadable Windows artifact. The distinction
is recorded to keep the result reproducible.

## Probe 1 — bounded unattended boot

The extracted base `default.xex` remained alive and responsive after 20 seconds.
Observed process working set was 688,398,336 bytes and accumulated CPU time was
12.39 seconds. The process was stopped at the test boundary.

## Probe 2 — visual boot sequence

The same executable was launched from a clean portable directory and inspected
without retaining or publishing screenshots.

Observed checkpoints:

1. Xenia recognized Title ID `544307D2` and version `0.0.0.3`.
2. The game reached and animated its copyright/legal warning sequence.
3. The opening movie began and continued rendering for several minutes.
4. The emulator window remained responsive throughout the observation.
5. A single default keyboard Return input did not skip the warning or movie.

Not yet verified:

- Audio correctness; XAudio2 initialized, but audio was not evaluated.
- Title screen or profile prompt.
- Save creation.
- Menu rendering or navigation.
- In-engine 3D rendering or gameplay.
- Controller input.

## Deterministic smoke-test route

Until controller input is established, the repeatable route is:

1. Start with a fresh portable Xenia directory.
2. Launch the verified base `default.xex` directly.
3. Confirm the window identifies Title ID `544307D2`, version `0.0.0.3`, D3D12,
   and XAudio2.
4. Confirm the legal warning renders and advances.
5. Confirm the opening movie begins and continues without a fatal error.
6. Stop the process at the defined observation deadline.

The next extension is to use an XInput controller, reach the title/profile gate,
and determine whether a local profile and save can be created.

Raw configurations, caches, logs, screenshots, and portable content remain in
ignored `evidence/local/` and must not be committed or attached publicly.

