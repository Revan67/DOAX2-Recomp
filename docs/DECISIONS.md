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

