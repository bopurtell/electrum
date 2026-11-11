(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "codec.ml" *)
(* Software byte conversion for P3.5 requests and responses. This codec does not clock
   pins, poll ready, retry, commit responses, or own transaction timing.

   A Decode_error means malformed bytes or an unexpected correlation. A well-formed
   refusal or device-reported framing error is instead returned as Response.t. The
   independent Verilog peer keeps its own constants, frames and CRC.
*)

open! Core
open Definitions

(* Software CRC-8/ATM, separate from the hardware shift-register implementation. *)
module Crc = struct
  open Definitions.Crc

  let update crc byte =
    Fn.apply_n_times
      ~n:8
      (fun crc ->
        let shifted = (crc lsl 1) land 0xff in
        if crc land 0x80 <> 0 then shifted lxor polynomial else shifted)
      (crc lxor byte)
  ;;

  (* The empty string gives the protocol's initial value. *)
  let compute bytes =
    String.fold bytes ~init:initial ~f:(fun crc byte -> update crc (Char.to_int byte))
    lxor final_xor
  ;;
end

(* Unchecked little-endian conversion, retaining the original helper semantics. *)
module U16 = struct
  let to_bytes value = [ value land 0xff; value lsr 8 ]
  let get bytes ~pos = Char.to_int bytes.[pos] lor (Char.to_int bytes.[pos + 1] lsl 8)
end

(* Typed request encoding; protocol constructors and layouts belong to the root. *)
module Request = struct
  open Definitions.Request

  module Encode_error = struct
    (* [field] is outside [0, max]. *)
    type t =
      | Out_of_range of
          { field : string
          ; value : int
          ; max : int
          }
    [@@deriving sexp_of, compare, equal]
  end

  (* Payload fields in wire order, named for error reporting. *)
  let payload_fields = function
    | Info | Status | Load_complete | Run | Stop | Abort -> []
    | Load_start { length } -> [ "length", length ]
    | Write_word { address; word } -> [ "address", address; "word", word ]
    | Read_word { address } -> [ "address", address ]
    | Verify_word { address; expected } -> [ "address", address; "expected", expected ]
  ;;

  (* The complete frame, CRC included. Every field is range-checked before any byte is
     produced, and the first failing field in wire order is reported; nothing is truncated
     to fit.
  *)
  let encode ~tag t =
    let open Result.Let_syntax in
    let check (field, value, max) =
      if value < 0 || value > max
      then Error (Encode_error.Out_of_range { field; value; max })
      else Ok ()
    in
    let fields = payload_fields t in
    let%map () =
      ("tag", tag, 0xff)
      :: List.map fields ~f:(fun (field, value) -> field, value, Definitions.U16.max)
      |> List.map ~f:check
      |> Result.all_unit
    in
    let payload = List.concat_map fields ~f:(fun (_, value) -> U16.to_bytes value) in
    let header =
      [ magic; Version.byte; tag; Command.to_int (command t) ]
      @ U16.to_bytes (List.length payload)
    in
    let body = String.of_char_list (List.map (header @ payload) ~f:Char.of_int_exn) in
    body ^ String.of_char (Char.of_int_exn (Crc.compute body))
  ;;
end

(* Response parsing and correlation; a well-formed refusal is a decoded response. *)
module Response = struct
  open Definitions.Response

  (* Why bytes are not a valid version-1 response, in the order [decode] checks. Only
     [Correlation_mismatch] carries a well-formed response: it is the device's answer to
     some other request.
  *)
  module Decode_error = struct
    type t =
      | Truncated of
          { expected : int
          ; actual : int
          }
      | Extra_bytes of
          { expected : int
          ; actual : int
          }
      | Bad_magic of int
      | Bad_version of int
      | Payload_length_too_large of int
      | Bad_crc of
          { computed : int
          ; received : int
          }
      | Unknown_result of int
      | Unexpected_result of
          { command : int
          ; result : Result_code.t
          }
      | Payload_length_mismatch of
          { command : int
          ; result : Result_code.t
          ; expected : int
          ; actual : int
          }
      | Invalid_field of
          { field : string
          ; value : int
          }
      | Correlation_mismatch of
          { expected : Correlation.t
          ; response : response
          }
    [@@deriving sexp_of, compare, equal]
  end

  let invalid_field field value = Error (Decode_error.Invalid_field { field; value })

  (* Set bits of [mask] as [all] entries, or [Invalid_field] if a reserved bit is set. *)
  let decode_bits ~field ~all ~bit mask =
    let set = List.filter all ~f:(fun entry -> mask land (1 lsl bit entry) <> 0) in
    let known =
      List.fold set ~init:0 ~f:(fun known entry -> known lor (1 lsl bit entry))
    in
    if mask = known then Ok set else invalid_field field mask
  ;;

  let decode_enum ~field ~of_int value =
    match of_int value with
    | Some decoded -> Ok decoded
    | None -> invalid_field field value
  ;;

  let decode_info payload =
    let open Result.Let_syntax in
    let byte pos = Char.to_int payload.[pos] in
    let u16 pos = U16.get payload ~pos in
    let%bind () =
      if byte Info.Offset.wire_major <> Version.major
      then invalid_field "INFO wire major" (byte Info.Offset.wire_major)
      else if byte Info.Offset.wire_minor <> Version.minor
      then invalid_field "INFO wire minor" (byte Info.Offset.wire_minor)
      else Ok ()
    in
    let%map capabilities =
      decode_bits
        ~field:"INFO capabilities"
        ~all:Capability.all
        ~bit:Capability.bit
        (u16 Info.Offset.capabilities)
    in
    { Info.wire_major = byte Info.Offset.wire_major
    ; wire_minor = byte Info.Offset.wire_minor
    ; isa_version = byte Info.Offset.isa_version
    ; memory_layout = byte Info.Offset.memory_layout
    ; capabilities
    ; memory_word_bits = u16 Info.Offset.memory_word_bits
    ; memory_depth = u16 Info.Offset.memory_depth
    ; max_request_payload_bytes = u16 Info.Offset.max_request_payload_bytes
    ; protocol_pin_count = byte Info.Offset.protocol_pin_count
    }
  ;;

  let decode_status payload =
    let open Result.Let_syntax in
    let byte pos = Char.to_int payload.[pos] in
    let u16 pos = U16.get payload ~pos in
    let%bind flags =
      decode_bits
        ~field:"STATUS flags"
        ~all:Status.Flag.all
        ~bit:Status.Flag.bit
        (u16 Status.Offset.flags)
    in
    let%bind fault_kind =
      decode_enum
        ~field:"STATUS fault kind"
        ~of_int:Fault_kind.of_int
        (byte Status.Offset.fault_kind)
    in
    let%map phase =
      decode_enum ~field:"STATUS phase" ~of_int:Phase.of_int (byte Status.Offset.phase)
    in
    { Status.flags
    ; image_length = u16 Status.Offset.image_length
    ; words_written = u16 Status.Offset.words_written
    ; words_verified = u16 Status.Offset.words_verified
    ; pc = u16 Status.Offset.pc
    ; fault_kind
    ; phase
    }
  ;;

  (* Checks, in order, each failing with the matching [Decode_error]:

     1. at least a header and CRC are present;
     2. magic, then version byte;
     3. the declared payload length is at most [max_payload_length] (so a nonzero high
        byte always fails here);
     4. the frame is exactly header, declared payload and CRC long;
     5. the CRC matches;
     6. the result code is defined;
     7. the result may answer the echoed command, with the payload length that pair
        requires;
     8. INFO and STATUS fields hold no reserved bit or undefined value.

     Nothing is compared with a request here; see [decode_correlated].
  *)
  let decode frame =
    let open Result.Let_syntax in
    let length = String.length frame in
    let byte pos = Char.to_int frame.[pos] in
    let fail_if condition (error : Decode_error.t) =
      if condition then Error error else Ok ()
    in
    let%bind () =
      fail_if
        (length < min_length)
        (Decode_error.Truncated { expected = min_length; actual = length })
    in
    let%bind () = fail_if (byte Offset.magic <> magic) (Bad_magic (byte Offset.magic)) in
    let%bind () =
      fail_if (byte Offset.version <> Version.byte) (Bad_version (byte Offset.version))
    in
    let payload_length = U16.get frame ~pos:Offset.payload_length in
    let%bind () =
      fail_if
        (payload_length > max_payload_length)
        (Payload_length_too_large payload_length)
    in
    let expected = header_length + payload_length + Definitions.Crc.length in
    let%bind () = fail_if (length < expected) (Truncated { expected; actual = length }) in
    let%bind () =
      fail_if (length > expected) (Extra_bytes { expected; actual = length })
    in
    let computed = Crc.compute (String.prefix frame (length - Definitions.Crc.length)) in
    let received = byte (length - Definitions.Crc.length) in
    let%bind () = fail_if (computed <> received) (Bad_crc { computed; received }) in
    let command = byte Offset.command in
    let%bind result =
      Result_code.of_int (byte Offset.result)
      |> Result.of_option ~error:(Decode_error.Unknown_result (byte Offset.result))
    in
    let%bind shape =
      shape ~command result
      |> Result.of_option ~error:(Decode_error.Unexpected_result { command; result })
    in
    let%bind () =
      fail_if
        (payload_length <> shape_length shape)
        (Payload_length_mismatch
           { command; result; expected = shape_length shape; actual = payload_length })
    in
    let payload = String.sub frame ~pos:Offset.payload ~len:payload_length in
    let%map payload =
      match shape with
      | Empty_payload -> Ok Payload.Empty
      | Word_payload -> Ok (Payload.Word (U16.get payload ~pos:0))
      | Info_payload -> decode_info payload >>| fun info -> Payload.Info info
      | Status_payload -> decode_status payload >>| fun status -> Payload.Status status
    in
    { tag = byte Offset.tag; command; result; payload }
  ;;

  (* The caller-facing correlation boundary. [expected] is the correlation of the request
     just sent (Host_link_protocol.Request.correlation). A response that decodes but
     echoes another tag or command is [Correlation_mismatch], which keeps the decoded
     response.

     Careful: a device that received fewer than four request bytes zeroes both echoed
     fields, so its framing error normally surfaces as a mismatch. For an INFO request
     with tag 0 the zeroes are indistinguishable from a real echo and the framing error is
     returned as the device's answer instead. Neither outcome is a success.
  *)
  let decode_correlated ~expected frame =
    let open Result.Let_syntax in
    let%bind response = decode frame in
    if Correlation.equal (correlation response) expected
    then Ok response
    else Error (Decode_error.Correlation_mismatch { expected; response })
  ;;
end
