#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Pre-commit detection and setup
setup_precommit() {
    local target_dir="$1"
    local templates_dir="$2"

    if [[ -f "$target_dir/.pre-commit-config.yaml" ]]; then
        echo -e "\n${BLUE}Pre-commit hooks detected${NC}"
        echo -e "${GREEN}Enable commit validation workflow? (y/n)${NC}"
        read -r ENABLE_PRECOMMIT

        if [[ "$ENABLE_PRECOMMIT" == "y" ]]; then
            # Copy checklist
            cp "$templates_dir/COMMIT_CHECKLIST.md" "$target_dir/.claude/"

            # Customize based on language
            local PRECOMMIT_CMD="pre-commit run --all-files"
            local VERIFY_CMDS=""
            local MAIN_LANGUAGE=""

            # Detect main language
            if [[ -f "$target_dir/pyproject.toml" ]] || [[ -f "$target_dir/setup.py" ]]; then
                MAIN_LANGUAGE="python"
            elif [[ -f "$target_dir/package.json" ]]; then
                MAIN_LANGUAGE="javascript"
            elif [[ -f "$target_dir/go.mod" ]]; then
                MAIN_LANGUAGE="go"
            fi

            case $MAIN_LANGUAGE in
                python)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="# Type checking\n$TEST_COMMAND\n$LINT_COMMAND"

                    # Enable Python hooks in pre-commit config if not exists
                    if [[ ! -f "$target_dir/.pre-commit-config.yaml" ]]; then
                        cp "$templates_dir/.pre-commit-config.yaml" "$target_dir/"
                        # Uncomment Python hooks
                        safe_sed "$target_dir/.pre-commit-config.yaml" 's/# - repo:.*ruff/- repo:/'
                        safe_sed "$target_dir/.pre-commit-config.yaml" 's/#   /  /'
                    fi
                    ;;
                javascript)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="$TEST_COMMAND\n$LINT_COMMAND\n$BUILD_COMMAND"

                    # Enable JS hooks
                    if [[ ! -f "$target_dir/.pre-commit-config.yaml" ]]; then
                        cp "$templates_dir/.pre-commit-config.yaml" "$target_dir/"
                        # Uncomment JS hooks
                        safe_sed "$target_dir/.pre-commit-config.yaml" 's/# - repo:.*prettier/- repo:/'
                        safe_sed "$target_dir/.pre-commit-config.yaml" 's/#   /  /'
                    fi
                    ;;
                go)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="$TEST_COMMAND\n$LINT_COMMAND\n$BUILD_COMMAND"
                    ;;
                *)
                    VERIFY_CMDS="$TEST_COMMAND\n$LINT_COMMAND"
                    ;;
            esac

            # Replace placeholders in checklist
            safe_sed "$target_dir/.claude/COMMIT_CHECKLIST.md" "s|{{PRE_COMMIT_COMMAND}}|$PRECOMMIT_CMD|g"
            safe_sed "$target_dir/.claude/COMMIT_CHECKLIST.md" "s|{{VERIFICATION_COMMANDS}}|$VERIFY_CMDS|g"

            info "  ✓ Commit validation workflow enabled"
            warn "Remember to run 'pre-commit install' to set up hooks"
        fi
    else
        echo -e "\n${YELLOW}No pre-commit configuration found. Skipping validation setup.${NC}"
        echo -e "${YELLOW}To enable later, create .pre-commit-config.yaml and re-run installer${NC}"
    fi
}
