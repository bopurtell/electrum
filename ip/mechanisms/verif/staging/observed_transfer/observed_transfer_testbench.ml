open! Core
open! Hardcaml
open! Protemu_mechanisms
open! Protemu_mechanisms_staging
module Shift_sim = Cyclesim.With_interface (Shift_lane.I) (Shift_lane.O)
module Observed_sim = Cyclesim.With_interface (Observed_transfer.I) (Observed_transfer.O)
module F_model = Protemu_f_model
module Kinds = Protemu_isa.Kinds

let bits width n = Bits.of_int_trunc ~width n

let check label signal expected =
  [%test_result: int] ~message:label ~expect:expected (Bits.to_int_trunc !signal)
;;
