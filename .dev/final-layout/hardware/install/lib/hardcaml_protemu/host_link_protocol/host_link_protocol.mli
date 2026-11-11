(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "host_link_protocol.mli" *)
(** Protocol vocabulary/layouts, CRC parameters and u16 bounds. Software byte conversion
    and its errors are exposed only by [Codec]. *)

include module type of struct
  include Definitions
end

module Codec = Codec
