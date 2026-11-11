#!/usr/bin/env python3
"""Temporary external build fixture; no old implementation enters the source tree."""
import hashlib
import os
import re
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[3]
baseline = Path(__file__).resolve().parent
snapshot = (baseline / "wire.ml").read_bytes()
assert hashlib.sha256(snapshot).hexdigest() == "23b46d8a57f5bd7ee7e36ce15221f7bbcf1d1c297f18b256bc2e8d6c515dcb9f"
prefix = ["flock", "/home/wayne/devel/jane/.protemu-build.lock", "opam", "exec", "--switch=5.2.0+ox", "--"]

def run(args, cwd, **kwargs):
    return subprocess.run(prefix + args, cwd=cwd, check=True, text=True, **kwargs)

# Verify every character of the fixed-vector test after reversing only API edits.
original = subprocess.check_output(["git", "show", "0bb9abc:test/host_link_wire/wire_tests.ml"], cwd=root, text=True)
migrated = (root / "test/host_link_protocol/wire_tests.ml").read_text()
restored = migrated.replace("module Wire = Host_link_protocol\nmodule Codec = Wire.Codec", "module Wire = Protemu_host_link_wire.Wire")
restored = restored.replace("Codec.Request.", "Request.").replace("Codec.Response.", "Response.").replace("Codec.Crc.", "Wire.Crc.")
restored = restored.replace("module Decode_error = Response.Decode_error", "module Decode_error = Wire.Response.Decode_error")
def without_formatting(text):
    # Preserve every byte inside string literals, including all independent vectors.
    return re.sub(r'"(?:\\.|[^"\\])*"|\s+', lambda match: match[0] if match[0].startswith('"') else '', text)

assert without_formatting(restored) == without_formatting(original), "Fixed tests changed beyond canonical API paths/formatting"
assert original.count("let%test_unit") == 26
print("PASS: all 26 fixed tests preserved exactly modulo API paths/formatting; string literals byte-identical", flush=True)

run(["dune", "build", "@install", "-j5"], root)
env = dict(os.environ, OCAMLPATH=str(root / "_build/install/default/lib"))
closure = run(["ocamlfind", "query", "-recursive", "-format", "%p", "hardcaml_protemu.host_link_protocol"], root, env=env, capture_output=True).stdout
for name in closure.splitlines():
    assert not any(word in name.lower() for word in ["hardcaml", "asic", "simulator", "agent", "verification"]) or name == "hardcaml_protemu.host_link_protocol", name
print("PASS: canonical installed dependency closure contains no hardware/agent dependencies", flush=True)

runner = r'''
module NAME = struct
  module P = PROTOCOL
  module C = CODEC
  let encode ~tag ~kind ~a ~b =
    let request : P.Request.t =
      match kind with
      | 0 -> Info | 1 -> Status | 2 -> Load_start { length = a }
      | 3 -> Write_word { address = a; word = b } | 4 -> Read_word { address = a }
      | 5 -> Verify_word { address = a; expected = b } | 6 -> Load_complete
      | 7 -> Run | 8 -> Stop | _ -> Abort
    in
    [%sexp_of: (string, C.Request.Encode_error.t) Result.t] (C.Request.encode ~tag request)
  let decode bytes =
    [%sexp_of: (P.Response.t, C.Response.Decode_error.t) Result.t] (C.Response.decode bytes)
  let correlated bytes tag command =
    [%sexp_of: (P.Response.t, C.Response.Decode_error.t) Result.t]
      (C.Response.decode_correlated ~expected:{ tag; command } bytes)
end
'''
main = r'''
let counts = Hashtbl.create (module String)
let check category context old_result new_result =
  if not (Sexp.equal old_result new_result)
  then failwith (category ^ " " ^ context ^ "\nold=" ^ Sexp.to_string old_result ^ "\nnew=" ^ Sexp.to_string new_result);
  Hashtbl.update counts category ~f:(function None -> 1 | Some n -> n + 1)
let encode tag kind a b =
  check "request" (sprintf "%d/%d/%d/%d" tag kind a b)
    (Old.encode ~tag ~kind ~a ~b) (New.encode ~tag ~kind ~a ~b)
let decode category bytes =
  check category (String.escaped bytes) (Old.decode bytes) (New.decode bytes)
let correlated bytes tag command =
  check "correlated" (sprintf "%s/%d/%d" (String.escaped bytes) tag command)
    (Old.correlated bytes tag command) (New.correlated bytes tag command)
let bytes values = String.of_char_list (List.map values ~f:Char.of_int_exn)
(* Independent bit-serial CRC and literal envelope, shared input, separate decoders. *)
let frame command result payload =
  let body = [90; 16; 128; command; result; List.length payload; 0] @ payload in
  let crc = List.fold body ~init:0 ~f:(fun crc byte ->
    List.fold (List.init 8 ~f:Fn.id) ~init:crc ~f:(fun crc bit ->
      let feedback = ((crc lsr 7) lxor (byte lsr (7-bit))) land 1 in
      ((crc lsl 1) land 255) lxor (if feedback = 1 then 7 else 0))) in
  bytes (body @ [crc])
let () =
  let edges = [Int.min_value; -65536; -1; 0; 1; 255; 256; 65535; 65536; Int.max_value] in
  List.iter edges ~f:(fun tag ->
    for kind = 0 to 9 do
      List.iter edges ~f:(fun a -> List.iter edges ~f:(fun b -> encode tag kind a b))
    done);
  for value = 0 to 65535 do
    for kind = 2 to 5 do encode (value land 255) kind value (65535-value) done
  done;
  for command = 0 to 255 do
    for result = 0 to 255 do
      for length = 0 to 14 do
        let payload = List.init length ~f:(fun i -> if command = 0 && i = 0 then 1 else 0) in
        let input = frame command result payload in
        decode "command-result-length" input;
        (* Correct and incorrect correlation, including unknown echoed commands. *)
        if length = 0 || length = 2 || length = 12 || length = 13 then (
          correlated input 128 command;
          correlated input 127 command;
          correlated input 128 ((command+1) land 255))
      done
    done
  done;
  for mask = 0 to 65535 do
    decode "capability-mask" (frame 0 0 [1;0;255;255;mask land 255;mask lsr 8;255;255;255;255;255;255;255]);
    decode "status-mask" (frame 1 0 [mask land 255;mask lsr 8;255;255;255;255;255;255;255;255;0;0])
  done;
  for value = 0 to 255 do
    decode "fault-enum" (frame 1 0 [0;0;0;0;0;0;0;0;0;0;value;0]);
    decode "phase-enum" (frame 1 0 [0;0;0;0;0;0;0;0;0;0;0;value]);
    decode "info-major" (frame 0 0 [value;0;0;0;0;0;0;0;0;0;0;0;0]);
    decode "info-minor" (frame 0 0 [1;value;0;0;0;0;0;0;0;0;0;0;0])
  done;
  let seeds = [frame 0 0 [1;0;1;1;127;0;16;0;0;1;4;0;8];
    frame 1 0 [255;15;0;1;255;0;128;0;52;18;9;6]; frame 18 0 [239;190];
    frame 19 36 [52;18]; frame 33 1 []; frame 126 20 []; frame 0 21 [];
    (* Multiple simultaneous failures exercise first-error precedence. *)
    bytes [0;0;0;0;2;255;255;0];
    frame 0 0 [2;1;0;0;128;0;0;0;0;0;0;0;0];
    frame 1 0 [0;16;0;0;0;0;0;0;0;0;10;7]] in
  List.iter seeds ~f:(fun seed ->
    for length = 0 to String.length seed do decode "truncation" (String.prefix seed length) done;
    decode "extra" (seed ^ "\000");
    for pos = 0 to String.length seed - 1 do
      for value = 0 to 255 do
        let changed = Bytes.of_string seed in
        Bytes.set changed pos (Char.of_int_exn value);
        let input = Bytes.to_string changed in
        decode "single-byte-mutation" input;
        correlated input 0 255
      done
    done);
  Hashtbl.to_alist counts |> List.sort ~compare:(fun (a,_) (b,_) -> String.compare a b)
  |> List.iter ~f:(fun (name,count) -> printf "PASS %s: %d comparisons\n" name count)
'''

