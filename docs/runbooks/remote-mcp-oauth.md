# Remote MCP OAuth

Use this runbook when OpenCode is running on a remote machine such as `ganymede`, but the browser lives on a different machine.

## Problem

OpenCode MCP OAuth expects a local callback on the machine running OpenCode, usually:

`http://127.0.0.1:19876/mcp/oauth/callback`

When the browser is on a different machine, the provider redirects to the browser machine's loopback interface instead of the OpenCode host, so the flow never completes unless the callback is forwarded back to the remote host.

## Preferred Workflow

1. Start an SSH tunnel from the browser machine to the remote OpenCode host:

   `ssh -L 19876:127.0.0.1:19876 <host>`

2. On the remote host, run:

   `opencode mcp auth <server>`

3. Open the printed authorization URL in the local browser.

4. Let the provider redirect back to `127.0.0.1:19876`.

5. The SSH tunnel forwards that callback to the remote host.

6. Verify success on the remote host:

   `opencode mcp list`

## Why This Is Preferred

- it keeps the callback on loopback
- it works with OpenCode's current localhost callback behavior
- it avoids exposing the callback port through a reverse proxy

## Manual Fallback

If port forwarding is not available:

1. Run `opencode mcp auth <server>` on the remote host.

2. Open the authorization URL in the local browser.

3. After the provider redirects to `http://127.0.0.1:19876/...` and the browser fails to connect, copy the full callback URL.

4. On the remote host, send that exact callback URL with `curl` so the remote listener receives it.

## Safety Notes

- prefer SSH forwarding over binding the callback listener to `0.0.0.0`
- avoid exposing the callback port through a public reverse proxy unless the redirect URI is intentionally designed for it
- treat the callback URL like a short-lived credential exchange artifact
