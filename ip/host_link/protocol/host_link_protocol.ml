(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "host_link_protocol.ml" *)
(* Public protocol vocabulary and layouts. Codec owns software byte conversion; both refer
   to the same definitions so request and response types retain identity.
*)

include Definitions
module Codec = Codec
