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
