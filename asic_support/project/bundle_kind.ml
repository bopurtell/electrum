open! Core

(* Legacy bundle selectors, not Silver chip IDs. *)
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

let of_string id_to_find =
  match List.find all ~f:(fun kind -> String.equal (id kind) id_to_find) with
  | Some kind -> Ok kind
  | None -> Or_error.error_string ("Unknown bundle kind: " ^ id_to_find)
;;
