# DOAX2 Recompilation Roadmap

## Objective

Produce a maintainable native PC recompilation of the Xbox 360 release of
*Dead or Alive Xtreme 2*, using legally dumped user-supplied game data and a
publicly redistributable runtime/toolchain.

The initial target is Windows x86-64. Other platforms are deferred until the
Windows implementation reaches stable gameplay.

## Working principles

- Treat every address, import, binary layout, shader behavior, and workaround
  as title- and build-specific until verified against DOAX2.
- Reuse methods and tooling lessons from the Rumble Roses work, not its
  game-specific constants or generated output.
- Keep original game data and generated code derived from it outside Git.
- Record hashes and tool versions so every result is reproducible.
- Advance by evidence gates. A milestone is complete only when its stated
  artifact and test evidence exist.
- Prefer minimal diagnostic probes before implementing broad compatibility
  layers.

## Phase 0 — Repository and evidence discipline

Deliverables:

- Independent Git repository and preservation-safe ignore rules.
- Project scope, legal boundary, directory conventions, and decision log.
- A reproducible metadata script that records hashes without copying game data.
- A baseline report template for host hardware, operating system, tools, game
  region/version, and test results.

Exit gate: repository hygiene check reports no proprietary or generated game
content tracked by Git.

## Phase 1 — Disc and executable inventory

Tasks:

1. Hash the original ISO and record its size, region/build identifiers, and
   volume metadata.
2. Select and pin an extraction tool; extract into an ignored directory.
3. Inventory executables, modules, archives, media, and directory structure.
4. Hash `default.xex` and identify title ID, media ID, version, base address,
   entry point, imports, sections, and compression/encryption state.
5. Identify whether a title update is needed; begin with the unmodified disc
   executable unless evidence requires otherwise.

Exit gate: a checked-in metadata manifest can identify the exact supported
build without containing game data.

## Phase 2 — Emulator baseline and behavioral oracle

Tasks:

1. Capture behavior on a pinned Xenia build and configuration.
2. Document boot sequence, profile requirement, save creation, menus, loading,
   audio, input, and first playable activity.
3. Record known renderer failures separately from expected game behavior.
4. Capture logs, screenshots, frame timings, and important filesystem access in
   ignored evidence directories.
5. Define a short deterministic smoke-test path through the game.

Exit gate: the same smoke-test path is repeatable and its expected behavior is
documented well enough to compare against a recomp build.

## Phase 3 — Toolchain proof and static analysis

Tasks:

1. Evaluate the current ReXGlue/XenonRecomp ecosystem against the exact XEX.
2. Pin toolchain commits and document all local patches.
3. Generate function discovery and import reports without committing derived
   code.
4. Measure unresolved branches, indirect calls, jump tables, unsupported PPC
   instructions, and exception/unwind behavior.
5. Map startup-critical functions and select the smallest boot slice.

Exit gate: translation completes deterministically, and all unsupported or
ambiguous constructs are enumerated rather than silently accepted.

## Phase 4 — Host runtime and CPU boot

Tasks:

1. Establish guest memory layout, stack, TLS, clocks, synchronization, and
   executable dispatch.
2. Implement only the kernel/XAM imports observed on the startup path.
3. Add structured logging, fatal diagnostics, guest address symbolization, and
   deterministic error codes.
4. Reach the entry point, then progressively reach initialization checkpoints.
5. Add focused probes for memory aliasing, atomics, endian conversion, callbacks,
   and indirect dispatch before expanding the runtime.

Exit gate: the recompiled executable repeatedly reaches a documented game
initialization checkpoint without relying on undefined stubs.

## Phase 5 — Filesystem, content, profile, and saves

Tasks:

1. Implement disc/content path mapping and required filesystem semantics.
2. Reproduce profile sign-in behavior locally without Xbox Live.
3. Support content enumeration and game configuration reads.
4. Implement save creation, validation, atomic writes, and recovery testing.
5. Keep save data isolated from source and game extraction directories.

Exit gate: the game passes its profile gate, creates a save, restarts, and loads
that save reproducibly.

## Phase 6 — Window, input, timing, and audio

Tasks:

