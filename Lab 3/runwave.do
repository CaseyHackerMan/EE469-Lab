vlib work

# ALL files relevant to the testbench should be listed here. 
vlog -work work ./top.sv

vlog -work work ./arm.sv
vlog -work work ./alu.sv
vlog -work work ./reg_file.sv

vlog -work work ./imem.sv
vlog -work work ./dmem.sv

vlog -work work ./testbench.sv

# Note that the name of the testbench module is in this statement. If you're running a testbench with a different name CHANGE IT
vsim -t 1fs -novopt testbench

view signals
view wave

# This is the wave file which stores all signals you're looking at along with their radix and other settings. If you use this feature make sure the name matches
# the saved file, otherwise ignore this.
# do wave_p1.do

run -all