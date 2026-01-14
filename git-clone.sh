#!/usr/bin/env bash
set -euo pipefail

show_help() {
    cat <<-EOF
Usage: $(basename "$0") [--branch <branch>] [--dir <dir>] <repo>

Options:
    -b, --branch <branch>   Clone specific branch (uses --single-branch)
    -d, --dir <dir>         Destination directory for clone
    -h, --help              Show this help
EOF
}

branch=""
dir=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--branch)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --branch requires an argument" >&2
                exit 1
            fi
            branch="$2"
            shift 2
            ;;
        -d|--dir)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --dir requires an argument" >&2
                exit 1
            fi
            dir="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

if [[ $# -lt 1 ]]; then
    show_help
    exit 1
fi

repo="$1"
if [[ $# -gt 1 ]]; then
    echo "Error: unexpected positional argument: ${2}" >&2
    show_help
    exit 1
fi

cmd=(git clone)
if [[ -n "$branch" ]]; then
    cmd+=(--branch "$branch" --single-branch)
fi
cmd+=("$repo")
if [[ -n "$dir" ]]; then
    cmd+=("$dir")
fi

echo "Running: ${cmd[*]}"
exec "${cmd[@]}"
