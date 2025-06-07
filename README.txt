
Directory layout
----------------
src/          – all SystemVerilog source files for the pipelined MIPS core  
sim/          – testbench and memfile.dat (fill memfile.dat with your program)  
synthesis/    – top_with_sram.sv, compile_with_sram.tcl, and placeholder SRAM models  

Build & simulate (Icarus Verilog example)
-----------------------------------------
    make            # compiles src + sim and runs testbench
    make clean

Replace `memfile.dat` in sim/ with your assembled program to test other cases.
