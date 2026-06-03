#!/usr/bin/env bash
# Fail if any tracked gitlink (submodule-style commit pointer) is not at the
# tip of its sibling repo's DEFAULT branch. This is what keeps the workspace
# pointers from silently drifting behind merged work.
#
# It compares the committed gitlink SHA against `git ls-remote <url> HEAD`, the
# remote's default-branch tip -- so it is correct for repos whose default is not
# `main` (e.g. ada_feeding -> ros2-devel) without any per-repo configuration.
#
# No sibling checkout is required (uses ls-remote), so it is cheap to run in CI.
# Sibling URLs are derived by convention: github.com/personalrobotics/<dir>.
#
# Usage: scripts/check_gitlink_freshness.sh
# Exit:  0 = all current; 1 = drift or lookup failure (fail closed).
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ORG_URL="https://github.com/personalrobotics"
stale=0
errors=0

printf "%-22s %-12s %-12s %s\n" "GITLINK" "RECORDED" "REMOTE-TIP" "STATUS"
printf -- "%.0s-" {1..64}; printf "\n"

# Each gitlink: mode 160000, "<sha> <path>".
while read -r sha path; do
    url="$ORG_URL/$(basename "$path")"
    tip="$(git ls-remote "$url" HEAD 2>/dev/null | awk 'NR==1{print $1}')"
    if [ -z "$tip" ]; then
        printf "%-22s %-12s %-12s %s\n" "$path" "${sha:0:11}" "??" "LOOKUP-FAILED"
        errors=1
        continue
    fi
    if [ "$sha" = "$tip" ]; then
        printf "%-22s %-12s %-12s %s\n" "$path" "${sha:0:11}" "${tip:0:11}" "ok"
    else
        printf "%-22s %-12s %-12s %s\n" "$path" "${sha:0:11}" "${tip:0:11}" "STALE"
        stale=1
    fi
done < <(git ls-tree -r HEAD | awk '$2=="commit"{print $3, $4}')

echo
if [ "$errors" -ne 0 ]; then
    echo "ERROR: could not resolve one or more sibling default branches (see LOOKUP-FAILED)."
    exit 1
fi
if [ "$stale" -ne 0 ]; then
    echo "Gitlinks are behind their default-branch tips. To fix, for each STALE repo:"
    echo "  (cd <repo> && git fetch origin && git checkout \"\$(git rev-parse origin/HEAD)\")"
    echo "  git add <repo> && git commit"
    exit 1
fi
echo "All gitlinks are at their default-branch tips."
