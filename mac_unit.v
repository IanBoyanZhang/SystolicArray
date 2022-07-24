// No pipelined/piplined MAC
// Version: 1.0

// Description:

// Function : mac_out = in_a * in_b + in_c.  Both work for INT8 and FP16 mode. Default INT8 and FP16 are signed number
// Exception : error detection for overflow and underflow in FP16 mode
`ifndef MAC_UNIT_V_
`define MAC_UNIT_V_

`include "int_fp_add.v"
`include "int_fp_mul.v"

`timescale 1ns / 1ps

module mac_unit
(
`ifdef PIPELINE
  input            clk,
  input            rst_n,
`endif
  input     [15:0] in_a, // multiplier input1
  input     [15:0] in_b, // multiplier input2
  input     [15:0] in_c, // adder input2 ; adder input1 = in_a*in_b
  input 	   mode,
  //output    [15:0] mac_out,
  output    [15:0] mac_out,
  output 	   error
);

  wire [15:0] mul_out;

  int_fp_add add(
  `ifdef PIPELINE
    .clk   (clk    ),
    .rst_n (rst_n  ),
  `endif 
    .mode  (mode   ),
    .a     (mul_out),
    .b     (in_c   ),
    .c     (mac_out)
  );

  int_fp_mul mul(
  `ifdef PIPELINE
    .clk   (clk    ),
    .rst_n (rst_n  ),
  `endif 
    .mode  (mode   ),
    .a     (in_a   ),
    .b     (in_b   ),
    .c     (mul_out),
    .error (error  )
  );

endmodule
`endif
