# Controller Input Boundary

This document records the smallest controller-facing boundary currently proven
for the supported base-disc executable. It contains no translated game code or
game assets.

## Recurring call path

The first recurring dispatcher stage reaches all three controller operations
through a short title-owned path:

| Operation | Proven path from `0x8258E000` | Host import |
| --- | --- | --- |
| Device capabilities | `0x8258E000` → `0x8258CEF0` → `0x8274B650` → `0x82782BE8` | `XamInputGetCapabilities` |
| Poll controller state | `0x8258E000` → `0x8258CEF0` → `0x8274B650` → `0x82782BF0` | `XamInputGetState` |
| Set vibration state | `0x8258E000` → `0x8258CEF0` → `0x8274B650` → `0x82782C00` | `XamInputSetState` |

The state and vibration thunks move the title-provided buffer pointer into the
XAM argument position and set the flags argument to zero. The vibration thunk
also clears its unused trailing arguments. The capability thunk branches
directly to its XAM import.

## Minimal native smoke-test contract

The initial host runtime does not need a complete input configuration system.
It needs enough behavior to:

1. Report whether controller slot 0 is connected and provide compatible
   capability data.
2. Return a stable packet counter plus buttons, triggers, and both thumbsticks
   for the connected controller.
3. Accept left- and right-motor vibration requests, including an all-zero stop
   request.
4. Return a consistent not-connected result for empty controller slots.
5. Preserve Xbox 360 structure layout, endianness, and guest-memory pointer
   handling at the import boundary.

The attached Xbox Series controller already passed the Phase 2 Xenia baseline.
That demonstrates suitable test hardware, but does not validate a future native
backend. Native validation must separately exercise connect, polling, packet
changes, analog ranges, and vibration shutdown.

## Reproducing the boundary

After producing ignored local ReXGlue output, print only host-import paths with:

```powershell
.\scripts\summarize_rexglue_call_slice.ps1 `
  -RootFunction sub_8258E000 `
  -Depth 4 `
  -ImportsOnly
```

The script reads generated output locally and does not create a call database.

