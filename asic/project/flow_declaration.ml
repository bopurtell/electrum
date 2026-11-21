open! Core
open Hardcaml_asic

let entry ~id ~label ~description ~endpoints ~additional_profiles ?(profiles = []) () =
  let open Or_error.Let_syntax in
  let%bind methodology =
    Flow.Methodology.create ~id ~label ~description ~backend_recipe:Librelane_classic_v1
      ~endpoints ~configurable:Flow.Parameter.Key.all ~defaults:[]
  in
  let%bind balanced =
    Flow.Profile.create ~id:"balanced" ~label:"Balanced"
      ~description:"Electrum synthesis defaults; unchanged timing envelope" ~assignments:[]
  in
  Flow.Catalog.Entry.create ~methodology
    ~profiles:(balanced :: profiles @ additional_profiles) ~default_profile:"balanced"
;;
