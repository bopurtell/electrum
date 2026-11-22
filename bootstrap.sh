#!/usr/bin/env bash
#
# Explicit environment preparation for a fresh clone or worktree.
#
#   1. OCaml layer   scripts/ocaml-deps.sh                     switch + opam packages
#   2. Local tools  scripts/install-tools.py                 ASIC + Silver
#   3. Flow layer   hardcaml-asic-flow provision              managed Python, PDK,
#                                                             TT tools, LibreLane image
#   4. Shell layer  source scripts/env.sh                     (printed; a script
#                                                               cannot do it)
#
# --check only validates prerequisites and an already-installed provider; it
# never compiles one just to answer a question about Python and the PDK.
#
# Environment and local release commands:
#
#   ./bootstrap.sh               select local tools and prepare flow collateral
#   ./bootstrap.sh --check       verify every layer and change nothing
#   ./bootstrap.sh --tools-only  install captured ASIC + Workbench locally
#
# Explicit --install-deps installs missing packages into the opam switch, shared with
# every other Hardcaml checkout on the machine. Use --check to see what is missing
# without touching the switch. ASIC and Workbench are never installed there.
#
# It prepares an environment. It does not stage a design, emit a bundle, or start
# hardening: that is ./asic_support/flow.sh, and it is always an explicit command.
#
# See docs/environment.md; the flow itself is docs/flow.md.

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly repo_root

usage() {
    cat <<'USAGE'
Usage: ./bootstrap.sh [options]

With no options: prepares the pinned local ASIC and Silver tools, provisions
the physical toolchain with managed Python 3.11, and configures the project
for plain Silver. Does not launch a flow.

Options:
  --check          Validate every layer and change nothing. Missing packages are
                   named with the command that installs them.
  --refresh        Revalidate and refresh setup even if nothing appears to have changed.
  --offline        Reuse the flow environment; fetch and install nothing.
  --no-container   Skip the Docker/Podman prerequisite. The pinned LibreLane
                   image is then not resolved either; supply a native LibreLane.
  --legacy-project Use the older Tiny Tapeout bootstrap to stage the legacy P0
                   project. The normal Electrum chip does not use it.
  --install-deps   Explicitly install missing published Electrum dependencies.
  --tools-only     Install captured ASIC + Workbench locally, then exit. No EDA
                   provisioning or shared-switch writes.
  -h, --help       Show this message.

Then:
  source scripts/env.sh    every new shell
  ./asic_support/flow.sh           the ASIC flow (--help first; the bare form hardens)
USAGE
}

check=0
refresh=0
install_deps=0
offline=0
no_container=0
legacy_project=0
tools_only=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --check) check=1 ;;
        --refresh) refresh=1 ;;
        --install-deps) install_deps=1 ;;
        --offline) offline=1 ;;
        --no-container) no_container=1 ;;
        --legacy-project) legacy_project=1 ;;
        --tools-only) tools_only=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "bootstrap: unknown option: $1 (try --help)" >&2; exit 1 ;;
    esac
    shift
done

if [[ $tools_only -eq 1 ]]; then
    if [[ $check -eq 1 || $install_deps -eq 1 || $offline -eq 1 || $legacy_project -eq 1 ]]; then
        echo "bootstrap: --tools-only is a separate local installation command" >&2
        exit 1
    fi
    "$repo_root/scripts/ocaml-deps.sh" --tool-deps
    exec python3 "$repo_root/scripts/install-tools.py"
fi

# --check promises to change nothing, so it cannot be combined with an option whose
# whole purpose is to install. Caught here rather than letting layer 1 install and
# layer 2 then report it would have.
if [[ $check -eq 1 && $install_deps -eq 1 ]]; then
    echo "bootstrap: --check and --install-deps contradict each other" >&2
    exit 1
fi

deps_args=()
[[ $install_deps -eq 0 ]] || deps_args+=(--install)
[[ $legacy_project -ne 0 ]] || deps_args+=(--tool-deps)

flow_args=()
[[ $check -eq 0 ]] || flow_args+=(--check)
[[ $offline -eq 0 ]] || flow_args+=(--offline)
[[ $no_container -eq 0 ]] || flow_args+=(--no-container)
[[ $legacy_project -eq 0 ]] || flow_args+=(--legacy-project)

if [[ $check -eq 0 && $offline -eq 0 && $legacy_project -eq 0 ]]; then
    mkdir -p "$repo_root/.dev"
    exec 9>"$repo_root/.dev/bootstrap.lock"
    if ! flock -n 9; then
        printf '%s\n' 'Another Electrum bootstrap is running; waiting for it to finish…' >&2
        flock 9
    fi
    if [[ $refresh -eq 0 && $install_deps -eq 0 ]] &&
        python3 -B "$repo_root/scripts/bootstrap_ready.py" check "$no_container"; then
        printf '%s\n' 'Electrum is already configured. Run silver.'
        exit 0
    fi
fi

"$repo_root/scripts/ocaml-deps.sh" "${deps_args[@]}"

if [[ $legacy_project -eq 1 ]]; then
    exec "$repo_root/asic_support/tinytapeout/scripts/bootstrap-toolchain.sh" "${flow_args[@]}"
fi

if [[ $check -eq 1 || $offline -eq 1 ]]; then
    python3 -B "$repo_root/scripts/install-tools.py" --check-current
else
    python3 -B "$repo_root/scripts/install-tools.py" --ensure
fi
source "$repo_root/scripts/env.sh"
"$ELECTRUM_TOOLS_PREFIX/bin/hardcaml-asic-flow" provision \
    --toolchain "$repo_root/_flow_tools" "${flow_args[@]}"
if [[ $check -eq 0 && $offline -eq 0 ]]; then
    python3 -B "$repo_root/scripts/workbench.py" configure --toolchain-root "$repo_root/_flow_tools"
    python3 -B "$repo_root/scripts/bootstrap_ready.py" record "$no_container" ||
        printf '%s\n' 'Bootstrap finished, but could not record fast-path readiness.' >&2
    printf 'Electrum is configured. Run silver from %s.\n' "$repo_root"
fi
