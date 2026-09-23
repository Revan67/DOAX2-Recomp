# Legal and Repository Policy

This repository is intended to be public. This deliberately conservative policy
reduces avoidable risk, but it is not legal advice. Reverse-engineering and
interoperability law varies by jurisdiction.

## Scope

The project contains independently authored interoperability research,
configuration, documentation, and host-runtime code. It is not a source for
*Dead or Alive Xtreme 2*, Xbox 360 system software, or proprietary development
materials.

## Never commit, upload, or release

- Disc images, XEX/XEXP files, title updates, DLC, extracted archives, game
  assets, executable sections, or fragments of any of those files.
- Recompiler-generated translations of the game executable, generated switch
  tables, bulk function/address databases, disassembly, or decompiled game logic.
- Extracted or translated shaders, caches, textures, models, animation, audio,
  video, fonts, text, localization, screenshots, or recordings containing game
  content unless separately reviewed for a specific publication.
- Xbox keys, certificates, credentials, device secrets, decryption material, or
  tools/material whose purpose is defeating access controls.
- Proprietary SDK headers, libraries, symbols, documentation, leaked source, or
  confidential material.
- Dumps, traces, logs, saves, profiles, or test packages that may embed game data,
  personal data, machine identity, or absolute user paths.
- Builds, installers, archives, CI artifacts, issue attachments, or release files
  containing anything above.

## Repository-safe content

- Independently authored host-runtime and compatibility code.
- Original build, validation, and metadata scripts.
- Configuration containing no copied third-party expression.
- Factual hashes, sizes, version identifiers, counts, and observations needed to
  identify compatible user-supplied input.
- Original documentation describing architecture and observable behavior.
- Open-source dependencies used according to their licenses, preferably as
  pinned external revisions rather than vendored copies.

## Development rules

1. Contributors supply their own lawfully obtained game copy in ignored paths.
2. Extraction, analysis, code generation, shader conversion, and captures happen
   locally; their output remains untracked.
3. Never attach proprietary files to issues, pull requests, CI, caches, or logs.
4. Do not paste generated or decompiled game logic into handwritten code.
5. Describe behavior in original words and implement interfaces independently.
6. Run `scripts/check_repository_hygiene.ps1` before every push.
7. Stop and review uncertain material before committing; deletion after a public
   push cannot remove forks, caches, or existing clones.

## Trademarks and affiliation

*Dead or Alive*, *Dead or Alive Xtreme 2*, Team Ninja, Tecmo, Koei Tecmo, Xbox,
Microsoft, and associated names and marks belong to their respective owners.
This project is unofficial and is not endorsed by or affiliated with them.

