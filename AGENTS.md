# Repository Guidelines

## Project Structure & Modules
- Top-level flake config in `flake.nix`; dev shell config in `flake/shell.nix`.
- Host definitions live in `hosts/` (one directory per machine). Shared logic sits in `modules/` with subfolders for `common/`, `darwin/`, `nixos/`, and `overlays/`.
- Utility files: `cliff.toml` for changelog rules, `CHANGELOG.md` for history. Use `flake/` for flake helpers and shell setup.

## Build, Test, and Development
- `nix develop` — enter the dev shell with formatting, linting, and deployment tools preloaded.
- `nr` — rebuild the local system (darwin-rebuild switch or colmena apply-local).
- `nrr <host>` — deploy to a remote host via Colmena.
- `nix flake check --show-trace` — validate the flake, options, and evaluations.
- `alejandra .` — format all Nix files.
- `deadnix .` — detect unused Nix definitions.
- `git-cliff -p` — generate changelog updates; keep `CHANGELOG.md` in sync when releasing.

## Coding Style & Naming
- Nix files use 2-space indentation and Nixpkgs style conventions; prefer explicit imports and alphabetized lists.
- Keep host-specific config in `hosts/<name>/` and shared modules in `modules/` with clear option interfaces.
- Use camelCase for variables and functions; write declaratively and add brief comments only for non-obvious logic.
- Preserve overlay and module boundaries: place reusable packages or tweaks in `modules/overlays/` rather than hosts.

## Testing & Validation
- Primary checks: `nix flake check`, `alejandra --check .`, and `deadnix --fail .` (mirrors CI). Run these before pushing.
- For deployment rehearsal, run `nr` locally; use `nrr <host>` for targeted remote verification.
- Keep profiles and host inputs minimal to avoid impurity surprises; prefer deterministic options and pinned inputs.

## Commit & Pull Requests
- Follow conventional commits (`feat: ...`, `chore: ...`, `fix: ...`) as seen in history; include scope when useful.
- PRs should describe the intent, list affected hosts/modules, and note any deployment steps (`nr`, `nrr <host>`). Include output snippets for `nix flake check` when changes are wide-reaching.
- Update `CHANGELOG.md` via `git-cliff` when making user-visible changes. Link issues or tickets when available.
