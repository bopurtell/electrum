open! Core
open! Hardcaml
open! Protemu_asic_bringup
module Sim = Cyclesim.With_interface (P0_observable.I) (P0_observable.O)

let int signal = Bits.to_int_trunc !signal

let check_output ~name signal expected =
  [%test_result: int] ~expect:expected (int signal) ~message:name
;;
