#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Commitlint setup
setup_commitlint() {
    local target_dir="$1"
    local templates_dir="$2"

    info "\nSetting up commit conventions..."

    # Copy templates
    cp "$templates_dir/COMMIT_SCOPES.yml" "$target_dir/.claude/"
    cp "$templates_dir/.commitlintrc.yml" "$target_dir/"

    # Detect project type and suggest scopes
    local DETECTED_SCOPES=""

    # Check for common directories/files to suggest scopes
    [[ -d "$target_dir/api" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - api\n"
    [[ -d "$target_dir/auth" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - auth\n"
    [[ -d "$target_dir/components" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - components\n"
    [[ -d "$target_dir/pages" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - pages\n"
    [[ -d "$target_dir/models" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - models\n"
    [[ -d "$target_dir/routes" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - routes\n"
    [[ -d "$target_dir/services" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - services\n"
    [[ -d "$target_dir/utils" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - utils\n"
    [[ -f "$target_dir/Dockerfile" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - docker\n"
    [[ -d "$target_dir/k8s" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - k8s\n"
    [[ -d "$target_dir/terraform" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - terraform\n"

    if [[ -n "$DETECTED_SCOPES" ]]; then
        info "Detected project scopes:"
        echo -e "$DETECTED_SCOPES"

        # Add to COMMIT_SCOPES.yml after "# Features" comment
        # Using awk to insert after the Features line
        awk -v scopes="$DETECTED_SCOPES" '
            /# Features/ {
                print
                printf "%s", scopes
                next
            }
            { print }
        ' "$target_dir/.claude/COMMIT_SCOPES.yml" > "$target_dir/.claude/COMMIT_SCOPES.yml.tmp"
        mv "$target_dir/.claude/COMMIT_SCOPES.yml.tmp" "$target_dir/.claude/COMMIT_SCOPES.yml"
    fi

    # Check if package.json exists for npm setup
    if [[ -f "$target_dir/package.json" ]]; then
        warn "To complete commitlint setup:"
        warn "1. Install commitlint:"
        warn "   npm install --save-dev @commitlint/cli @commitlint/config-conventional"
        warn "2. Add to package.json scripts:"
        warn '   "commitlint": "commitlint --edit"'
        warn "3. Configure git hook:"
        warn "   npx husky add .husky/commit-msg 'npx commitlint --edit \$1'"
    fi

    # For Python projects
    if [[ -f "$target_dir/pyproject.toml" ]]; then
        warn "To complete commitlint setup:"
        warn "1. Install commitizen:"
        warn "   pip install commitizen"
        warn "2. Add to pyproject.toml:"
        warn "   [tool.commitizen]"
        warn "   name = 'cz_conventional_commits'"
        warn "3. Use 'cz commit' for interactive commits"
    fi

    info "  ✓ Commit conventions configured"
    warn "Remember to customize scopes in .claude/COMMIT_SCOPES.yml"
}
