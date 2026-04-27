#!/usr/bin/env bash

set -euo pipefail

WORKSPACE_ROOT="/home/inc/projects/tagd-workspace"
PROJECTS_ROOT="/home/inc/projects"
SANDBOX_ROOT="/home/inc/sandbox"
WORKTREE_REPOS=(
	"tagd"
	"tagd-simple-english"
	"tagr"
	"tagd-nlp"
	"tagd-ai"
)

usage() {
	printf 'usage: %s <add|remove> <feature>\n' "${0##*/}" >&2
	exit 64
}

die() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

prune_repo_worktrees() {
	local repo_path="$1"
	git -C "$repo_path" worktree prune >/dev/null 2>&1 || true
}

require_clean_dev_repo() {
	local repo_path="$1"
	local repo_name="$2"
	local branch

	branch="$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)"
	[[ "$branch" == "dev" ]] || die "$repo_name must have dev checked out; found $branch"

	if [[ -n "$(git -C "$repo_path" status --porcelain)" ]]; then
		die "$repo_name is not clean"
	fi
}

validate_feature() {
	local feature="$1"

	[[ -n "$feature" ]] || die "feature name is required"
	[[ "$feature" != */* ]] || die "feature must not contain /"
	[[ "$feature" =~ ^[A-Za-z0-9._-]+$ ]] || die "feature contains unsupported characters"
}

ensure_missing_path() {
	local path="$1"
	[[ ! -e "$path" ]] || die "target path already exists: $path"
}

ensure_existing_path() {
	local path="$1"
	[[ -e "$path" ]] || die "target path not found: $path"
}

branch_exists() {
	local repo_path="$1"
	local branch_name="$2"
	git -C "$repo_path" show-ref --verify --quiet "refs/heads/$branch_name"
}

worktree_exists() {
	local repo_path="$1"
	local worktree_path="$2"
	git -C "$repo_path" worktree list --porcelain |
		awk '/^worktree / { print substr($0, 10) }' |
		grep -Fxq "$worktree_path"
}

add_repo_worktree() {
	local source_repo="$1"
	local target_path="$2"
	local branch_name="$3"
	local repo_name="$4"

	prune_repo_worktrees "$source_repo"
	ensure_missing_path "$target_path"
	mkdir -p "$(dirname "$target_path")"
	if git -C "$source_repo" show-ref --verify --quiet "refs/heads/$branch_name"; then
		die "branch already exists in $repo_name: $branch_name"
	fi
	git -C "$source_repo" worktree add -b "$branch_name" "$target_path" dev
}

remove_repo_worktree() {
	local source_repo="$1"
	local target_path="$2"
	local branch_name="$3"
	local repo_name="$4"

	prune_repo_worktrees "$source_repo"
	worktree_exists "$source_repo" "$target_path" ||
		die "worktree not registered in $repo_name: $target_path"
	git -C "$source_repo" worktree remove "$target_path"
	prune_repo_worktrees "$source_repo"
	branch_exists "$source_repo" "$branch_name" ||
		die "branch not found in $repo_name after worktree removal: $branch_name"
	git -C "$source_repo" branch -D "$branch_name"
}

preflight_add_agent_tree() {
	local agent="$1"
	local feature="$2"
	local branch_name="$agent/$feature"
	local workspace_target="$SANDBOX_ROOT/$agent/tagd-workspace"
	local repo
	local source_repo
	local repo_target

	prune_repo_worktrees "$WORKSPACE_ROOT"
	ensure_missing_path "$workspace_target"
	if git -C "$WORKSPACE_ROOT" show-ref --verify --quiet "refs/heads/$branch_name"; then
		die "branch already exists in tagd-workspace: $branch_name"
	fi

	for repo in "${WORKTREE_REPOS[@]}"; do
		source_repo="$PROJECTS_ROOT/$repo"
		prune_repo_worktrees "$source_repo"
		[[ -d "$source_repo" ]] || die "configured repo does not exist: $source_repo"
		git -C "$source_repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
			die "configured repo is not a git repository: $source_repo"
		require_clean_dev_repo "$source_repo" "$repo"
		repo_target="$workspace_target/$repo"
		ensure_missing_path "$repo_target"
		if branch_exists "$source_repo" "$branch_name"; then
			die "branch already exists in $repo: $branch_name"
		fi
	done
}

add_agent_tree() {
	local agent="$1"
	local feature="$2"
	local branch_name="$agent/$feature"
	local workspace_target="$SANDBOX_ROOT/$agent/tagd-workspace"
	local repo
	local source_repo
	local repo_target

	add_repo_worktree "$WORKSPACE_ROOT" "$workspace_target" "$branch_name" "tagd-workspace"

	for repo in "${WORKTREE_REPOS[@]}"; do
		source_repo="$PROJECTS_ROOT/$repo"
		repo_target="$workspace_target/$repo"
		add_repo_worktree "$source_repo" "$repo_target" "$branch_name" "$repo"
	done
}

preflight_remove_agent_tree() {
	local agent="$1"
	local feature="$2"
	local branch_name="$agent/$feature"
	local workspace_target="$SANDBOX_ROOT/$agent/tagd-workspace"
	local repo
	local source_repo
	local repo_target

	prune_repo_worktrees "$WORKSPACE_ROOT"
	ensure_existing_path "$workspace_target"
	worktree_exists "$WORKSPACE_ROOT" "$workspace_target" ||
		die "worktree not registered in tagd-workspace: $workspace_target"
	branch_exists "$WORKSPACE_ROOT" "$branch_name" ||
		die "branch not found in tagd-workspace: $branch_name"

	for repo in "${WORKTREE_REPOS[@]}"; do
		source_repo="$PROJECTS_ROOT/$repo"
		prune_repo_worktrees "$source_repo"
		[[ -d "$source_repo" ]] || die "configured repo does not exist: $source_repo"
		git -C "$source_repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
			die "configured repo is not a git repository: $source_repo"
		require_clean_dev_repo "$source_repo" "$repo"
		repo_target="$workspace_target/$repo"
		ensure_existing_path "$repo_target"
		worktree_exists "$source_repo" "$repo_target" ||
			die "worktree not registered in $repo: $repo_target"
		branch_exists "$source_repo" "$branch_name" ||
			die "branch not found in $repo: $branch_name"
	done
}

remove_agent_tree() {
	local agent="$1"
	local feature="$2"
	local branch_name="$agent/$feature"
	local workspace_target="$SANDBOX_ROOT/$agent/tagd-workspace"
	local repo
	local source_repo
	local repo_target

	for repo in "${WORKTREE_REPOS[@]}"; do
		source_repo="$PROJECTS_ROOT/$repo"
		repo_target="$workspace_target/$repo"
		remove_repo_worktree "$source_repo" "$repo_target" "$branch_name" "$repo"
	done

	remove_repo_worktree "$WORKSPACE_ROOT" "$workspace_target" "$branch_name" "tagd-workspace"
}

main() {
	local command="${1:-}"
	local feature="${2:-}"

	[[ $# -eq 2 ]] || usage
	validate_feature "$feature"
	[[ "$command" == "add" || "$command" == "remove" ]] || usage

	[[ -d "$WORKSPACE_ROOT" ]] || die "workspace root not found: $WORKSPACE_ROOT"
	require_clean_dev_repo "$WORKSPACE_ROOT" "tagd-workspace"

	case "$command" in
		add)
			preflight_add_agent_tree "codex" "$feature"
			preflight_add_agent_tree "claude" "$feature"
			add_agent_tree "codex" "$feature"
			add_agent_tree "claude" "$feature"
			;;
		remove)
			preflight_remove_agent_tree "codex" "$feature"
			preflight_remove_agent_tree "claude" "$feature"
			remove_agent_tree "codex" "$feature"
			remove_agent_tree "claude" "$feature"
			;;
	esac
}

main "$@"
