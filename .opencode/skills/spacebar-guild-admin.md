# Spacebar Guild Admin Recovery Skill

## Overview

This skill documents how to grant a user admin access in a Spacebar guild when the UI is missing or broken. It covers Fermi UI, API fallback, and direct Postgres recovery (ganymede).

## Prerequisites

- Guild ID and target user ID
- Admin role ID (or ability to create one)
- Access to Spacebar API or SSH access to the Postgres host

## Phase 1: Fermi UI (Preferred)

1. Open guild settings and go to Roles.
2. Create a role named `@admin` (or similar).
3. Enable `Administrator` permission.
4. Move the role above normal member roles.
5. Assign the role to the target user (if UI supports it).

If the UI cannot assign roles, move to API fallback.

## Phase 2: API Fallback (No DB)

Use the Spacebar REST endpoint to assign a role directly.

**Assign a role to a member:**
```bash
curl -i -X PUT \
  -H "authorization: <TOKEN>" \
  "https://<instance>/api/v9/guilds/<GUILD_ID>/members/<USER_ID>/roles/<ROLE_ID>"
```

**Notes:**
- Expect HTTP 204 on success.
- You can grab the `authorization` token from an authenticated request in browser devtools.

If the API is failing or auth is blocked, move to DB fallback.

## Phase 3: Postgres Recovery (ganymede)

Run these queries in a transaction.

```sql
BEGIN;

SELECT id, name, owner_id
FROM guilds
WHERE id = '<GUILD_ID>';

SELECT id, username, discriminator
FROM users
WHERE id = '<USER_ID>';

SELECT id, name, permissions
FROM roles
WHERE id = '<ROLE_ID>'
  AND guild_id = '<GUILD_ID>';

SELECT id, guild_id, "index"
FROM members
WHERE id = '<USER_ID>'
  AND guild_id = '<GUILD_ID>';

-- Ensure Administrator bit (8) is present
UPDATE roles
SET permissions = ((permissions::bigint | 8)::text)
WHERE id = '<ROLE_ID>'
  AND guild_id = '<GUILD_ID>';

-- Attach role to member (idempotent)
INSERT INTO member_roles ("index", role_id)
SELECT m."index", '<ROLE_ID>'
FROM members m
WHERE m.id = '<USER_ID>'
  AND m.guild_id = '<GUILD_ID>'
  AND NOT EXISTS (
    SELECT 1
    FROM member_roles mr
    WHERE mr."index" = m."index"
      AND mr.role_id = '<ROLE_ID>'
  );

-- Verify
SELECT u.id AS user_id, u.username, r.id AS role_id, r.name, r.permissions
FROM users u
JOIN members m ON m.id = u.id
JOIN member_roles mr ON mr."index" = m."index"
JOIN roles r ON r.id = mr.role_id
WHERE u.id = '<USER_ID>'
  AND m.guild_id = '<GUILD_ID>';

COMMIT;
```

## Common Issues

- `member_roles` table uses column `index`, not `member_index`.
- If role assignment appears but UI does not update, have the user refresh or re-login.

## Success Checklist

- Role has Administrator permission bit set.
- Member is linked to the admin role in `member_roles`.
- User can access guild admin settings after refresh.
