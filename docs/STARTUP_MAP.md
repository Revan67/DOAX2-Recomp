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
| `0x8258DD38` | First game-owned main-dispatch candidate | Calls five game-owned routines before returning a result |
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
4. The transitive initialization path below `0x8258DD38`, which is the next
   mapping target and is not yet claimed to be the final game main loop.

## Open questions

- Resolve and classify the runtime-populated callback tables used by
  `0x82786798` and `0x827866B8`.
- Map the five direct descendants of `0x8258DD38` and identify the first
  filesystem, window, graphics, audio, and input boundaries.
- Determine the earliest observable checkpoint suitable for a headless native
  smoke test.
