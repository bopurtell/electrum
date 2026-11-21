open! Core

type t =
  | Loader
  | Memory
  | Observable
[@@deriving equal]

let all = [ Loader; Memory; Observable ]

let id = function
  | Loader -> "loader"
  | Memory -> "memory"
  | Observable -> "observable"
;;

let label = function
  | Loader -> "Electrum serial loader"
  | Memory -> "Program memory bring-up"
  | Observable -> "Protocol mechanisms bring-up"
;;

let of_string id_to_find =
  match List.find all ~f:(fun kind -> String.equal (id kind) id_to_find) with
  | Some kind -> Ok kind
  | None -> Or_error.error_string ("Unknown chip: " ^ id_to_find)
;;
