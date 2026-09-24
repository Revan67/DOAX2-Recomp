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

## First execution result

The first run with an explicit ignored game-data root successfully initialized
guest virtual and physical memory, MMIO, input, audio, the virtual filesystem,
and the function dispatcher. It loaded the supported XEX, registered 18,245
translated functions, created 73 XAM and 156 kernel import symbols, and reached
module-launch preparation.

The first live-dispatch failure was an indirect call to unregistered guest
address `0x82A1B3F0`. This aligned address is within the executable code range
and immediately follows the discovered `0x82A1B3D0` thunk. It has therefore
been added as a minimal function-discovery hint for strict regeneration. The
next run advanced to `0x82A1B410`, revealing a contiguous family of 32-byte
indirect callback thunks. Static regeneration confirmed the fixed-size pattern
through the next already discovered function at `0x82A1B490`; the intervening
aligned starts `0x82A1B410`, `0x82A1B430`, `0x82A1B450`, and `0x82A1B470` are
now declared together rather than discovered through repeated crashing runs.

With that family present, module launch advanced to a second missed entry point
at `0x82A1ECC0`. Strict regeneration identifies it as a substantive function,
not another callback thunk, and accepts it without unresolved or fatal output.
The next controlled launch will begin from this expanded 18,251-function set.

That launch advanced again, to unregistered address `0x82A49E58`. The address
immediately follows the known 32-byte indirect thunk at `0x82A49E38`; the next
existing discovered function begins at `0x82A49F28`. Strict regeneration shows
three additional 32-byte thunks at `0x82A49E58`, `0x82A49E78`, and
`0x82A49E98`, followed by a substantive missed function at `0x82A49EB8`.
Addresses inside that final function were explicitly rejected as entry points
rather than retained as artificial function fragments.

The corrected 18,255-function build survived through that group and next
selected `0x82A4A308`. Although it lies between two known indirect thunks, the
gap is larger than a single thunk and its surrounding data-argument pattern
does not justify inferring additional starts. Only the runtime-proven address
is therefore declared pending strict regeneration.

That function advanced launch to `0x82A4A640`, exactly after the 32-byte thunk
at `0x82A4A620` and 16 bytes before the known `0x82A4A650` function. Only this
runtime-selected address is added for validation; no neighboring starts are
inferred from such a short gap.

The 18,257-function run then reached `0x82A54F30`. It immediately follows the
known 32-byte thunk at `0x82A54F10`, but the next known function is 64 bytes
later at `0x82A54F70`. Only `0x82A54F30` is declared; strict regeneration must
establish its body before any further address is considered.

Strict regeneration established `0x82A54F30` as a complete 32-byte indirect
callback thunk ending at `0x82A54F50`. The remaining bytes before
`0x82A54F70` are not declared as code without independent runtime evidence.

The next controlled run supplied that evidence by dispatching directly to
`0x82A54F50`. This exactly fills the final 32-byte slot before the known
`0x82A54F70` function. Strict regeneration confirms it is the second complete
indirect callback thunk in the pair.

With both callbacks present, the 18,259-function run advanced to
`0x82A55220`. It lies immediately after the known 32-byte callback thunk at
`0x82A55200` and 16 bytes before the known function at `0x82A55230`. Only the
runtime-selected address was declared. Strict regeneration confirms it is a
complete 16-byte tail-call thunk to `sub_829ECB08`.

