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
vsim -t 5fs -novopt testbench

view signals
view wave

add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/rst
add wave -position end  sim:/testbench/cpu/processor/u_reg_file/memory
add wave -position end  sim:/testbench/cpu/processor/FlagsE
add wave -position end  sim:/testbench/cpu/processor/ALUFlags
add wave -position end  sim:/testbench/cpu/processor/StallF
add wave -position end  sim:/testbench/cpu/processor/StallD
add wave -position end  sim:/testbench/cpu/processor/FlushD
add wave -position end  sim:/testbench/cpu/processor/FlushE
add wave -position end  sim:/testbench/cpu/processor/Match
add wave -position end  sim:/testbench/cpu/processor/ForwardAE
add wave -position end  sim:/testbench/cpu/processor/ForwardBE

run -all