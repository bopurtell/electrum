open! Core
open Hardcaml_asic

(* Association for the existing loader, not a parameterized hardware factory.
   Memory implementation remains a separate explicit resource policy. *)
let create () =
  let open Or_error.Let_syntax in
  let%bind package = Hardware_variant.Parameter.create
    ~key:"package" ~kind:(Enumeration [ "loader-v1" ]) in
  let%bind schema = Hardware_variant.Schema.create
    ~design_id:"electrum-loader" ~schema_id:"fixed-loader-v1" ~parameters:[ package ] in
  Hardware_variant.create ~schema ~assignments:[ "package", Enum "loader-v1" ]
;;

let validate variant =
  let open Or_error.Let_syntax in
  let%bind supported = create () in
  if String.equal (Hardware_variant.identity supported) (Hardware_variant.identity variant)
  then Ok ()
  else Or_error.error_string "only the unchanged fixed loader-v1 hardware variant is supported"
;;
