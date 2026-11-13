# Per-shell activation. Source it; do not run it:
#
#   source ./scripts/env.sh
#
# Installs nothing and is safe to source repeatedly. It sets up what a new shell
# lacks after a reboot or in a new terminal: the opam switch, the flow variables
# written by the bootstrap, and the project Python environment on PATH.
#
# None of this is needed by the repository's scripts, which locate their own
# tools; it is for running dune, python, librelane, etc. by hand. Precheck's
# separate _flow_tools/precheck-venv is never activated: precheck.sh calls it directly.

# Sourced into an interactive shell, where the user's aliases and functions are
# live: a `paste`, `grep` or `cd` of their own would run in place of the real
# command. Shell-side path editing uses builtins and parameter expansion, never
# external text tools, and `builtin cd`/`builtin pwd`. Python/opam metadata calls
# are explicit below.
_electrum_src=${BASH_SOURCE[0]:-$0}
case $_electrum_src in
    */*) _electrum_root=${_electrum_src%/*} ;;
    *) _electrum_root=. ;;
esac
_electrum_root=$(CDPATH='' builtin cd -- "$_electrum_root/.." && builtin pwd)
unset _electrum_src

# Remove only paths owned by this project's local tools (including a previously
# selected generation). Preserve unrelated entries, their order and empty entries.
_electrum_old_prefix=${ELECTRUM_TOOLS_PREFIX:-${PROTEMU_TOOLS_PREFIX:-}}
case $_electrum_old_prefix in
    */.dev/tools/generations/*/prefix) ;;
    *) _electrum_old_prefix= ;;
esac
_electrum_clean_owned_path() {
    _electrum_rest=$1:
    _electrum_clean=
    _electrum_first=1
    while [ -n "$_electrum_rest" ]; do
        _electrum_entry=${_electrum_rest%%:*}
        _electrum_rest=${_electrum_rest#*:}
        case $_electrum_entry in
            "$_electrum_root"/.dev/tools/generations/*/prefix/bin|\
            "$_electrum_root"/.dev/tools/generations/*/prefix/lib|\
            "$_electrum_root"/.dev/tools/generations/*/prefix/lib/*|\
            "$_electrum_root"/.dev/pt3a-provider/bin|\
            "$_electrum_root"/.dev/pt3a-provider/prefix/bin|\
            "$_electrum_root"/.dev/pt3a-provider/prefix/lib|\
            "$_electrum_root"/.dev/pt3a-provider/prefix/lib/*) continue ;;
        esac
        if [ -n "$_electrum_old_prefix" ]; then
            case $_electrum_entry in
                "$_electrum_old_prefix"/bin|"$_electrum_old_prefix"/lib|"$_electrum_old_prefix"/lib/*) continue ;;
            esac
        fi
        if [ "$_electrum_first" -eq 1 ]; then
            _electrum_clean=$_electrum_entry
            _electrum_first=0
        else
            _electrum_clean=$_electrum_clean:$_electrum_entry
        fi
    done
}
_electrum_clean_owned_path "${PATH-}"
export PATH=$_electrum_clean
for _electrum_var in OCAMLPATH CAML_LD_LIBRARY_PATH; do
    if [ "${!_electrum_var+x}" ]; then
        _electrum_clean_owned_path "${!_electrum_var}"
        if [ -n "$_electrum_clean" ]; then
            export "$_electrum_var=$_electrum_clean"
        else
            unset "$_electrum_var"
        fi
    fi
done
for _electrum_var in OCAMLFIND_CONF OCAMLFIND_DESTDIR OCAMLFIND_TOOLCHAIN DUNE_BUILD_DIR DUNE_WORKSPACE DUNE_PROFILE; do
    case ${!_electrum_var-} in
        "$_electrum_root"/.dev/tools/generations/*|"$_electrum_root"/.dev/pt3a-provider/*) unset "$_electrum_var" ;;
    esac
done
unset ELECTRUM_TOOLS_PREFIX ELECTRUM_TOOLS_RECEIPT ELECTRUM_ASIC_PREFIX ELECTRUM_ASIC_RECEIPT
unset PROTEMU_TOOLS_PREFIX PROTEMU_TOOLS_RECEIPT PROTEMU_ASIC_PREFIX PROTEMU_ASIC_RECEIPT

# Validate BEFORE opam/flow activation can replace the caller's environment.
# Interactive failure must also prevent an ordinary command from falling through
# to an older shared-switch CLI/library. Guards affect this shell only; Dune is
# blocked only within the failed project. A successful source removes our guards.
_electrum_activation_guard() {
    builtin printf '%s\n' 'Electrum tools activation failed; repair/select the local installation and source scripts/env.sh again.' >&2
    return 2
}
if ! _electrum_activation=$(command python3 "$_electrum_root/scripts/install-tools.py" --activation); then
    _electrum_blocked_root=$_electrum_root
    export ELECTRUM_TOOLS_ACTIVATION_FAILED=1
    if ! declare -F hardcaml-asic-flow >/dev/null; then
        function hardcaml-asic-flow { _electrum_activation_guard; }
    fi
    if ! declare -F hardcaml-workbench >/dev/null; then
        function hardcaml-workbench { _electrum_activation_guard; }
    fi
    if ! declare -F hardcaml-workbench-daemon >/dev/null; then
        function hardcaml-workbench-daemon { _electrum_activation_guard; }
    fi
    if ! declare -F dune >/dev/null; then
        function dune {
            case $(builtin pwd -P)/ in
                "$_electrum_blocked_root"/*) _electrum_activation_guard ;;
                *) command dune "$@" ;;
            esac
        }
    fi
    unset _electrum_activation _electrum_root _electrum_old_prefix _electrum_var
    unset _electrum_rest _electrum_entry _electrum_clean _electrum_first
    unset -f _electrum_clean_owned_path
    return 2 2>/dev/null || exit 2
fi

# Clear only guards still carrying our sentinel, not user-replaced functions.
for _electrum_var in hardcaml-asic-flow hardcaml-workbench hardcaml-workbench-daemon dune; do
    case $(declare -f "$_electrum_var") in
        *'_electrum_activation_guard'*|*'_protemu_activation_guard'*) unset -f "$_electrum_var" ;;
    esac
done
unset -f _electrum_activation_guard _electrum_clean_owned_path
unset -f _protemu_activation_guard _protemu_clean_owned_path
unset PROTEMU_TOOLS_ACTIVATION_FAILED _protemu_blocked_root
unset ELECTRUM_TOOLS_ACTIVATION_FAILED _electrum_blocked_root _electrum_old_prefix _electrum_var
unset _electrum_rest _electrum_entry _electrum_clean _electrum_first

# 1. OCaml
if command -v opam >/dev/null 2>&1; then
    eval "$(opam env --switch="${OPAM_SWITCH:-5.2.0+ox}" --set-switch)"
else
    echo "env.sh: opam not found; run ./scripts/bootstrap.sh" >&2
fi

# 2. Apply the validated project-local compiler/library/tool selection. Metadata
# and receipt inventory are the normal authority, not the historical PT3a lock.
eval "$_electrum_activation"
unset _electrum_activation

# 3. Optional legacy flow variables (PDK, PDK_ROOT, TT_SUPPORT_TOOLS_DIR).
# Normal Workbench configuration may explicitly select an external toolchain, so
# absence of the legacy local environment is not an activation failure.
if [ -f "$_electrum_root/_flow_tools/toolchain-env.sh" ]; then
    . "$_electrum_root/_flow_tools/toolchain-env.sh"
fi

# 4. Python environment. The same effect as _flow_tools/venv/bin/activate without changing
#    the prompt. Any previously active environment (another worktree's, or this
#    one from an earlier source) is removed from PATH first, so re-sourcing
#    switches rather than stacks, and the flow venv always leads the opam bin.
if [ -x "$_electrum_root/_flow_tools/venv/bin/python" ]; then
    _electrum_path=
    _electrum_rest=$PATH:
    while [ -n "$_electrum_rest" ]; do
        _electrum_entry=${_electrum_rest%%:*}
        _electrum_rest=${_electrum_rest#*:}
        if [ -n "$_electrum_entry" ] \
            && { [ -z "${VIRTUAL_ENV:-}" ] || [ "$_electrum_entry" != "$VIRTUAL_ENV/bin" ]; } \
            && [ "$_electrum_entry" != "$_electrum_root/_flow_tools/venv/bin" ]; then
            _electrum_path=${_electrum_path:+$_electrum_path:}$_electrum_entry
        fi
    done
    export VIRTUAL_ENV="$_electrum_root/_flow_tools/venv"
    export PATH="$VIRTUAL_ENV/bin:$_electrum_path"
    unset PYTHONHOME _electrum_path _electrum_rest _electrum_entry
fi

unset _electrum_root
