# Development Layout

Only the repository-safe side of this layout is committed.

| Path | Tracked | Purpose |
| --- | --- | --- |
| `docs/` | Yes | Original plans, decisions, and sanitized findings |
| `scripts/` | Yes | Original acquisition, metadata, and hygiene automation |
| `manifests/public/` | Yes | Hashes and non-expressive compatibility metadata |
| `config/` | Conditional | Original configuration after review |
| `runtime/` | Conditional | Independently authored host/runtime code |
| `game/` | No | Locally extracted user-supplied game data |
| `generated/` | No | Recompiler output derived from the game executable |
| `build/` | No | Build products and fetched dependencies |
| `evidence/local/` | No | Logs, captures, dumps, screenshots, and raw reports |
| `tools/*` | No | Local tool checkouts pinned in `toolchain.lock.json` |

Scripts must accept explicit paths or resolve paths relative to the repository.
They must not contain developer usernames, machine names, drive-specific absolute
paths, secrets, keys, or proprietary filenames beyond generic expected inputs.

