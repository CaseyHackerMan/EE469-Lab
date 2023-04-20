vlib work

vlog -work work ./reg_file.sv
vlog -work work ./alu.sv
vlog -work work ./top.sv
vlog -work work ./testbench.sv
vlog -work work ./imem.sv
vlog -work work ./dmem.sv
vlog -work work ./arm.sv

# Note that the name of the testbench module is in this statement. If you're running a testbench with a different name CHANGE IT
vsim -t 1ps -novopt testbench -L unisim -L secureip -L unifast -L unimacro -Lf altera_mf_ver

view signals
view wave

add wave -position end  sim:/testbench/cpu/clk
add wave -position end  sim:/testbench/cpu/rst
add wave -position end  sim:/testbench/cpu/PC
add wave -position end  sim:/testbench/cpu/Instr
add wave -position end  sim:/testbench/cpu/ALUResult
add wave -position end  sim:/testbench/cpu/WriteData
add wave -position end  sim:/testbench/cpu/MemWrite
add wave -position end  sim:/testbench/cpu/ReadData
add wave -position end  sim:/testbench/cpu/processor/u_reg_file/memory

radix signal sim:/testbench/cpu/ReadData hexadecimal
radix signal sim:/testbench/cpu/WriteData hexadecimal
radix signal sim:/testbench/cpu/PC hexadecimal
radix signal sim:/testbench/cpu/ALUResult hexadecimal
radix signal sim:/testbench/cpu/processor/u_reg_file/memory hexadecimal

run -all