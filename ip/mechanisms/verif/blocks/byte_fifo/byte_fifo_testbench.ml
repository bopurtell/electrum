open! Core
open! Hardcaml
open! Electrum_mechanisms
module Sim = Cyclesim.With_interface (Byte_fifo.I) (Byte_fifo.O)
module F_model = Electrum_f_model
module Kinds = Electrum_isa.Kinds

let bits width n = Bits.of_int_trunc ~width n

let check label signal expected =
  [%test_result: int] ~message:label ~expect:expected (Bits.to_int_trunc !signal)
;;
