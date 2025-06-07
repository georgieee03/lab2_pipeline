all: sim synth verdi

compile:
	@echo "=== Compiling async_fifo + tb_async_fifo.sv ==="
	${VCS_HOME}/bin/vcs -full64 -sverilog -debug_access+all src/*.sv -kdb -lca |& tee compile.log

sim: compile
	@echo "=== Running simulation (writes fifo_tb.fsdb) ==="
	./simv -ucli +fsdbfile=waves.fsdb

verdi:
	@echo "=== Launching Verdi on fifo_tb.fsdb ==="
	${VERDI_HOME}/bin/verdi -dbdir ./simv.daidir -ssf novas.fsdb -nologo &

synth:
	@echo "=== Launching Design Compiler ==="
	dc_shell-t -f compile_dc.tcl |& tee synth.log

clean_synth:
	rm -rf *.syn *.pvl *.mr *.svf command.log  WORK rpt

clean: clean_synth
	rm -rf simv csrc simv.daidir waves.fsdb novas* *.key *.log verdi*

.PHONY: all clean clean_synth compile sim synth verdi
