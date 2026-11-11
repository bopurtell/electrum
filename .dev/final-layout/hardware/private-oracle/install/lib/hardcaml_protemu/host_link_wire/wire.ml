(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "wire.ml" *)
(* Temporary AM3 compatibility facade for the frozen HL4a archive and transitional
   external consumers. New consumers use Host_link_protocol and its Codec. Remove this
   facade only after those consumers migrate and the owner retires the archive. All
   definitions and software implementations belong to the canonical library.
*)

include Host_link_protocol

module Crc = struct
  include Host_link_protocol.Crc
  include Host_link_protocol.Codec.Crc
end

module U16 = struct
  include Host_link_protocol.U16
  include Host_link_protocol.Codec.U16
end

module Request = struct
  include Host_link_protocol.Request
  include Host_link_protocol.Codec.Request
end

module Response = struct
  include Host_link_protocol.Response
  include Host_link_protocol.Codec.Response
end
