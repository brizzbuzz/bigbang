---
description: Open a draft PR using the git-commit-and-draft-pr skill
---

Load the `git-commit-and-draft-pr` skill and apply it to this request.

Use that skill instead of ad hoc `gh pr create` steps.

Always create the PR in draft mode unless the user explicitly asks for ready-for-review.

Use the skill's PR body template exactly as clean rendered Markdown.
Do not include shell construction text like `$(cat <<'EOF'`, `EOF`, or `)` in the PR body.
Do not post the PR body template as a GitHub comment unless the user explicitly asks for that comment.

Apply it to this request:

$ARGUMENTS
