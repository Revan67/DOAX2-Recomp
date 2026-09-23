# Phase 3 Toolchain Findings

## Strict-analysis baseline

The pinned ReXGlue build `c94f5ebdcb3c9d1a460ca48e04f9758448f8d518`
was rerun against the verified base executable without force mode and with its
generation stamp bypassed.

Automatic discovery initially stopped validation on two direct tail branches:

- `0x82723004` to `0x8271F580`
- `0x829B17C4` to `0x829B96A8`

Both targets are aligned executable addresses between neighboring discovered
functions. The callers are small adjustment/tail thunks, not indirect calls or
jump tables. Declaring the two missed entry points allowed validation to pass.

The subsequent write phase exposed one additional direct tail target,
`0x82783210` to `0x82785670`, that the validation phase did not report. Without
an explicit entry point, ReXGlue returned success while emitting a fatal runtime
stub. The third target was therefore added to the same minimal hint set.

## Deterministic result

With the three entry-point hints in
`manifests/public/rexglue-base-disc.toml`, strict code generation completed
without force mode. An immediate second run reported:

- 0 files written
- 249 files unchanged
- 0 files deleted
- 18,245 generated function declarations
- 121 generated C++ partitions

The ignored generated output contains no unresolved-call, unresolved-function,
unsupported-instruction, or `REX_FATAL` markers.

Raw logs and generated translations remain local and ignored. The checked-in
file contains only the three minimal discovery facts required to reproduce
strict generation for the supported executable hash.

## Toolchain issue identified

Validation can currently miss a direct branch that later produces a fatal stub
during code emission. Until that behavior is corrected upstream, Phase 3 checks
must inspect both the process exit status and generated output for fatal or
unresolved markers. `scripts/verify_rexglue_codegen.ps1` automates both checks
while keeping its log and generated translations in ignored local directories.

## Next analysis slice

Strict translation is now deterministic. The next task is to map the executable
entry point and its transitive startup calls, identify the first kernel/XAM
boundary, and select the smallest boot-critical slice for the native runtime.

The first direct layer from `xstart` at `0x82784C18` is now mapped in
`docs/STARTUP_MAP.md`. It identifies nine game/CRT callees plus direct
`DbgPrint` and `XamLoaderTerminateTitle` boundaries. The next active slice is
the subsystem boundary below the persistent game dispatcher at `0x8258DD38`.
That dispatcher is now known to run two one-time initialization stages followed
by a three-stage recurring frame loop. Its platform-init branch reaches video,
filesystem, event, and synchronization imports within one additional layer.
Bounded descendant slices also locate controller polling and timing in the
first recurring stage, while the final recurring stage reaches the video
command-buffer and swap boundaries. The middle stage remains the broad main
game-update region. These slices can be reproduced locally with
`scripts/summarize_rexglue_call_slice.ps1`; no generated translation or bulk
call database is published.

The controller branch is now narrowed to three XAM imports: capability query,
state polling, and vibration output. `docs/INPUT_BOUNDARY.md` records the proven
paths and the minimal smoke-test contract while leaving guest structure-layout
verification for runtime bring-up.
