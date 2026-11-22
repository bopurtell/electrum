open! Core

(* The repository's command front door: [dune exec electrum -- <command>].

   Stateful work (provisioning, staging, hardening, precheck) stays in the scripts under
   scripts/ and asic_support/tinytapeout/scripts/, which own their options and exit codes;
   commands here exec them so those codes reach the caller unchanged. Pure checks are dune
   rules rather than commands: see asic_support/tinytapeout/src/dune and
   asic_support/tinytapeout/test/dune. *)

let lock_file = "asic_support/tinytapeout/toolchain.lock"

(* Search upward from Dune's root or the executable, independent of directory depth.
   Prefer an outer source root over a copied lock beneath _build/default. *)
let repo_root =
  lazy
    (let from_env = Sys.getenv "DUNE_SOURCEROOT" in
     let from_exe = Filename.dirname (Filename_unix.realpath Sys_unix.executable_name) in
     let is_root dir = Sys_unix.file_exists_exn (dir ^/ lock_file) in
     let rec find_root dir =
       let parent = Filename.dirname dir in
       let outer = if String.equal parent dir then None else find_root parent in
       match outer with
       | Some _ -> outer
       | None -> if is_root dir then Some dir else None
     in
     match List.find_map (List.filter_opt [ from_env; Some from_exe ]) ~f:find_root with
     | Some root -> root
     | None ->
       eprintf "error: cannot find the repository root (no %s)\n" lock_file;
       exit 2)
;;

let script path = force repo_root ^/ path

let exec path args =
  let prog = script path in
  never_returns (Core_unix.exec ~prog ~argv:(prog :: args) ())
;;

(* Runs to completion, for commands that report on several scripts. *)
let run path args =
  let prog = script path in
  let pid = Core_unix.fork_exec ~prog ~argv:(prog :: args) () in
  Result.is_ok (Core_unix.waitpid pid)
;;

let flag_arg name = function
  | true -> [ "--" ^ name ]
  | false -> []
;;

let bootstrap_script = "bootstrap.sh"

(* The canonical ASIC flow. Every command here that implements or hardens goes through
   this one script, so there is a single implementation path and a single set of exit
   codes. See docs/flow.md. *)
let flow_script = "asic_support/flow.sh"

let bootstrap =
  Command.basic
    ~summary:"Converge the OCaml and flow environments on the lockfile"
    ~readme:(fun () ->
      "Runs ./bootstrap.sh: checks OCaml prerequisites, selects local ASIC and \
       Silver tools, and provisions the pinned physical toolchain and its managed Python. \
       No design is staged unless -legacy-project is selected.")
    (let%map_open.Command offline =
       flag "offline" no_arg ~doc:" reuse the environment; fetch and install nothing"
     and check = flag "check" no_arg ~doc:" validate and change nothing"
     and no_container =
       flag "no-container" no_arg ~doc:" skip the Docker/Podman prerequisite"
     and legacy_project =
       flag
         "legacy-project"
         no_arg
         ~doc:
           " also stage and configure the legacy P0 project (./asic_support/flow.sh does not use \
            it)"
     in
     fun () ->
       exec
         bootstrap_script
         (flag_arg "offline" offline
          @ flag_arg "check" check
          @ flag_arg "no-container" no_container
          @ flag_arg "legacy-project" legacy_project))
;;

(* Activation is optional for the scripts but is what a new terminal lacks, so it is
   reported rather than failed. *)
let report_shell () =
  let root = force repo_root in
  printf "\n==> This shell\n";
  let expect ~var ~want =
    let status =
      match Sys.getenv var with
      | None -> "not set; source scripts/env.sh"
      | Some have when String.equal have want -> "ok"
      | Some have ->
        sprintf "%s belongs to another checkout; source scripts/env.sh here" have
    in
    printf "    %-12s %s\n" var status
  in
  expect ~var:"PDK_ROOT" ~want:(root ^/ "_flow_tools/pdk");
  expect ~var:"FLOW_PY" ~want:(root ^/ "_flow_tools/.venv/bin/python")
;;

let doctor =
  Command.basic
    ~summary:"Report the state of every environment layer; change nothing"
    (let%map_open.Command no_container =
       flag "no-container" no_arg ~doc:" skip the Docker/Podman prerequisite"
     in
     fun () ->
       let flow_ok =
         run bootstrap_script ("--check" :: flag_arg "no-container" no_container)
       in
       report_shell ();
       let verdict ok = if ok then "ok" else "needs ./bootstrap.sh" in
       printf "\n==> Summary\n";
       printf "    %-12s %s\n" "bootstrap" (verdict flow_ok);
       if not flow_ok then exit 2)
;;

let flow =
  Command.basic
    ~summary:"Run the adopted ASIC flow (an alias for ./asic_support/flow.sh)"
    ~readme:(fun () ->
      "Passes the named steps to ./asic_support/flow.sh and returns its exit status unchanged. \
       With no step it runs the whole flow, hardening included, which takes hours.\n\n\
       ./asic_support/flow.sh --help is the help for the steps and the ELECTRUM_* overrides; this \
       alias cannot show it, because -help is read by this command line first. \
       ./asic_support/flow.sh is the canonical spelling and the one the documentation uses: the \
       alias exists so a `electrum` habit still reaches the same runner, and it needs \
       neither dune nor an activated switch.")
    (let%map_open.Command steps = anon (sequence ("STEP" %: string)) in
     fun () -> exec flow_script steps)
;;

