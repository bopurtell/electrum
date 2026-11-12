open! Core
open! Hardcaml
open! Hardcaml_asic

let require label condition = if not condition then failwith label
let macro = "RM_IHPSG13_1P_256x16_c2_bm_bist"

module Design = struct
  module I = struct
    type 'a t =
      { clock : 'a
      ; enable : 'a
      ; write_enable : 'a
      ; address : 'a [@bits 8]
      ; write_data : 'a [@bits 16]
      }
    [@@deriving hardcaml]
  end

  module O = struct
    type 'a t = { read_data : 'a [@bits 16] } [@@deriving hardcaml]
  end

  let name = "program_resource_test"

  let create context (i : _ I.t) =
    { O.read_data =
        Protemu_asic_rtl.Program_memory.create
          context
          ~clock:i.clock
          ~enable:i.enable
          ~write_enable:i.write_enable
          ~address:i.address
          ~write_data:i.write_data
    }
  ;;
end

let policy requirement name =
  Resource_policy.create
    [ { selector = Resource_policy.Selector.instance_exn name; requirement } ]
  |> Or_error.ok_exn
;;

let project requirement name =
  Project.create
    ~name:"program_resource_test"
    ~metadata:{ title = "Program resource"; author = "test"; description = "PT.3a" }
    ~design:(module Design)
    ~target:
      { harness = Tiny_tapeout { tiles = T6x4 }; technology = Technology.ihp_sg13cmos5l }
    ~flow:(Flow.librelane Synthesis)
    ~policy:(policy requirement name)
    ()
  |> Or_error.ok_exn
;;

let check requirement mode elaborated =
  let resources = Elaborated_project.resources elaborated in
  require "exactly one production program resource" (List.length resources = 1);
  let r = List.hd_exn resources in
  require "stable identity" (String.equal (Resource.Id.to_string r.id) "program");
  require "RAM kind" (String.equal r.request.kind "single_port_ram");
  require
    "complete ordered logical contract"
    (Sexp.equal
       r.request.contract
       (Sexp.of_string
          "((width 16) (depth 256) (read_latency 1) (port 1rw) (disabled_output hold) \
           (write_output unspecified))"));
  require "explicit requirement" (Resource_policy.Requirement.equal r.requirement requirement);
  require
    "instance rule"
    (Resource_policy.Applied.equal
       r.policy
       (Rule (Resource_policy.Selector.instance_exn "program")));
  (match requirement with
   | Resource_policy.Requirement.Flops ->
     require "flops" (Resource.Selection.Implementation.equal r.selection.implementation Flops);
     require "no fallback" (Resource.Selection.Reason.equal r.selection.reason Explicit_flops)
   | Exact ->
     require
       "stock macro"
       (Resource.Selection.Implementation.equal r.selection.implementation (Macro macro));
     require
       "exact mapping"
       (Resource.Selection.Reason.equal
          r.selection.reason
          (Exact_mapping { technology = "ihp-sg13cmos5l" }))
   | Exact_or_flop_fallback -> failwith "unexpected fallback requirement");
  (match mode with
   | Elaboration.Mode.Simulation ->
     require
       "behavioral even when Exact selected"
       (Resource.Record.Elaborated_as.equal r.elaborated_as Behavioral_model);
     require
       "only generated behavioral source"
       ([%equal: Resource.Record.Source.t list] r.sources [ Generated_behavioral_model ])
   | Implementation ->
     require
       "selected implementation"
       (Resource.Record.Elaborated_as.equal r.elaborated_as Selected_implementation);
     (match requirement with
      | Flops ->
        require
          "only synthesizable source"
          ([%equal: Resource.Record.Source.t list] r.sources [ Generated_synthesis_rtl ])
      | Exact ->
        let expected =
          let open Technology.Collateral in
          let pdk directory file = "pdk_dir::libs.ref/sg13cmos5l_sram/" ^ directory ^ "/" ^ file in
          let models role =
            List.map
              [ macro ^ ".v"; "RM_IHPSG13_1P_core_behavioral_bm_bist.v" ]
              ~f:(fun file -> { role; reference = pdk "verilog" file })
          in
          [ { role = Black_box; reference = "generated:" ^ macro ^ ".blackbox.v" } ]
          @ models Simulation_model
          @ models Timed_simulation_model
          @ List.map
              [ "typ", "typ_1p20V_25C"; "slow", "slow_1p08V_125C"; "fast", "fast_1p32V_m55C" ]
              ~f:(fun (corner, suffix) ->
                { role = Timing_model { corner }; reference = pdk "lib" (macro ^ "_" ^ suffix ^ ".lib") })
          @ [ { role = Physical_abstract; reference = pdk "lef" (macro ^ ".lef") }
            ; { role = Physical_layout; reference = pdk "gds" (macro ^ ".gds") }
            ; { role = Spice_netlist; reference = pdk "cdl" (macro ^ ".cdl") }
            ]
          |> List.map ~f:(fun c -> Resource.Record.Source.Collateral c)
        in
        require "complete typed stock collateral" ([%equal: Resource.Record.Source.t list] r.sources expected)
      | Exact_or_flop_fallback -> assert false));
  let restored =
    Resource_snapshot.of_elaborated elaborated
    |> Resource_snapshot.to_json
    |> Resource_snapshot.of_json
    |> Or_error.ok_exn
    |> Resource_snapshot.records
  in
  require "public snapshot round trip" ([%equal: Resource.Record.t list] resources restored)
;;

let () =
  List.iter [ Resource_policy.Requirement.Flops; Exact ] ~f:(fun requirement ->
    List.iter [ Elaboration.Mode.Simulation; Implementation ] ~f:(fun mode ->
      Project.elaborate (project requirement "program") ~mode
      |> Or_error.ok_exn
      |> check requirement mode;
      List.iter [ "memory"; "loader" ] ~f:(fun kind ->
        Protemu_chip_project.Chip_project.project ~selection:requirement kind
        |> Or_error.bind ~f:(Project.elaborate ~mode)
        |> Or_error.ok_exn
        |> check requirement mode);
      require
        "misspelled policy must fail"
        (Or_error.is_error (Project.elaborate (project requirement "progam") ~mode)));
    require
      "no implicit policy for another resource"
      (Or_error.is_error
         (Resource_policy.lookup
            (policy requirement "program")
            (Resource.Id.of_string_exn "other"))));
  printf "PASS PT.3a production program contract, explicit selection, source roles, snapshot and policy rejection\n"
;;
