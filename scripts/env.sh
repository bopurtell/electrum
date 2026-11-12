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
_protemu_src=${BASH_SOURCE[0]:-$0}
case $_protemu_src in
    */*) _protemu_root=${_protemu_src%/*} ;;
    *) _protemu_root=. ;;
esac
_protemu_root=$(CDPATH='' builtin cd -- "$_protemu_root/.." && builtin pwd)
unset _protemu_src

# Remove only paths owned by this project's local tools (including a previously
# selected generation). Preserve unrelated entries, their order and empty entries.
_protemu_old_prefix=${PROTEMU_TOOLS_PREFIX:-}
case $_protemu_old_prefix in
    */.dev/tools/generations/*/prefix) ;;
    *) _protemu_old_prefix= ;;
esac
_protemu_clean_owned_path() {
    _protemu_rest=$1:
    _protemu_clean=
    _protemu_first=1
    while [ -n "$_protemu_rest" ]; do
        _protemu_entry=${_protemu_rest%%:*}
        _protemu_rest=${_protemu_rest#*:}
        case $_protemu_entry in
            "$_protemu_root"/.dev/tools/generations/*/prefix/bin|\
            "$_protemu_root"/.dev/tools/generations/*/prefix/lib|\
            "$_protemu_root"/.dev/tools/generations/*/prefix/lib/*|\
            "$_protemu_root"/.dev/pt3a-provider/bin|\
            "$_protemu_root"/.dev/pt3a-provider/prefix/bin|\
            "$_protemu_root"/.dev/pt3a-provider/prefix/lib|\
            "$_protemu_root"/.dev/pt3a-provider/prefix/lib/*) continue ;;
        esac
        if [ -n "$_protemu_old_prefix" ]; then
            case $_protemu_entry in
                "$_protemu_old_prefix"/bin|"$_protemu_old_prefix"/lib|"$_protemu_old_prefix"/lib/*) continue ;;
            esac
        fi
        if [ "$_protemu_first" -eq 1 ]; then
            _protemu_clean=$_protemu_entry
            _protemu_first=0
        else
            _protemu_clean=$_protemu_clean:$_protemu_entry
        fi
    done
}
_protemu_clean_owned_path "${PATH-}"
export PATH=$_protemu_clean
for _protemu_var in OCAMLPATH CAML_LD_LIBRARY_PATH; do
    if [ "${!_protemu_var+x}" ]; then
        _protemu_clean_owned_path "${!_protemu_var}"
        if [ -n "$_protemu_clean" ]; then
            export "$_protemu_var=$_protemu_clean"
        else
            unset "$_protemu_var"
        fi
    fi
done
for _protemu_var in OCAMLFIND_CONF OCAMLFIND_DESTDIR OCAMLFIND_TOOLCHAIN DUNE_BUILD_DIR DUNE_WORKSPACE DUNE_PROFILE; do
    case ${!_protemu_var-} in
        "$_protemu_root"/.dev/tools/generations/*|"$_protemu_root"/.dev/pt3a-provider/*) unset "$_protemu_var" ;;
    esac
done
unset PROTEMU_TOOLS_PREFIX PROTEMU_TOOLS_RECEIPT PROTEMU_ASIC_PREFIX PROTEMU_ASIC_RECEIPT

# Validate BEFORE opam/flow activation can replace the caller's environment.
# Interactive failure must also prevent an ordinary command from falling through
# to an older shared-switch CLI/library. Guards affect this shell only; Dune is
# blocked only within the failed project. A successful source removes our guards.
_protemu_activation_guard() {
    builtin printf '%s\n' 'Protemu tools activation failed; repair/select the local installation and source scripts/env.sh again.' >&2
    return 2
}
if ! _protemu_activation=$(command python3 "$_protemu_root/scripts/install-tools.py" --activation); then
    _protemu_blocked_root=$_protemu_root
    export PROTEMU_TOOLS_ACTIVATION_FAILED=1
    if ! declare -F hardcaml-asic-flow >/dev/null; then
        function hardcaml-asic-flow { _protemu_activation_guard; }
    fi
    if ! declare -F hardcaml-workbench >/dev/null; then
        function hardcaml-workbench { _protemu_activation_guard; }
    fi
    if ! declare -F hardcaml-workbench-daemon >/dev/null; then
        function hardcaml-workbench-daemon { _protemu_activation_guard; }
    fi
    if ! declare -F dune >/dev/null; then
        function dune {
            case $(builtin pwd -P)/ in
                "$_protemu_blocked_root"/*) _protemu_activation_guard ;;
                *) command dune "$@" ;;
            esac
        }
    fi
    unset _protemu_activation _protemu_root _protemu_old_prefix _protemu_var
    unset _protemu_rest _protemu_entry _protemu_clean _protemu_first
    unset -f _protemu_clean_owned_path
    return 2 2>/dev/null || exit 2
fi

# Clear only guards still carrying our sentinel, not user-replaced functions.
for _protemu_var in hardcaml-asic-flow hardcaml-workbench hardcaml-workbench-daemon dune; do
    case $(declare -f "$_protemu_var") in
        *'_protemu_activation_guard'*) unset -f "$_protemu_var" ;;
    esac
done
unset -f _protemu_activation_guard _protemu_clean_owned_path
unset PROTEMU_TOOLS_ACTIVATION_FAILED _protemu_blocked_root _protemu_old_prefix _protemu_var
unset _protemu_rest _protemu_entry _protemu_clean _protemu_first

# 1. OCaml
if command -v opam >/dev/null 2>&1; then
    eval "$(opam env --switch="${OPAM_SWITCH:-5.2.0+ox}" --set-switch)"
else
    echo "env.sh: opam not found; run ./scripts/bootstrap.sh" >&2
fi

# 2. Apply the validated project-local compiler/library/tool selection. Metadata
# and receipt inventory are the normal authority, not the historical PT3a lock.
eval "$_protemu_activation"
unset _protemu_activation

# 3. Optional legacy flow variables (PDK, PDK_ROOT, TT_SUPPORT_TOOLS_DIR).
# Normal Workbench configuration may explicitly select an external toolchain, so
# absence of the legacy local environment is not an activation failure.
if [ -f "$_protemu_root/_flow_tools/toolchain-env.sh" ]; then
    . "$_protemu_root/_flow_tools/toolchain-env.sh"
fi

# 4. Python environment. The same effect as _flow_tools/venv/bin/activate without changing
#    the prompt. Any previously active environment (another worktree's, or this
#    one from an earlier source) is removed from PATH first, so re-sourcing
#    switches rather than stacks, and the flow venv always leads the opam bin.
if [ -x "$_protemu_root/_flow_tools/venv/bin/python" ]; then
    _protemu_path=
    _protemu_rest=$PATH:
    while [ -n "$_protemu_rest" ]; do
        _protemu_entry=${_protemu_rest%%:*}
        _protemu_rest=${_protemu_rest#*:}
        if [ -n "$_protemu_entry" ] \
            && { [ -z "${VIRTUAL_ENV:-}" ] || [ "$_protemu_entry" != "$VIRTUAL_ENV/bin" ]; } \
            && [ "$_protemu_entry" != "$_protemu_root/_flow_tools/venv/bin" ]; then
            _protemu_path=${_protemu_path:+$_protemu_path:}$_protemu_entry
        fi
    done
    export VIRTUAL_ENV="$_protemu_root/_flow_tools/venv"
    export PATH="$VIRTUAL_ENV/bin:$_protemu_path"
    unset PYTHONHOME _protemu_path _protemu_rest _protemu_entry
fi

unset _protemu_root
