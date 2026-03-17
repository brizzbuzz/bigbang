---
name: spacebar-guild-admin
description: Recover or grant Spacebar guild admin access through the UI, API, or direct Postgres intervention when normal management paths are broken.
---

Use this skill when a user needs guild admin access and the normal Spacebar management path is unavailable.

## Escalation order

1. Use the Fermi UI if it works.
2. Fall back to the Spacebar API if the UI cannot assign the role.
3. Use Postgres only when the higher-level paths are unavailable.

## Required context

- Guild ID
- Target user ID
- Admin role ID, or a way to create one
- API access or SSH and Postgres access

## Success conditions

- The admin role has the administrator permission bit
- The target member is associated with the role
- The user can access guild admin functions after refreshing or re-authenticating

## Safety

- Prefer idempotent operations
- Verify role and member identity before making changes
- Use direct database writes only as the last resort
