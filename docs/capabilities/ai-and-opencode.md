# AI and OpenCode

This capability is primarily centered on `ganymede`, with supporting configuration also deployed to user machines.

## Purpose

The OpenCode capability provides:

- hosted OpenCode instances on `ganymede`
- user-level OpenCode configuration on managed machines
- MCP configuration for local and remote tools
- shared agent and command files deployed from the repo

## Hosts Involved

- `ganymede` hosts the long-running OpenCode service instances
- `frame`, `pip`, and `dot` receive user-level OpenCode configuration through the shared config-file system

## Main Modules

- `modules/nixos/opencode.nix`
- `modules/common/users/config-files/configs/opencode.nix`
- `modules/common/users/config-files/files/opencode/`

## Hosted Instances

`ganymede` currently hosts two OpenCode instances:

- `ryan` on port `4096`
- `odyssey` on port `4097`

Those are exposed internally through `callisto`.

## Secret and Identity Model

The hosted OpenCode module relies heavily on OpNix and 1Password for:

- SSH auth keys
- SSH signing keys
- optional server auth secrets
- Kagi API access

## MCP Model

The user-facing OpenCode config currently enables a mix of local and remote MCP servers.

Examples include:

- `chrome_devtools`
- `nixos`
- `nushell`
- `linear`
- `kagi`
- `datadog` for company profiles
- `notion` for company profiles

## Current Notes

- OpenCode is both a hosted service capability and a user environment capability.
- Repo-level agent, command, and skill files are copied directly into user config directories during activation.

## Runtime Paths

The hosted OpenCode services on `ganymede` do not read the user-level `~/.config/opencode` trees.

- Hosted `ryan` runtime: `/home/ryan/.local/share/opencode-service-ryan/config/opencode`
- Hosted `odyssey` runtime: `/home/odyssey/.local/share/opencode-service-odyssey/config/opencode`
- User-level config trees still exist at `~/.config/opencode` for interactive local use

## Expected Global Commands And Skills

The globally deployed OpenCode assets should include these command files:

- `commit-branch`
- `create-pr`
- `draft-pr`
- `grill-me`
- `improve-codebase-architecture`
- `prd-to-issues`
- `review-pr`
- `tdd`
- `write-a-prd`

The globally deployed skill set should include these base skills:

- `frontend-design`
- `git-commit-and-draft-pr`
- `grill-me`
- `improve-codebase-architecture`
- `prd-to-issues`
- `product-manager`
- `review-pull-request`
- `tdd`
- `write-a-prd`

## PR Safety Expectations

Global OpenCode guidance should enforce these defaults for PR creation:

- Load the `git-commit-and-draft-pr` skill for pull request creation requests
- Default to draft mode unless the user explicitly asks for ready-for-review
- Pass only clean rendered Markdown to `gh pr create`
- Never include shell wrapper text like `$(cat <<'EOF'`, `EOF`, or trailing `)` in the PR body
- Never post the PR body template as a GitHub comment unless the user explicitly asks for that comment

## Verification

After changing the OpenCode config in this repo and deploying `ganymede`, verify both hosted accounts against the runtime paths above.

Check at minimum:

- `AGENTS.md` contains the global PR safety rules
- `commands/` contains both `draft-pr.md` and `create-pr.md`
- `skills/git-commit-and-draft-pr/SKILL.md` contains the PR body sanity-check guidance
- `opencode.json` still reflects the expected MCP set for `ryan` and `odyssey`
