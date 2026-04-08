---
description: Create a signed conventional commit and open a draft PR using the git-commit-and-draft-pr skill
---

Load the `git-commit-and-draft-pr` skill and apply it to this request.

Always create the PR in draft mode unless the user explicitly asks for ready-for-review.

Use the skill's PR body template exactly as clean rendered Markdown.
Do not include shell construction text like `$(cat <<'EOF'`, `EOF`, or `)` in the PR body.

Apply it to this request:

$ARGUMENTS
