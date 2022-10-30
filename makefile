all:
	make clean
	make concat
	iverilog -Wall -o tb_top.out testbenches/mat_mul_tb.v
	vvp tb_top.out
	gtkwave dump.vcd --script=add_waves.tcl	

concat:
	python3 codegen/concat_files.py

veri_gen:
	make clean
	make concat
	verilator --cc mat_mul_generated.v

clean:
	rm -f *.out
	rm -f *.vcd
	rm -f ./mat_mul_generated.v
	rm -rf obj_dir/ 
