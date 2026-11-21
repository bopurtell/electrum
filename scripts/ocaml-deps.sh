#!/usr/bin/env bash
#
# The OCaml layer of the bootstrap: the opam switch and this repository's opam
# dependencies. Everything else needs dune, and dune needs this, so it is plain
# shell with no dependency on the repository having been built.
#
# The switch is shared with every other Hardcaml checkout on the machine, so this
# script's own default is to check and print commands; changes happen only with
# --install. ./scripts/bootstrap.sh only passes it with --install-deps.
#
# `opam install . --deps-only` is deliberately not used, not even as a dry run:
# against a shared switch it proposes recompiling packages other repositories
# depend on. Dependencies are checked and installed by name instead.
#
# ASIC and Workbench themselves are installed to a project-local prefix by
# install-tools.py, never by this script.

set -euo pipefail

readonly EX_PREREQ=2

SWITCH="${OPAM_SWITCH:-5.2.0+ox}"
readonly SWITCH
readonly OX_REPOSITORY=git+https://github.com/oxcaml/opam-repository.git

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly repo_root
readonly opam_file="$repo_root/electrum.opam"

install=0
tool_deps=0

usage() {
    cat <<'USAGE'
Usage: scripts/ocaml-deps.sh [--install] [--tool-deps]

Checks that the OxCaml opam switch exists and has this repository's opam
dependencies. Changes nothing unless --install is given.

Options:
  --install    Create the switch if it is missing (about 30 minutes),
               install missing published packages, then verify them.
  --tool-deps  Include dependencies needed to build/test the normal local
               ASIC and Workbench selection from the sibling checkouts.
  -h, --help   Show this message.

Environment:
  OPAM_SWITCH  Switch to use. Default: 5.2.0+ox

Exit codes:
  0  switch present with every dependency
  2  something is missing or opam failed; the commands that fix it are printed
USAGE
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --install) install=1 ;;
        --tool-deps) tool_deps=1 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
    shift
done

step() { printf '\n==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }

die() {
    local code=$1
    shift
    printf '\nerror: %s\n' "$1" >&2
    shift
    local line
    for line in "$@"; do printf '       %s\n' "$line" >&2; done
    exit "$code"
}

step "Checking the OCaml layer (opam switch $SWITCH)"

command -v opam >/dev/null 2>&1 || die "$EX_PREREQ" "opam is not installed" \
    "Install it with your package manager (apt install opam), then run:" \
    "  opam init --bare --no-setup"

opam var root >/dev/null 2>&1 || die "$EX_PREREQ" "opam is not initialised" \
    "Run: opam init --bare --no-setup"

if ! opam switch list --short 2>/dev/null | grep -qx "$SWITCH"; then
    create=(opam switch create "$SWITCH" "ocaml-variants.5.2.0+ox"
            --repos "ox=$OX_REPOSITORY,default" --yes)
    if [[ $install -eq 0 ]]; then
        die "$EX_PREREQ" "opam switch '$SWITCH' does not exist" \
            "Rerun with --install to create it (about 30 minutes), or run:" \
            "  ${create[*]}"
    fi
    info "creating switch $SWITCH; this takes about 30 minutes"
    "${create[@]}"
fi

version=$(opam exec --switch="$SWITCH" -- ocamlc -version)
case $version in
    5.2.0+ox*) info "OCaml $version" ;;
    *) die "$EX_PREREQ" "switch '$SWITCH' has OCaml $version, expected 5.2.0+ox" ;;
esac

# Include test and developer dependencies but not documentation. Read the
# committed ASIC manifest, not the sibling checkout's potentially dirty bytes.
depends() {
    opam show --just-file --raw -f depends "$1"
}

asic_depends() (
    manifest=$(mktemp "${TMPDIR:-/tmp}/electrum-asic.XXXXXXXX.opam") || exit
    trap 'rm -f -- "$manifest"' EXIT
    git -C "$1" show "$2:hardcaml_asic.opam" > "$manifest" && depends "$manifest"
)

