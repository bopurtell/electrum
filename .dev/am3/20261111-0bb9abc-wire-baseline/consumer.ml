module P = Host_link_protocol
module W = Protemu_host_link_wire.Wire

(* These assignments must compile without conversion across the installed packages. *)
let request : P.Request.t = W.Request.Write_word { address = 0xff; word = 0xbeef }
let old_request : W.Request.t = P.Request.Verify_word { address = 1; expected = 2 }
let encode_error (e : W.Request.Encode_error.t) : P.Codec.Request.Encode_error.t = e
let decode_error (e : P.Codec.Response.Decode_error.t) : W.Response.Decode_error.t = e
let response (r : W.Response.t) : P.Response.t = r
let payload (p : P.Response.Payload.t) : W.Response.Payload.t = p
let correlation (c : P.Correlation.t) : W.Correlation.t = c
let shape (s : W.Response.shape) : P.Response.shape = s

let () =
  let expected_request = "\xa5\x10\x03\x11\x04\x00\xff\x00\xef\xbe\x1a" in
  assert (P.Codec.Request.encode ~tag:3 request = Ok expected_request);
  assert (W.Request.encode ~tag:3 request = Ok expected_request);
  assert (P.Codec.Crc.compute "123456789" = 0xf4);
  assert (P.Crc.polynomial = 7 && P.Crc.length = 1 && P.U16.max = 65535);
  assert (P.Codec.U16.to_bytes 0xabcd = [ 0xcd; 0xab ]);
  assert (P.Codec.U16.get "\xcd\xab" ~pos:0 = 0xabcd);
  let invalid = P.Request.Write_word { address = -1; word = 65536 } in
  let error field value max =
    Error (P.Codec.Request.Encode_error.Out_of_range { field; value; max })
  in
  assert (P.Codec.Request.encode ~tag:256 invalid = error "tag" 256 255);
  assert (P.Codec.Request.encode ~tag:0 invalid = error "address" (-1) 65535);
  assert
    (encode_error (W.Request.Encode_error.Out_of_range { field = "tag"; value = 256; max = 255 })
     = P.Codec.Request.Encode_error.Out_of_range { field = "tag"; value = 256; max = 255 });
  let body = "\x5a\x10\x42\x12\x00\x02\x00\x34\x12" in
  let frame = body ^ String.make 1 (Char.chr (P.Codec.Crc.compute body)) in
  let expected : P.Response.t =
    { tag = 0x42; command = 0x12; result = P.Result_code.Complete
    ; payload = P.Response.Payload.Word 0x1234 }
  in
  assert (P.Codec.Response.decode frame = Ok expected);
  assert (W.Response.decode frame = Ok (response expected));
  let expected_correlation = P.Request.correlation ~tag:0x43 P.Request.Info in
  let mismatch : W.Response.Decode_error.t =
    decode_error
      (P.Codec.Response.Decode_error.Correlation_mismatch
         { expected = expected_correlation; response = expected })
  in
  assert (P.Codec.Response.decode_correlated ~expected:expected_correlation frame = Error mismatch);
  assert
    (P.Codec.Response.decode "" =
     Error (P.Codec.Response.Decode_error.Truncated { expected = 8; actual = 0 }));
  assert
    (P.Codec.Response.decode "\x00\x00\x00\x00\x00\xff\xff\x00" =
     Error (P.Codec.Response.Decode_error.Bad_magic 0));
  (* Retained helper APIs also accept the canonical types. *)
  assert (W.Request.payload_fields old_request = P.Codec.Request.payload_fields old_request);
  assert (shape W.Response.Word_payload = P.Response.Word_payload);
  assert (payload expected.payload = W.Response.Payload.Word 0x1234);
  assert (correlation (P.Response.correlation expected) = W.Response.correlation expected);
  print_endline "AM3 installed canonical/shim constructors, errors, vectors and type identity: PASS"
