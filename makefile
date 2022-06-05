all:
	iverilog -Wall -o tb_top.out mat_mul_tb.v
	vvp tb_top.out	

clean:
	rm -f *.out
	rm -f *.vcd
