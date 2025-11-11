#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Code quality standards setup
setup_quality_standards() {
    local target_dir="$1"
    local templates_dir="$2"

    info "\nSetting up code quality standards..."

    # Copy standards template
    cp "$templates_dir/CODE_QUALITY_STANDARDS.md" "$target_dir/.claude/"

    # Customize based on language
    local MIN_COVERAGE="80"
    local MAIN_LANGUAGE=""

    # Detect main language
    if [[ -f "$target_dir/pyproject.toml" ]] || [[ -f "$target_dir/setup.py" ]]; then
        MAIN_LANGUAGE="python"
    elif [[ -f "$target_dir/package.json" ]]; then
        # Check if TypeScript
        if [[ -f "$target_dir/tsconfig.json" ]]; then
            MAIN_LANGUAGE="typescript"
        else
            MAIN_LANGUAGE="javascript"
        fi
    elif [[ -f "$target_dir/go.mod" ]]; then
        MAIN_LANGUAGE="go"
    elif [[ -f "$target_dir/Cargo.toml" ]]; then
        MAIN_LANGUAGE="rust"
    else
        MAIN_LANGUAGE="generic"
    fi

    case $MAIN_LANGUAGE in
        python)
            safe_sed "$target_dir/.claude/CODE_QUALITY_STANDARDS.md" 's/{{MAIN_LANGUAGE}}/Python/g'
            # Remove JS-specific sections (everything between ### JavaScript/TypeScript and ### Python)
            awk '/### JavaScript\/TypeScript/{flag=1} /### Python/{flag=0; print; next} !flag' \
                "$target_dir/.claude/CODE_QUALITY_STANDARDS.md" > "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.tmp"
            mv "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.tmp" "$target_dir/.claude/CODE_QUALITY_STANDARDS.md"
            ;;
        javascript|typescript)
            safe_sed "$target_dir/.claude/CODE_QUALITY_STANDARDS.md" "s/{{MAIN_LANGUAGE}}/$MAIN_LANGUAGE/g"
            # Remove Python-specific sections (everything between ### Python and ## Dead Code Removal)
            awk '/### Python/{flag=1} /## Dead Code Removal/{flag=0; print; next} !flag' \
                "$target_dir/.claude/CODE_QUALITY_STANDARDS.md" > "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.tmp"
            mv "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.tmp" "$target_dir/.claude/CODE_QUALITY_STANDARDS.md"
            ;;
        *)
            safe_sed "$target_dir/.claude/CODE_QUALITY_STANDARDS.md" "s/{{MAIN_LANGUAGE}}/$MAIN_LANGUAGE/g"
            ;;
    esac

    safe_sed "$target_dir/.claude/CODE_QUALITY_STANDARDS.md" "s/{{MIN_COVERAGE}}/$MIN_COVERAGE/g"

    info "  ✓ Code quality standards configured for $MAIN_LANGUAGE"
}
