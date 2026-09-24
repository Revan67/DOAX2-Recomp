# Phase 4 Host Runtime Findings

## Native build baseline

Phase 4 began from the ignored ReXGlue host scaffold generated during Phase 3.
The public repository still contains no generated translation or game data.

The first Windows x86-64 Debug build used:

- ReXGlue SDK revision `c94f5ebdcb3c9d1a460ca48e04f9758448f8d518`
- Visual Studio 2022 Developer PowerShell 17.14.39
- Clang/Clang++ 19.1.5
- Ninja through the SDK-generated CMake preset
- D3D12 host backend

After two narrowly scoped build workarounds, all 121 generated translation
partitions compiled and the host linked successfully. The ignored local result
was a 108,920,320-byte Debug executable with SHA-256
`b3394033bdf40a29725f155cf63665bd249bfa422f1628ab5f411df02b341fd7`.
The hash identifies this diagnostic build only; the executable is not a public
release artifact and is not tracked.

## Pinned SDK integration issues

The clean initial build exposed two reproducible SDK-side issues:

1. `src/core/memory.cpp` uses the SSSE3 `_mm_shuffle_epi8` intrinsic, but the
   internal `rexcore` target does not receive an SSSE3-or-later compiler flag
   under Windows Clang. Configuring with `CMAKE_CXX_FLAGS=-msse4.1` allowed the
   endian-copy routines to compile.
2. The generated host target compiles SDK `rex_app.cpp`, whose public include
   chain reaches `imgui.h`, without receiving the SDK's private ImGui include
   directory. Adding `thirdparty/imgui` to the host target's private include
   directories resolved the failure.

Neither workaround changes translated game logic. They remain local until a
small, reviewable build integration patch is added and validated against a
clean SDK checkout.

## Current checkpoint

The project has crossed the Phase 4 compile/link checkpoint. It has not yet
crossed the execution checkpoint: successful linking does not prove guest
memory setup, XEX image loading, import registration, or entry-point execution.

Next work:

1. Make the two build workarounds reproducible without editing generated files.
2. Launch the diagnostic binary with structured logging enabled.
3. Record the earliest repeatable runtime checkpoint and the first undefined or
   failing import, without treating a created window as successful boot.

