module Model = Protemu_f_model.Example_programs
module Firmware = Protemu_firmware_examples.Example_programs

let model_to_firmware (value : Model.Byte_loop.t) : Firmware.Byte_loop.t = value
let firmware_to_model (value : Firmware.Byte_loop.t) : Model.Byte_loop.t = value

let (_ : pin:int -> delay:int -> byte:int -> (Protemu_isa.Program.t, Protemu_isa.Invalid.t) result)
  = Model.uart_tx_loop

let (_ : pin:int -> delay:int -> byte:int -> (Protemu_isa.Program.t, Protemu_isa.Invalid.t) result)
  = Firmware.uart_tx_loop
