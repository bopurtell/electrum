open! Core
module P = Host_link_protocol
module C = P.Codec

(* Deliberately independent frame construction: literal framing and a bit-serial CRC,
   without the codec's CRC, lengths, offsets, shapes, or enum conversions. *)
let frame ~command ~result payload =
  let body = [ 0x5a; 0x10; 0x80; command; result; List.length payload; 0 ] @ payload in
  let crc =
    List.fold body ~init:0 ~f:(fun crc byte ->
      List.fold (List.init 8 ~f:Fn.id) ~init:crc ~f:(fun crc bit ->
        let feedback = (crc lsr 7) lxor (byte lsr (7 - bit)) land 1 in
        (crc lsl 1) land 255 lxor if feedback = 1 then 7 else 0))
  in
  String.of_char_list (List.map (body @ [ crc ]) ~f:Char.of_int_exn)
;;

let invalid bytes ~field ~value =
  [%test_result: (P.Response.t, C.Response.Decode_error.t) Result.t]
    (C.Response.decode bytes)
    ~expect:(Error (Invalid_field { field; value }))
;;

let%test_unit "every u16 survives the codec boundary without memory-size restrictions" =
  for value = 0 to 65535 do
    let bytes = C.U16.to_bytes value in
    [%test_result: int list] bytes ~expect:[ value land 255; value lsr 8 ];
    let bytes = String.of_char_list (List.map bytes ~f:Char.of_int_exn) in
    [%test_result: int] (C.U16.get bytes ~pos:0) ~expect:value;
    let request = P.Request.Write_word { address = value; word = 65535 - value } in
    assert (Result.is_ok (C.Request.encode ~tag:(value land 255) request))
  done
;;

let%test_unit "INFO capability masks and STATUS flag masks cover all u16 values" =
  for mask = 0 to 65535 do
    let check ~command ~payload ~known ~field ~all ~bit extract =
      let decoded = C.Response.decode (frame ~command ~result:0 payload) in
      if mask land known <> mask
      then
        [%test_result: (P.Response.t, C.Response.Decode_error.t) Result.t]
          decoded
          ~expect:(Error (Invalid_field { field; value = mask }))
      else (
        let response = Result.ok decoded |> Option.value_exn in
        let actual = extract response.P.Response.payload in
        let expected =
          List.filter all ~f:(fun entry -> mask land (1 lsl bit entry) <> 0)
        in
        assert (List.equal Int.equal actual (List.map expected ~f:bit)))
    in
    check
      ~command:0
      ~payload:[ 1; 0; 255; 255; mask land 255; mask lsr 8; 0; 0; 0; 0; 0; 0; 255 ]
      ~known:0x7f
      ~field:"INFO capabilities"
      ~all:P.Capability.all
      ~bit:P.Capability.bit
      (function
        | P.Response.Payload.Info info -> List.map info.capabilities ~f:P.Capability.bit
        | _ -> assert false);
    check
      ~command:1
      ~payload:[ mask land 255; mask lsr 8; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0 ]
      ~known:0xfff
      ~field:"STATUS flags"
      ~all:P.Status.Flag.all
      ~bit:P.Status.Flag.bit
      (function
        | P.Response.Payload.Status status -> List.map status.flags ~f:P.Status.Flag.bit
        | _ -> assert false)
  done
;;

let%test_unit "STATUS enum bytes distinguish every defined and undefined value" =
  for value = 0 to 255 do
    let fault = frame ~command:1 ~result:0 [ 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; value; 0 ] in
    if value > 9
    then invalid fault ~field:"STATUS fault kind" ~value
    else (
      match C.Response.decode fault with
      | Ok { payload = Status status; _ } ->
        [%test_result: int] (P.Fault_kind.to_int status.fault_kind) ~expect:value
      | _ -> assert false);
    let phase = frame ~command:1 ~result:0 [ 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; value ] in
    if value > 6
    then invalid phase ~field:"STATUS phase" ~value
    else (
      match C.Response.decode phase with
      | Ok { payload = Status status; _ } ->
        [%test_result: int] (P.Phase.to_int status.phase) ~expect:value
      | _ -> assert false)
  done
;;

let%test_unit "payload validation order precedes correlation and preserves malformed \
               errors"
  =
  let check bytes field value =
    invalid bytes ~field ~value;
    [%test_result: (P.Response.t, C.Response.Decode_error.t) Result.t]
      (C.Response.decode_correlated ~expected:{ tag = 0; command = 255 } bytes)
      ~expect:(Error (Invalid_field { field; value }))
  in
  check
    (frame ~command:0 ~result:0 [ 2; 1; 0; 0; 128; 0; 0; 0; 0; 0; 0; 0; 0 ])
    "INFO wire major"
    2;
  check
    (frame ~command:0 ~result:0 [ 1; 1; 0; 0; 128; 0; 0; 0; 0; 0; 0; 0; 0 ])
    "INFO wire minor"
    1;
  check
    (frame ~command:1 ~result:0 [ 0; 16; 0; 0; 0; 0; 0; 0; 0; 0; 10; 7 ])
    "STATUS flags"
    4096;
  check
    (frame ~command:1 ~result:0 [ 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 10; 7 ])
    "STATUS fault kind"
    10
;;

let%test_unit "every refusal answers each known command and preserves correlation" =
  List.iter [ 0x20; 0x21; 0x22; 0x23; 0x2f ] ~f:(fun result ->
    List.iter [ 0; 1; 0x10; 0x11; 0x12; 0x13; 0x14; 0x20; 0x21; 0x22 ] ~f:(fun command ->
      let bytes = frame ~command ~result [] in
      match C.Response.decode_correlated ~expected:{ tag = 0x80; command } bytes with
      | Ok response ->
        [%test_result: int] (P.Result_code.to_int response.result) ~expect:result;
        [%test_result: P.Response.Payload.t] response.payload ~expect:Empty
      | Error _ -> assert false))
;;
