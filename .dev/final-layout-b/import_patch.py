"""Print an apply_patch patch; never writes source files."""
from pathlib import Path
import difflib
import re

ROOT = Path(__file__).resolve().parents[2]
OWNERS = {
    "Protemu_mechanisms": ["Byte_fifo", "Input_events", "Pin_bank", "Shift_lane", "Timing"],
    "Protemu_mechanisms_staging": ["Observed_transfer", "Observed_transfer_bank", "Primitive_demo", "Uart_tx", "Uart_slice"],
    "Protemu_controller": ["Program_memory_controller"],
    "Protemu_core": ["Control_port", "Emulator_core", "Execution_unit", "Instruction_decoder", "Primitive_dispatch"],
    "Protemu_core_legacy": ["Executable_core"],
    "Protemu_host_link": ["Command_dispatch", "Frame_rx", "Frame_tx", "Host_link", "Serial_phy", "Wire_crc", "Wire_layout"],
    "Protemu_system": ["Protemu_top"],
    "Protemu_asic_bringup": ["P0_observable"],
}
PATHS = {
    "test/core/control_execution/": "ip/emulator_core/verif/execution/",
    "test/core/protocol_core/": "ip/program_memory_controller/verif/controller/",
    "test/integration/uart_slice/": "ip/mechanisms/verif/staging/uart_slice/",
    "test/integration/observed_transfer_bank/": "ip/mechanisms/verif/staging/observed_transfer_bank/",
    "test/core/control_port/": "ip/emulator_core/verif/control_port/",
    "test/integration/host_simulator": "software/simulator/test",
    "test/common/": "verif/common/test/",
    "test/verification_support/": "verif/common/test/",
    "lib/emulator_core/control_port.ml": "ip/emulator_core/rtl/control_port.ml",
}


def emit(p, old, new):
    if old == new:
        return
    print("*** Update File: " + str(p))
    for line in list(difflib.unified_diff(old.splitlines(), new.splitlines(), n=3, lineterm=""))[2:]:
        print("@@" if line.startswith("@@") else line)


print("*** Begin Patch")
paths = sorted(ROOT.glob("ip/*/verif/**/*.ml")) + sorted(ROOT.glob("ip/*/verif/**/dune"))
paths += [ROOT / "software/simulator/simulator_backend.ml", ROOT / "software/simulator/test/host_simulator_tests.ml"]
for p in paths:
    relative = str(p.relative_to(ROOT))
    if "/archived/" in relative or "/emit/" in relative:
        continue
    old = p.read_text()
    new = old
    if p.name == "dune":
        if "hardcaml_protemu" in old:
            if relative.startswith("ip/mechanisms/verif/blocks/"):
                libs = "protemu_mechanisms"
            elif relative.startswith("ip/mechanisms/verif/staging/"):
                libs = "protemu_mechanisms protemu_mechanisms_staging"
            elif relative.startswith("ip/program_memory_controller/"):
                libs = "protemu_controller"
            elif "/execution/" in relative:
                libs = "protemu_controller protemu_core protemu_core_legacy"
            elif relative.startswith("ip/emulator_core/"):
                libs = "protemu_mechanisms protemu_controller protemu_core"
            else:
                libs = "protemu_mechanisms protemu_core protemu_host_link"
            new = new.replace("hardcaml_protemu", libs)
    else:
        if "open! Hardcaml_protemu" in new:
            libs = [lib for lib, modules in OWNERS.items() if any(re.search(r"\b" + name + r"\b", old) for name in modules)]
            new = new.replace("open! Hardcaml_protemu\n", "".join("open! " + lib + "\n" for lib in libs))
        for lib, modules in OWNERS.items():
            for module in modules:
                new = new.replace("Hardcaml_protemu." + module, lib + "." + module)
    for old_path, new_path in PATHS.items():
        new = new.replace(old_path, new_path)
    # These three fixtures exercise the actual executable command after alias retirement.
    for old_dir, new_dir in [
        ("test/core/control_execution", "ip/emulator_core/verif/execution"),
        ("test/core/protocol_core", "ip/program_memory_controller/verif/controller"),
        ("test/integration/uart_slice", "ip/mechanisms/verif/staging/uart_slice"),
    ]:
        new = new.replace(old_dir, new_dir)
    new = new.replace("test/primitives/input_events --force", "ip/mechanisms/verif/blocks/input_events --force")
    new = new.replace("test/primitives/input_events/", "ip/mechanisms/verif/blocks/input_events/")
    emit(p, old, new)
print("*** End Patch")
