all:
	make clean
	python3 codegen/concat_files.py
	iverilog -Wall -o tb_top.out testbenches/mat_mul_tb.v
	vvp tb_top.out
	gtkwave dump.vcd --script=add_waves.tcl	

clean:
	rm -f *.out
	rm -f *.vcd
