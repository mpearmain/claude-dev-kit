#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

detect_project_name() {
    local dir="$1"
    if [[ -d "$dir/.git" ]]; then
        basename "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo "$dir")"
    else
        basename "$dir"
    fi
}

detect_language() {
    local dir="$1"
    [[ -f "$dir/pyproject.toml" ]] && echo "python" && return
    [[ -f "$dir/package.json" ]] && echo "javascript" && return
    [[ -f "$dir/go.mod" ]] && echo "go" && return
    [[ -f "$dir/Cargo.toml" ]] && echo "rust" && return
    [[ -f "$dir/main.tf" ]] || [[ -d "$dir/modules" ]] && echo "terraform" && return
    echo "generic"
}

detect_package_manager() {
    local dir="$1"
    local lang="$2"

    case "$lang" in
        python)
            [[ -f "$dir/uv.lock" ]] && echo "uv" && return
            [[ -f "$dir/poetry.lock" ]] && echo "poetry" && return
            echo "pip"
            ;;
        javascript)
            [[ -f "$dir/pnpm-lock.yaml" ]] && echo "pnpm" && return
            [[ -f "$dir/yarn.lock" ]] && echo "yarn" && return
            echo "npm"
            ;;
        *)
            echo "none"
            ;;
    esac
}

detect_project_context() {
    local target_dir="$1"

    info "Detecting project context..."

    # Detect project name from directory or git
    PROJECT_NAME=$(detect_project_name "$target_dir")

    # Python detection
    if [[ -f "$target_dir/pyproject.toml" ]]; then
        info "  ✓ Detected Python project"
        MAIN_SRC_DIR="src"

        if [[ -f "$target_dir/uv.lock" ]]; then
            info "  ✓ Detected uv package manager"
            TEST_COMMAND="uv run pytest"
            LINT_COMMAND="uv run ruff check"
            BUILD_COMMAND="uv build"
            SETUP_COMMAND="uv sync"
        elif [[ -f "$target_dir/poetry.lock" ]]; then
            info "  ✓ Detected Poetry package manager"
            TEST_COMMAND="poetry run pytest"
            LINT_COMMAND="poetry run ruff check"
            BUILD_COMMAND="poetry build"
            SETUP_COMMAND="poetry install"
        else
            TEST_COMMAND="pytest"
            LINT_COMMAND="ruff check"
            BUILD_COMMAND="python -m build"
            SETUP_COMMAND="pip install -e ."
        fi
        return
    fi

    # Node.js detection
    if [[ -f "$target_dir/package.json" ]]; then
        info "  ✓ Detected Node.js project"
        MAIN_SRC_DIR="src"

        if [[ -f "$target_dir/pnpm-lock.yaml" ]]; then
            info "  ✓ Detected pnpm package manager"
            TEST_COMMAND="pnpm test"
            LINT_COMMAND="pnpm run lint"
            BUILD_COMMAND="pnpm run build"
            SETUP_COMMAND="pnpm install"
        elif [[ -f "$target_dir/yarn.lock" ]]; then
            info "  ✓ Detected Yarn package manager"
            TEST_COMMAND="yarn test"
            LINT_COMMAND="yarn lint"
            BUILD_COMMAND="yarn build"
            SETUP_COMMAND="yarn install"
        else
            TEST_COMMAND="npm test"
            LINT_COMMAND="npm run lint"
            BUILD_COMMAND="npm run build"
            SETUP_COMMAND="npm install"
        fi
        return
    fi

    # Go detection
    if [[ -f "$target_dir/go.mod" ]]; then
        info "  ✓ Detected Go project"
        MAIN_SRC_DIR="."
        TEST_COMMAND="go test ./..."
        LINT_COMMAND="golangci-lint run"
        BUILD_COMMAND="go build ./..."
        SETUP_COMMAND="go mod download"
        return
    fi

    # Rust detection
    if [[ -f "$target_dir/Cargo.toml" ]]; then
        info "  ✓ Detected Rust project"
        MAIN_SRC_DIR="src"
        TEST_COMMAND="cargo test"
        LINT_COMMAND="cargo clippy"
        BUILD_COMMAND="cargo build"
        SETUP_COMMAND="cargo fetch"
        return
    fi

    # Terraform detection
    if [[ -f "$target_dir/main.tf" ]] || [[ -d "$target_dir/modules" ]]; then
        info "  ✓ Detected Terraform project"
        MAIN_SRC_DIR="modules"
        TEST_COMMAND="terraform validate"
        LINT_COMMAND="tflint"
        BUILD_COMMAND="terraform plan"
        SETUP_COMMAND="terraform init"
        return
    fi

    # Defaults if nothing detected
    warn "  ⚠ Could not detect project type - using generic defaults"
    MAIN_SRC_DIR="src"
    TEST_COMMAND="make test"
    LINT_COMMAND="make lint"
    BUILD_COMMAND="make build"
    SETUP_COMMAND="make install"
}

# Check for optional tools
check_optional_tools() {
    # Check for Gemini CLI (optional enhanced analysis)
    if command -v gemini &> /dev/null; then
        info "  ✓ Detected Gemini CLI (optional enhanced analysis available)"
    fi
}