(* The adopted path and the legacy path both harden, but from different inputs, so one
   name cannot mean both. [harden] is the adopted physical run; the staged-project one
   keeps its script and an explicitly legacy name. *)
let harden =
  Command.basic
    ~summary:"Harden the emitted bundle: an alias for ./asic_support/flow.sh run"
    ~readme:(fun () ->
      "Runs the adopted flow's physical step on the bundle in $ELECTRUM_FLOW_OUT: mapped \
       CMOS5L synthesis and place-and-route, into a new run directory. It does not emit \
       the bundle first, so `./asic_support/flow.sh build emit preflight` (or the whole \
       `./asic_support/flow.sh`) comes before it.\n\n\
       This used to harden the legacy staged project, which is a different input. That \
       command is now `legacy-harden`, and its -tag and -no-docker flags belong to it: \
       they are rejected here rather than reinterpreted.")
    (let%map_open.Command no_docker =
       flag "no-docker" no_arg ~doc:" (legacy only) use a native LibreLane"
     and tag =
       flag
         "tag"
         (optional string)
         ~doc:"NAME (legacy only) label for the archived previous run"
     in
     fun () ->
       (* Translating these would be a guess. The adopted runner is dockerized with the
          pinned image, and it never archives a previous run to make room for this one:
          each attempt already gets its own directory under $ELECTRUM_RUNS. *)
       let reject flag ~spelling reason =
         eprintf "error: %s is a legacy-harden flag\n" flag;
         eprintf "       %s\n" reason;
         eprintf "       Use: dune exec electrum -- legacy-harden %s\n" spelling;
         exit 2
       in
       if no_docker
       then
         reject
           "-no-docker"
           ~spelling:"-no-docker"
           "the adopted run uses the pinned LibreLane image from toolchain.lock.";
       Option.iter tag ~f:(fun tag ->
         reject
           "-tag"
           ~spelling:(sprintf "-tag %s" tag)
           "the adopted run gives every attempt its own directory; none is archived.");
       exec flow_script [ "run" ])
;;

let legacy_harden =
  Command.basic
    ~summary:"Legacy: harden the staged project (_flow_results/legacy/p0-staged)"
    ~readme:(fun () ->
      "The pre-adoption physical path: it hardens the staged legacy P0 project built \
       from the committed RTL and the hand-maintained info.yaml and src/config.json, not \
       an emitted bundle. It needs `./bootstrap.sh --legacy-project` to have \
       staged that project. Kept until the adopted route is validated; new work belongs \
       in ./asic_support/flow.sh.")
    (let%map_open.Command no_docker =
       flag "no-docker" no_arg ~doc:" use a native LibreLane"
     and tag =
       flag "tag" (optional string) ~doc:"NAME label for the archived previous run"
     in
     fun () ->
       exec
         "asic_support/tinytapeout/scripts/harden-cmos5l.sh"
         (flag_arg "no-docker" no_docker
          @ Option.value_map tag ~default:[] ~f:(fun tag -> [ "--tag"; tag ])))
;;

let check =
  Command.basic
    ~summary:"RTL regression on the committed RTL: build, tests, lint, staging"
    ~readme:(fun () ->
      "Legacy inputs: the committed asic_support/tinytapeout/src RTL and the hand-maintained \
       info.yaml and src/config.json. It runs dune build, the Hardcaml tests, the \
       wrapper simulation, Verilator lint and generic Yosys synthesis, then stages the \
       legacy project. The adopted bundle is checked instead by \
       asic_support/tinytapeout/scripts/check-adopted-bundle.py, and built by ./asic_support/flow.sh \
       build emit.")
    (Command.Param.return (fun () -> exec "asic_support/tinytapeout/scripts/check-p0.sh" []))
;;

let stage =
  Command.basic
    ~summary:"Legacy: regenerate RTL and stage the Tiny Tapeout project"
    ~readme:(fun () ->
      "Writes _flow_results/legacy/p0-staged from the committed RTL and the \
       hand-maintained metadata and configuration, for legacy-harden and precheck. The \
       adopted flow reads none of it: ./asic_support/flow.sh emit renders its inputs from the \
       declaration in asic_support/project/chip_project.ml.")
    (Command.Param.return (fun () -> exec "asic_support/tinytapeout/scripts/stage-project.sh" []))
;;

let precheck =
  Command.basic
    ~summary:"Legacy: Tiny Tapeout precheck on a legacy hardening run (needs Nix)"
    ~readme:(fun () ->
      "Reads the run left by legacy-harden under _flow_results/legacy/runs. The adopted \
       flow runs the same upstream precheck as part of ./asic_support/flow.sh postcheck, against \
       its own run directory, and needs no separate command.")
    (Command.Param.return (fun () -> exec "asic_support/tinytapeout/scripts/precheck.sh" []))
;;

let command =
  Command.group
    ~summary:"Host, simulator, environment, and ASIC flow commands for electrum"
    ~readme:(fun () ->
      "First time on a machine or clone: ./bootstrap.sh\n\
       Each new shell: source scripts/env.sh\n\
       The ASIC flow: ./asic_support/flow.sh (./asic_support/flow.sh --help)\n\
       See docs/environment.md for the environment, docs/flow.md for the flow.")
    [ "bootstrap", bootstrap
    ; "doctor", doctor
    ; "flow", flow
    ; "harden", harden
    ; "check", check
    ; "stage", stage
    ; "precheck", precheck
    ; "legacy-harden", legacy_harden
    ; "sim", Sim_cli.command
    ]
;;

let () = Command_unix.run command
