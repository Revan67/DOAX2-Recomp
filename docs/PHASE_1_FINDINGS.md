# Phase 1 Findings

## Supported source image

The initial source is a user-supplied Xbox 360 disc image identified by the
public manifest `doax2-disc-base-5a642963`.

- Size: 7,834,892,288 bytes
- SHA-256: `5a642963dd43b212355dde562878f80e306bc5a18a5ecccf458930c616f12036`
- Extracted filesystem: 64 files, 6 directories, 6,604,948,720 bytes

No file listing or game content is tracked.

## Base executable

- File size: 15,749,120 bytes
- SHA-256: `c4a14853e1f7af951be34f380604113703638780b36d5e74e674fe7431992870`
- Title ID: `544307D2`
- Media ID: `21B9628E`
- Version: `0.0.0.3`
- XEX timestamp reported by ReXGlue: 2006-10-22 15:53:51 UTC
- Image base: `0x82000000`
- Entry point: `0x82784C18`
- Code base observed by ReXGlue: `0x82410000`
- XEX optional-header count: 16
- Expanded image size: 32,047,104 bytes
- Encryption: normal
- Compression: basic
- Page descriptors: 489
- Section descriptors: 103 code, 312 data, 74 read-only data
- Imports: 448 symbols across two libraries (`xam.xex` and `xboxkrnl.exe`)

The title, media, version, image, and code-base values were measured from the
local XEX using pinned ReXGlue revision
`c94f5ebdcb3c9d1a460ca48e04f9758448f8d518`. They were not copied from a web
database.

## Extraction and analysis tools

- XboxDev `extract-xiso` revision
  `3f5b62cfe68f000b0e3c8a30104973f3a297948e` extracted the disc successfully.
- ReXGlue revision `c94f5ebdcb3c9d1a460ca48e04f9758448f8d518`
  built locally as version `0.10.0.2-dev.gc94f5eb`.
- The first strict ReXGlue analysis completed discovery but stopped validation
  with two unresolved calls. A forced local generation confirmed the pipeline
  can emit output, but all generated output remains ignored and must not be
  published.

## Title update policy

The supported bootstrap target is the unmodified disc executable. No title
update has been applied. Title-update investigation is deferred until the base
build reaches a measurable boot checkpoint or a documented compatibility reason
requires a separate updated target.

## Phase 1 exit status

Complete. The public manifest identifies the supported disc and executable,
the metadata scripts reproduce its hashes and XEX facts, and no extracted or
generated content is tracked. Raw reports remain under ignored local evidence.
