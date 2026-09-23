# Startup Call Map

This document records a bounded, factual call map for the supported base-disc
executable. It contains no disassembly or translated game logic. Addresses are
specific to manifest `doax2-disc-base-5a642963`.

## Entry point

- XEX entry point: `0x82784C18`
- ReXGlue symbol: `xstart`

The entry point performs platform/environment initialization, invokes the game
dispatcher, reports its return value through the debug-print import, and asks
XAM to terminate the title.

## First direct call layer

| Address | Evidence-based classification | Notable boundary |
| --- | --- | --- |
| `0x82785C90` | Early termination/firmware callback wrapper | May call `HalReturnToFirmware` |
| `0x827865C8` | Serialized callback invocation | Uses `RtlEnterCriticalSection` and `RtlLeaveCriticalSection` |
| `0x82784A48` | Console environment and launch-policy setup | Queries executable privilege, AV pack, configuration, and language |
| `0x829F0948` | CRT/TLS and static-initialization coordinator | Allocates and sets kernel TLS; invokes initializer callbacks |
| `0x82786798` | Single indirect startup callback pass | Indirect call target remains runtime-selected |
| `0x827866B8` | Multi-stage indirect startup callback pass | Contains three runtime-selected calls |
| `0x827866A8` | No-op startup hook | Returns without further calls in the supported build |
| `0x8258DD38` | Persistent game-owned dispatcher | Runs two one-time initialization stages, then loops across three per-frame stages |
| `0x829EFCC0` | Post-dispatch CRT cleanup wrapper | Tail-dispatches to `0x829EFB40` |

Direct imports used by `xstart` itself are `DbgPrint` and
`XamLoaderTerminateTitle`. Helper save/restore routines are omitted from the
logical call map.

## Current boot-slice boundary

The initial native boot slice must include:

1. `xstart` and its nine first-layer game/CRT functions listed above.
2. Kernel support for critical sections, TLS allocation/value storage, firmware
   return behavior, executable privilege/configuration queries, AV-pack and
   language queries, debug printing, and title termination.
3. Function-dispatch support for the indirect initializer/callback targets.
4. The initialization and frame-stage descendants below `0x8258DD38`.

## Game dispatcher structure

`0x8258DD38` has the following stable control-flow shape:

1. `0x8258DD60` — one-time platform/system initialization. Within one additional
   call layer it reaches video-mode detection, filesystem-cache configuration,
   volume/file queries, event creation, and critical-section synchronization.
2. `0x8258E1C0` — one-time game-system initialization. Deeper descendants
   reach thread creation/resume and affinity, memory management, sign-in-state
   inspection, and the dirty-disc error UI.
3. `0x8258E000` — recurring timing/input and pre-update stage. Its bounded call
   slice reaches the performance-frequency query and XAM controller
   capability, state, and vibration boundaries.
4. `0x8258E500` — second and largest recurring stage. Its much broader game
   graph includes content, profile, networking, and audio-facing work; it is
   conservatively classified as the main game-update stage.
5. `0x8258E0D8` — final recurring presentation stage, followed by a branch back
   to `0x8258E000`. Its bounded slice reaches video-mode queries and the system
   command-buffer, display-persistence, and swap boundaries.

These labels describe host-facing evidence, not a complete reconstruction of
the game engine. In particular, rendering work may be prepared before the
final presentation stage.

`scripts/summarize_rexglue_call_slice.ps1` can reproduce bounded call slices
from ignored local generated output without writing or publishing a call
database.

## Open questions

- Resolve and classify the runtime-populated callback tables used by
  `0x82786798` and `0x827866B8`.
- Map the controller-state path beneath `0x8258E000` and determine the minimal
  input ABI required for a native smoke test.
- Separate graphics command construction from final presentation and identify
  the first audio boundary used during boot.
- Determine the earliest observable checkpoint suitable for a headless native
  smoke test.
