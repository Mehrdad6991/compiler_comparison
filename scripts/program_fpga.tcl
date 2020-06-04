set bitstream /home/mehrdad/RISC-V/pulpissimo/pulpissimo/pulpissimo_genesys2.bit

open_hw
connect_hw_server
open_hw_target [lindex [get_hw_targets] 1]
set_property PROGRAM.FILE $bitstream [current_hw_device]
program_hw_devices
