open! Core
module P = Host_link_protocol
module W = Electrum_host_link_wire.Wire

let%test_unit "legacy facade and canonical API share types in both directions" =
  let request : P.Request.t = W.Request.Verify_word { address = 256; expected = 65535 } in
  let legacy_request : W.Request.t = request in
  let correlation : P.Correlation.t = W.Request.correlation ~tag:255 legacy_request in
  let legacy_correlation : W.Correlation.t = correlation in
  let payload : P.Response.Payload.t = W.Response.Payload.Word 65535 in
  let legacy_payload : W.Response.Payload.t = payload in
  let response : P.Response.t =
    { W.Response.tag = 255
    ; command = 0x13
    ; result = Verification_mismatch
    ; payload = legacy_payload
    }
  in
  let legacy_response : W.Response.t = response in
  let error : P.Codec.Response.Decode_error.t =
    W.Response.Decode_error.Correlation_mismatch
      { expected = legacy_correlation; response = legacy_response }
  in
  let legacy_error : W.Response.Decode_error.t = error in
  let encode_error : P.Codec.Request.Encode_error.t =
    W.Request.Encode_error.Out_of_range { field = "tag"; value = 256; max = 255 }
  in
  let legacy_encode_error : W.Request.Encode_error.t = encode_error in
  assert (P.Request.equal request legacy_request);
  assert (P.Response.equal response legacy_response);
  assert (P.Codec.Response.Decode_error.equal error legacy_error);
  assert (P.Codec.Request.Encode_error.equal encode_error legacy_encode_error)
;;
