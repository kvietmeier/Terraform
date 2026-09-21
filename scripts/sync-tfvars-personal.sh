#!/usr/bin/env bash
# Weekly (or anytime) backup of real tfvars → private personal repo.
#
# Walks the entire Terraform tree, copies every real *.tfvars file into
# ~/github/personal/terraform-tfvars/ with the same relative path.
# Public users keep *.tfvars.example in this repo; SG/subnet IDs stay private.
#
# Usage (default = full tree, like your Windows weekly job):
#   ./scripts/sync-tfvars-personal.sh push
#   ./scripts/sync-tfvars-personal.sh pull
#   ./scripts/sync-tfvars-personal.sh push aws/ec2          # optional scope
#
# Env:
#   PERSONAL_TFVARS  mirror root (default: ~/github/personal/terraform-tfvars)
#
# Windows twin lived in system-tools (TFvarsBackup.ps1); .ps1 sync in this repo is not supported.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MIRROR="${PERSONAL_TFVARS:-$HOME/github/personal/terraform-tfvars}"
MODE="${1:-}"
SCOPE="${2:-}"

usage() {
  sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

[[ "$MODE" == "push" || "$MODE" == "pull" ]] || usage
mkdir -p "$MIRROR"

# Real values only — skip examples and terraform internals
collect_tfvars() {
  local root="$1"
  find "$root" -type f \( -name '*.tfvars' -o -name '*.tfvars.json' \) \
    ! -name '*.example' \
    ! -name '*.tfvars.example' \
    ! -path '*/.terraform/*' \
    ! -path '*/secrets/*' \
    | sort
}

case "$MODE" in
  push)
    search="$REPO_ROOT"
    [[ -n "$SCOPE" ]] && search="$REPO_ROOT/$SCOPE"
    count=0
    while IFS= read -r src; do
      [[ -z "$src" ]] && continue
      rel="${src#"$REPO_ROOT"/}"
      dest="$MIRROR/$rel"
      mkdir -p "$(dirname "$dest")"
      cp -p "$src" "$dest"
      echo "push  $rel"
      count=$((count + 1))
    done < <(collect_tfvars "$search")
    echo "Pushed $count file(s) → $MIRROR"
    echo "Then:  cd ~/github/personal && git add terraform-tfvars && git commit -m 'tfvars backup' && git push"
    ;;
  pull)
    search="$MIRROR"
    [[ -n "$SCOPE" ]] && search="$MIRROR/$SCOPE"
    [[ -d "$search" ]] || { echo "No mirror at $search" >&2; exit 1; }
    count=0
    while IFS= read -r src; do
      [[ -z "$src" ]] && continue
      rel="${src#"$MIRROR"/}"
      dest="$REPO_ROOT/$rel"
      mkdir -p "$(dirname "$dest")"
      cp -p "$src" "$dest"
      echo "pull  $rel"
      count=$((count + 1))
    done < <(collect_tfvars "$search")
    echo "Restored $count file(s) → local stacks (gitignored in public repo)"
    ;;
esac