dependencies=$(depends "$opam_file") || die "$EX_PREREQ" "could not read depends from $opam_file"
if [[ $tool_deps -eq 1 ]]; then
    workspace=$(dirname "$repo_root")
    revision=$(python3 "$repo_root/scripts/install-tools.py" --print-asic-revision) ||
        die "$EX_PREREQ" "could not read the normal ASIC source selection"
    asic_deps=$(asic_depends "$workspace/hardcaml_asic" "$revision") ||
        die "$EX_PREREQ" "could not read ASIC dependencies at $revision" \
            "Fetch the locked commit into $workspace/hardcaml_asic."
    for pkg in hardcaml_workbench hardcaml_workbench_provider; do
        manifest="$workspace/silver/$pkg.opam"
        workbench_deps=$(depends "$manifest") || die "$EX_PREREQ" "could not read depends from $manifest"
        dependencies+=$'\n'"$workbench_deps"
    done
    dependencies+=$'\n'"$asic_deps"
fi
mapfile -t wanted < <(awk -F'"' '
    NF > 1 && !/with-doc/ && $2 !~ /^(hardcaml_asic|hardcaml_workbench|hardcaml_workbench_provider)$/ && !seen[$2]++ { print $2 }
' <<< "$dependencies")
[[ ${#wanted[@]} -gt 0 ]] || die "$EX_PREREQ" "no published OCaml dependencies found"

# Fills [missing] with the wanted packages the switch does not have.
#
# Careful: opam's exit status is checked rather than dropped, and its stderr is kept.
# `opam list` exits nonzero with EMPTY stdout when it fails at all (a stale lock, an
# unreadable root, a switch that vanished mid-run), and empty stdout read as data means
# "no package is installed" -- which would report every dependency as missing and send
# the reader off to reinstall a switch that was fine. An opam failure is reported as an
# opam failure instead.
find_missing() {
    local listing status pkg
    listing=$(opam list --switch="$SWITCH" --installed --short "${wanted[@]}" 2>&1) || {
        status=$?
        die "$EX_PREREQ" "could not list installed packages in switch '$SWITCH'" \
            "opam exited $status and said:" "$listing"
    }
    mapfile -t installed <<<"$listing"
    missing=()
    for pkg in "${wanted[@]}"; do
        printf '%s\n' "${installed[@]}" | grep -qx "$pkg" || missing+=("$pkg")
    done
}

find_missing

# Do not accept Electrum's older Dune floor for a local Silver build.
check_dune_version() {
    dune_version=$(opam exec --switch="$SWITCH" -- dune --version) ||
        die "$EX_PREREQ" "could not read the installed Dune version"
    opam admin compare-versions "$dune_version" --geq 3.22
}

if [[ $tool_deps -eq 1 ]]; then
    for i in "${!missing[@]}"; do
        if [[ ${missing[$i]} == dune ]]; then
            missing[$i]='dune>=3.22'
        fi
    done
    if printf '%s\n' "${installed[@]}" | grep -qx dune && ! check_dune_version; then
        missing+=('dune>=3.22')
    fi
fi

if [[ ${#missing[@]} -gt 0 ]]; then
    if [[ $install -eq 0 ]]; then
        printf -v install_args ' %q' "${missing[@]}"
        die "$EX_PREREQ" "missing opam packages: ${missing[*]}" \
            "Rerun with --install (preserving --tool-deps if used), or run:" \
            "  opam install --switch=$SWITCH$install_args"
    fi

    info "installing ${missing[*]}"
    opam install --switch="$SWITCH" --yes "${missing[@]}"

    # Read the switch back rather than trusting the exit status: opam can report
    # success having installed less than it was asked for, and a dependency that is
    # still absent here becomes a "Library not found" from dune much later.
    requested=("${missing[@]}")
    find_missing
    if [[ $tool_deps -eq 1 ]]; then
        check_dune_version ||
            die "$EX_PREREQ" "Silver requires Dune 3.22 or newer (found $dune_version)"
    fi
    [[ ${#missing[@]} -eq 0 ]] || die "$EX_PREREQ" \
        "still missing after installing ${requested[*]}: ${missing[*]}" \
        "opam reported success. Install one of them on its own to see why:" \
        "  opam install --switch=$SWITCH ${missing[0]}"
fi

info "all ${#wanted[@]} opam dependencies installed"
