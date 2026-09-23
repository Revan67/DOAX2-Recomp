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
   The Team Ninja startup logo did not respond to controller skip input and is
   treated as unskippable original behavior in the oracle baseline.
4. The title screen rendered and accepted input from an attached Xbox Series
   controller through Xenia's `any` input backend.
5. The game required a local Xenia profile before campaign progression.
6. After profile creation, the main menu and campaign cinematic rendered.
7. Campaign progression reached the fully drawn character-select screen.
8. Selecting Helena reached her opening beach dialogue and the Day 1 Morning
   island/activity interface.
9. Xenia created title-specific `rds.dat` and `ups.dat` save containers beneath
   the ignored portable content root.
10. Several Day 1 activities were completed and the save containers received
    newer timestamps, consistent with automatic saving during progression.
11. Choosing Quit Game from Poolside, closing Xenia, relaunching the same pinned
    build, and entering Main Game successfully loaded the existing vacation.
12. The emulator window remained responsive throughout the observation.

One first campaign start appeared to remain black for more than 30 seconds
while Xenia stayed responsive and consumed roughly one CPU core. Repeating the
route with the newly created profile reached the campaign cinematic. Treat this
as a possible first-run loading or shader-cache transition until it can be
reproduced under controlled cache conditions; it is not currently classified as
a deterministic hang.

Not yet verified:

- Audio correctness; XAudio2 initialized, but audio was not evaluated.
- Completion of a full in-game day.
- Frame timing or renderer correctness beyond the observed frontend, beach
  dialogue, and island interface.
- Whether the first-start black transition depends on cold shader caches,
  profile initialization, or another state variable.

Recomp enhancement backlog: allow the Team Ninja startup logo to be skipped,
while retaining the original unskippable behavior as a compatibility option.

## Deterministic smoke-test route

The current repeatable route is:

1. Start the pinned portable Xenia build with an existing local test profile.
2. Launch the verified base `default.xex` directly.
3. Confirm the window identifies Title ID `544307D2`, version `0.0.0.3`, D3D12,
   and XAudio2.
4. Confirm the legal warning, opening movie, and title screen render.
5. Press Start with the attached Xbox controller and choose Main Game.
6. Confirm the campaign cinematic reaches Character Select.
7. Select Helena and advance her opening dialogue.
8. Confirm the Day 1 Morning island/activity interface appears.
9. Confirm the ignored portable content root contains title-specific save
   containers for `544307D2`.

The autosave/reload portion of this route is verified. The next extension is to
complete a full in-game day and record timing, audio, and renderer discrepancies
for each activity used in the smoke test.

Raw configurations, caches, logs, screenshots, and portable content remain in
ignored `evidence/local/` and must not be committed or attached publicly.