with tempfile.TemporaryDirectory(prefix="am3-pure-", dir="/tmp/opencode") as directory:
    fixture = Path(directory)
    (fixture / "dune-project").write_text("(lang dune 3.17)\n")
    (fixture / "baseline_wire.ml").write_bytes(snapshot)
    old = runner.replace("NAME", "Old").replace("PROTOCOL", "Baseline_wire").replace("CODEC", "Baseline_wire")
    new = runner.replace("NAME", "New").replace("PROTOCOL", "Host_link_protocol").replace("CODEC", "Host_link_protocol.Codec")
    (fixture / "main.ml").write_text("open! Core\n" + old + new + main)
    (fixture / "dune").write_text("(executable (name main) (modules main baseline_wire) (libraries core hardcaml_protemu.host_link_protocol) (preprocess (pps ppx_jane)))\n")
    run(["dune", "exec", "./main.exe", "-j5"], fixture, env=env)
    # Compile-negative API probes check the public root AND actual Definitions module.
    probes = ["Crc.compute", "Crc.update", "U16.to_bytes", "U16.get", "Request.encode", "Request.payload_fields", "Response.decode", "Response.decode_correlated", "Response.decode_info", "Response.decode_status", "Response.decode_bits", "Response.decode_enum", "Response.invalid_field"]
    (fixture / "dune").write_text("(executable (name probe) (modules probe) (libraries core hardcaml_protemu.host_link_protocol))\n")
    (fixture / "probe.ml").write_text("let _ = Host_link_protocol.Request.Info\nlet _ = Host_link_protocol.Codec.Request.encode ~tag:0 Host_link_protocol.Request.Info\n")
    run(["dune", "build", "probe.exe", "-j5"], fixture, env=env)
    for namespace in ["Host_link_protocol", "Host_link_protocol__Definitions"]:
        for probe in probes:
            (fixture / "probe.ml").write_text(f"let _ = {namespace}.{probe}\n")
            result = subprocess.run(prefix + ["dune", "build", "probe.exe", "-j5"], cwd=fixture, env=env, text=True, capture_output=True)
            assert result.returncode != 0 and "Unbound value" in result.stderr, (namespace, probe, result.stderr)
        for module in ["Request.Encode_error", "Response.Decode_error"]:
            (fixture / "probe.ml").write_text(f"type t = {namespace}.{module}.t\n")
            result = subprocess.run(prefix + ["dune", "build", "probe.exe", "-j5"], cwd=fixture, env=env, text=True, capture_output=True)
            assert result.returncode != 0 and "Unbound module" in result.stderr, (namespace, module, result.stderr)
    print("PASS: installed pure canonical consumer; 30 compile-negative codec/error API boundary probes", flush=True)
