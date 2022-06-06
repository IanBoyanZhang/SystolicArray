all:
	make clean
	iverilog -Wall -o tb_top.out mat_mul_tb.v
	vvp tb_top.out
	gtkwave dump.vcd --script=add_waves.tcl	

clean:
	rm -f *.out
	rm -f *.vcd
