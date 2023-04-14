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

# add wave -position end  sim:/ram_1port_testbench/clk
# add wave -position end  sim:/ram_1port_testbench/Write
# add wave -position end  sim:/ram_1port_testbench/Address
# add wave -position end  sim:/ram_1port_testbench/DataIn
# add wave -position end  sim:/ram_1port_testbench/DataOut1
# add wave -position end  sim:/ram_1port_testbench/DataOut2

# radix signal sim:/ram_1port_testbench/Address hexadecimal

# run -all