1. Create a stable host window and event loop.
2. Map Xbox 360 controls through SDL/XInput with correct dead zones and vibration.
3. Validate guest time, frame pacing, and synchronization assumptions.
4. Bring up audio with format, channel, streaming, and latency diagnostics.
5. Confirm menus can be navigated through the deterministic smoke-test path.

Exit gate: menus are controllable, timing is stable, and audio operates without
blocking progression.

## Phase 7 — GPU bring-up

Tasks:

1. Capture and classify command processor traffic before changing rendering
   behavior.
2. Establish render-target, depth, texture, sampler, resolve, and presentation
   paths.
3. Translate and validate shaders against captured behavior.
4. Investigate DOAX2-specific effects independently: skin, hair, cloth, water,
   shadows, reflections, post-processing, and UI composition.
5. Build scene-specific probes and image-difference baselines.

Exit gate: the first deterministic in-engine scene renders with correct UI,
geometry, depth, and a documented list of remaining visual discrepancies.

## Phase 8 — Gameplay vertical slice

Target slice:

- Clean boot.
- Local profile and save load.
- Character selection and island arrival.
- Hotel/menu navigation.
- At least one complete activity.
- Save, exit, restart, and resume.

Exit gate: the complete slice passes repeatedly without fatal errors, save
corruption, or progression blockers.

## Phase 9 — Compatibility and completeness

Coverage areas:

- All characters and locations.
- Volleyball and every other activity/minigame.
- Shops, gifting, casino, collection, photography, and progression systems.
- Long-session memory behavior and transitions.
- Region/build differences and optional title-update support.
- Controller disconnect/reconnect, window focus, unusual resolutions, and
  recovery from interrupted saves.

Exit gate: a maintained compatibility matrix covers all major systems, and no
known blocker prevents completing a normal vacation cycle.

## Phase 10 — Native-PC quality and release

Tasks:

1. Add user-facing configuration, controller remapping, display modes, and safe
   defaults without changing game logic by default.
2. Package only redistributable project components.
3. Require users to install from their own verified disc image.
4. Add automated build, repository hygiene, smoke, and packaging checks.
5. Document known issues, supported hashes, provenance, licenses, and clean-room
   contribution rules.

Exit gate: a clean machine can build the project, install from a supported
user-supplied ISO, pass the smoke test, and produce a package containing no
copyrighted game files.

## Immediate work queue

1. Add repository hygiene automation.
2. Record the ISO hash and non-content metadata.
3. Select and pin the extraction/recompilation toolchain.
4. Extract into an ignored directory and create the executable/content inventory.
5. Establish the pinned Xenia baseline and deterministic smoke-test route.
6. Write the Phase 1 findings before generating any translated code.

## Current progress

- Phase 0 repository boundary, layout, baseline template, decision log, public
  manifest policy, and hygiene automation are implemented.
- The source ISO has been measured at 7,834,892,288 bytes with SHA-256
  `5a642963dd43b212355dde562878f80e306bc5a18a5ecccf458930c616f12036`.
- Extraction and executable verification remain open Phase 1 work.
- The disc was extracted locally into ignored storage. The base executable is
  verified as Title ID `544307D2`, Media ID `21B9628E`, version `0.0.0.3`.
- Pinned ReXGlue analysis reaches validation with two unresolved calls; generated
  translations remain local and ignored.
- Phase 1 is complete: the public manifest independently identifies the supported
  ISO and base XEX, including hashes, executable identifiers, layout summary,
  compression state, and aggregate imports.
- Phase 2 baseline on pinned Xenia Canary `02d2cb5` now reaches the title and
  profile gate, campaign cinematic, character selection, Helena's opening beach
  dialogue, and the Day 1 Morning island interface under D3D12/XAudio2. Xbox
  controller input and title-specific save creation are verified. Save reload,
  activity completion, audio correctness, and detailed renderer behavior remain
  open before the Phase 2 exit gate.

## Explicit non-goals for the bootstrap stage

- Distributing game files, keys, SDK components, title updates, or DLC.
- Claiming broad compatibility after merely reaching a window or menu.
- Importing Rumble Roses addresses, generated translations, or undocumented
  patches into this project.
- Adding enhancements before the original behavior is measurable and stable.
