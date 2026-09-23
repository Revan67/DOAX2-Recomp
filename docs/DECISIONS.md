# Decision Log

Record decisions that affect reproducibility, architecture, legal boundaries,
or supported game builds. Each entry should include the date, decision, evidence,
alternatives considered, and consequences.

## 2026-09-22 — Separate repository

Decision: maintain DOAX2 in `D:\Dev\doax2` as an independent Git repository
from the Rumble Roses project.

Reason: the projects can share research methods while preserving independent
history, build products, game data, configuration, and title-specific runtime
work.

## 2026-09-22 — Windows-first bootstrap

Decision: target Windows x86-64 first and postpone additional host platforms
until stable gameplay exists.

Reason: it matches the current development environment and reduces the number
of variables during CPU, runtime, and GPU bring-up.

## 2026-09-22 — Public-repository boundary

Decision: enforce a conservative public-repository policy with both ignore rules
and a tracked-file hygiene script. Game files, generated translations, raw
reverse-engineering artifacts, captures, logs, and proprietary materials remain
local and untracked.

Reason: ignored files can still be force-added accidentally, so publication
safety requires an explicit pre-push validation gate as well as `.gitignore`.

## 2026-09-22 — Initial toolchain split

Decision: use XboxDev `extract-xiso` solely for local disc extraction and
ReXGlue as the primary recompilation/runtime path. Keep XenonRecomp available as
a reference analyzer, but do not combine two translation paths during bootstrap.

Reason: narrow tool responsibilities improve auditability and reproducibility,
while a single primary runtime avoids multiplying unknowns during initial boot.

