(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "item.ml" *)
(* Items for the serial-host agent: the transactions that cross the Host_link serial
   boundary, and the pure helpers that build and read their bytes.

   Product protocol types stay in [Protemu_host_link_wire.Wire]; items refer to them and
   never redefine them. Nothing here touches a simulator. [Driver] clocks these items
   through the pins; [Monitor] rebuilds the [Observed] items from them. See
   docs/serial_host_pilot.md.
*)

open! Core
module Wire = Protemu_host_link_wire.Wire

(* Bytes as space-separated hex, for transcripts and failure reports. *)
let hex bytes =
  String.to_list bytes
  |> List.map ~f:(fun byte -> sprintf "%02x" (Char.to_int byte))
  |> String.concat ~sep:" "
;;

(* The serial link is MSB first: a byte's bits in send order, and bits back to bytes. *)
let bits_of_byte byte =
  List.init 8 ~f:(fun index -> Char.to_int byte land (0x80 lsr index) <> 0)
;;

let bytes_of_bits bits =
  List.chunks_of bits ~length:8
  |> List.map ~f:(fun byte ->
    List.fold byte ~init:0 ~f:(fun value bit -> (value lsl 1) lor Bool.to_int bit)
    |> Char.of_int_exn)
  |> String.of_char_list
;;

(* The host's choice after validating a response with LCLK high: commit supplies the final
   fall; replay deselects first so the loader retains the response.
*)
module Outcome = struct
  type t =
    | Commit
    | Replay
  [@@deriving sexp_of, compare, equal]
end

(* A pause inside a selected response read, after bit [after_bits] (counting from one).
   With [clock_high] the pause follows that bit's sample with LCLK still high; otherwise
   it follows the bit's fall.
*)
module Pause = struct
  type t =
    { after_bits : int
    ; cycles : int
    ; clock_high : bool
    }
end

(* Validation before the final fall: commit a decodable, correlated response; replay
   anything else.
*)
let commit_if_valid : (Wire.Response.t, _) Result.t -> Outcome.t = function
  | Ok _ -> Commit
  | Error _ -> Replay
;;

(* One response read: its selection and deselection cycles, the bytes read, their
   decoding, and the outcome the host chose.
*)
module Read = struct
  type t =
    { selected : int
    ; deselected : int
    ; bytes : string
    ; decoded : (Wire.Response.t, Wire.Response.Decode_error.t) Result.t
    ; outcome : Outcome.t
    }
end

(* The cycles and response of a committed request/response transaction. *)
module Exchange = struct
  type t =
    { started : int (* cycle LSEL_N was asserted for the request *)
    ; request_deselected : int
    ; ready : int
    ; response_selected : int
    ; response_deselected : int
    ; bytes : string
    ; response : Wire.Response.t
    }
end

(* A legal request frame from the codec; an encode error is a bug in the test. *)
let encode ~tag request =
  match Wire.Request.encode ~tag request with
  | Ok frame -> frame
  | Error error ->
    raise_s [%message "bad test request" (error : Wire.Request.Encode_error.t)]
;;

(* Malformed request frames, built byte by byte. [Wire.Request.encode] builds only legal
   frames, so intentional corruption lives here, never in the codec. [crc] uses the
   software CRC over the bytes given.
*)
module Raw = struct
  let crc body = String.of_char (Char.of_int_exn (Wire.Crc.compute body))

  let body ?(magic = 0xa5) ?(version = 0x10) ?payload_length ~tag ~command payload =
    let payload_length = Option.value payload_length ~default:(List.length payload) in
    String.of_char_list
      (List.map
         ([ magic; version; tag; command; payload_length land 0xff; payload_length lsr 8 ]
          @ payload)
         ~f:Char.of_int_exn)
  ;;

  (* Header, payload, and a correct CRC for them. *)
  let frame ?magic ?version ?payload_length ~tag ~command payload =
    let body = body ?magic ?version ?payload_length ~tag ~command payload in
    body ^ crc body
  ;;

  let flip_last frame ~mask =
    let last = String.length frame - 1 in
    String.prefix frame last
    ^ String.of_char (Char.of_int_exn (Char.to_int frame.[last] lxor mask))
  ;;

  let zeros count = String.make count '\x00'
end

(* What the passive monitor saw cross the pins in one selection, LSEL_N low to LSEL_N
   high. Each item is rebuilt from the sampled pins alone, never from what the driver
   intended. [selected] is the first cycle with LSEL_N low and [deselected] the first
   cycle with it high again. Bits are sampled at each LCLK rise, pre-edge, in the rise
   cycle; whole bytes are packed MSB first and [extra_bits] holds the bits of a final
   partial byte in clocked order.
*)
module Observed = struct
  (* How a response read ended. *)
  module Ending = struct
    type t =
      | Commit (* LSEL_N high with LCLK low after every declared bit *)
      | Replay (* LSEL_N high with LCLK still high *)
      | Abandoned (* LSEL_N high with LCLK low before the declared length *)
    [@@deriving sexp_of, compare, equal]
  end

  (* A request frame as clocked on LDI. There is no request decoder in the codec, so the
     frame stays raw.
  *)
  module Request = struct
    type t =
      { selected : int
      ; deselected : int
      ; bytes : string
      ; extra_bits : bool list
      }
    [@@deriving sexp_of, compare, equal]
  end

  (* A response read as clocked out of LDO, with [Wire.Response.decode] of its whole
     bytes. Nothing is correlated with a request here.
  *)
  module Response = struct
    type t =
      { selected : int
      ; deselected : int
      ; bytes : string
      ; extra_bits : bool list
      ; decoded : (Wire.Response.t, Wire.Response.Decode_error.t) Result.t
      ; ending : Ending.t
      }
    [@@deriving sexp_of, compare, equal]
  end

  type t =
    | Request of Request.t
    | Response of Response.t
  [@@deriving sexp_of, compare, equal]
end
