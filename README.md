# DOAX2 Recompilation Project

[![Project phase](https://img.shields.io/badge/phase-3%20static%20analysis-2563eb)](docs/ROADMAP.md)
[![Target](https://img.shields.io/badge/target-Windows%20x86--64-0078d4)](docs/ROADMAP.md)
[![Launcher](https://img.shields.io/badge/launcher-not%20yet%20playable-lightgrey)](docs/ROADMAP.md)
[![Last commit](https://img.shields.io/github/last-commit/Revan67/DOAX2-Recomp)](https://github.com/Revan67/DOAX2-Recomp/commits/main)
[![Public repository policy](https://img.shields.io/badge/repository-clean--room%20boundary-2ea44f)](LEGAL.md)

An experimental native recompilation project for the Xbox 360 release of
*Dead or Alive Xtreme 2*. The initial target is Windows x86-64.

No playable recompilation or launcher is available yet.

## Current status

- Phase 0: public repository and evidence boundary complete.
- Phase 1: base-disc and executable inventory complete.
- Phase 2: pinned Xenia behavioral oracle complete through Day 2 progression.
- Phase 3: deterministic strict ReXGlue translation established; startup-call
  mapping is in progress.

The verified source target is identified by public hashes and metadata, but the
source game and generated translations are never distributed here. See the
[roadmap](docs/ROADMAP.md), [Phase 1 findings](docs/PHASE_1_FINDINGS.md),
[Phase 2 baseline](docs/PHASE_2_BASELINE.md), and
[Phase 3 findings](docs/PHASE_3_FINDINGS.md).

## What this repository will contain

Only the independently authored material necessary to reproduce the analysis,
build the eventual launcher/runtime, and validate user-supplied source data:

- Launcher and host-runtime source code as it is implemented.
- Build files, toolchain pins, and minimal analysis configuration.
- Input-validation, repository-hygiene, and local code-generation scripts.
- Original interoperability documentation and factual compatibility metadata.

Build products, dependencies, raw evidence, and local generated code remain
ignored. Public releases will contain only redistributable project components.

## Required user input

Anyone building or using the project must provide files dumped from a copy of
the game they lawfully own. This repository does not provide the ISO, XEX,
extracted assets, title updates, DLC, keys, saves, or proprietary SDK material.

The currently supported base image is documented in
[`manifests/public/disc-base.json`](manifests/public/disc-base.json).

## Development checks

Before every push, run:

```powershell
pwsh -File scripts/check_repository_hygiene.ps1
```

Developers with the ignored local ReXGlue toolchain and their own verified game
dump can additionally run:

```powershell
pwsh -File scripts/verify_rexglue_codegen.ps1
```

Read [LEGAL.md](LEGAL.md) and [CONTRIBUTING.md](CONTRIBUTING.md) before
publishing or contributing any artifact.

## Unofficial project

This project is not affiliated with or endorsed by Team Ninja, Tecmo, Koei
Tecmo, Microsoft, or the Xenia project. Product names and trademarks belong to
their respective owners.
