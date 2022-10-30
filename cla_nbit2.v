`ifndef CLA_NBIT_V_
`define CLA_NBIT_V_

`timescale 1ns / 1ps

// Carry Look-ahead adder (CLA)
// delay implications
// https://www.edaplayground.com/x/4SU9
module cla_nbit #(
  parameter n = 4
) (
  input   [n-1:0] a,
  input   [n-1:0] b,
  input           ci,
  output  [n-1:0] s,
  output          co
);

  wire [n-1:0] g;
  wire [n-1:0] p;

  /* verilator lint_off UNOPTFLAT */
  wire [  n:0] c;
  /* verilator lint_on  UNOPTFLAT */

  assign c[0] = ci;
  assign co   = c[n];

  assign g[n - 1:0] = a[n - 1 : 0] & b[n - 1:0];
  assign p[n - 1:0] = a[n - 1 : 0] | b[n - 1:0];
  assign s[n - 1:0] = a[n - 1 : 0] ^ b[n - 1:0] ^ c[n - 1 : 0];

  genvar i;  /* i - generate index variable */

  generate
    for (i = 0; i < n; i = i + 1) begin : addbit
      // https://www.embecosm.com/appnotes/ean6/html/ch07s02s07.html
      assign c[i + 1] = g[i] | (p[i] & c[i]);
    end
  endgenerate
  
endmodule
`endif
