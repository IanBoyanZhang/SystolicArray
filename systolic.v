`ifndef SYSTOLIC_V_
`define SYSTOLIC_V_

`include "PE.v"

`timescale 1ns / 1ps
`default_nettype none

// row
// 3 x 3
module systolic #(
  parameter W = 16,
  parameter N = 3
) (
  input  wire                         i_clk,
  input  wire                         i_rst,
  input  wire                         i_en,
  input  wire                         i_mode,
  input  wire [        W * N - 1 : 0] i_A,
  input  wire [        W * N - 1 : 0] i_B,
  output wire [    W * N * N - 1 : 0] o_C,

  // debug
  output wire [    W * N * 2 - 1 : 0] debug_pe_a,
  output wire [    W * N * 2 - 1 : 0] debug_pe_b
);

  //localparam O_VEC_WIDTH = 2 * W;
  localparam O_VEC_WIDTH = W;

  wire [W - 1 : 0] a00, a01, a02, b00, b01, b02;
  wire [W - 1 : 0] pe_a_00_01, pe_a_01_02, pe_a_10_11, pe_a_11_12, pe_a_20_21, pe_a_21_22;
  wire [W - 1 : 0] pe_b_00_10, pe_b_01_11, pe_b_02_12, pe_b_10_20, pe_b_11_21, pe_b_12_22;

  // TODO: Errors are not handled yet
  wire pe00_err, pe01_err, pe02_err, pe10_err, pe11_err, pe12_err, pe20_err, pe21_err, pe22_err;

  wire [O_VEC_WIDTH - 1 : 0] c00, c01, c02, c10, c11, c12, c20, c21, c22;

  assign a00 = i_A[0 * W +: W];
  assign a01 = i_A[1 * W +: W];
  assign a02 = i_A[2 * W +: W];

  assign b00 = i_B[0 * W +: W];
  assign b01 = i_B[1 * W +: W];
  assign b02 = i_B[2 * W +: W];

  PE #(.W(W)) PE00(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(a00),        .i_B(b00),      .o_A(pe_a_00_01),.o_B(pe_b_00_10),.o_C(c00), .o_error(pe00_err));
  PE #(.W(W)) PE01(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(pe_a_00_01), .i_B(b01),      .o_A(pe_a_01_02),.o_B(pe_b_01_11),.o_C(c01), .o_error(pe01_err));
  PE #(.W(W)) PE02(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(pe_a_01_02), .i_B(b02),      .o_A(),          .o_B(pe_b_02_12),.o_C(c02), .o_error(pe02_err));

  PE #(.W(W)) PE10(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(a01),       .i_B(pe_b_00_10),.o_A(pe_a_10_11),.o_B(pe_b_10_20),.o_C(c10), .o_error(pe10_err));
  PE #(.W(W)) PE11(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(pe_a_10_11),.i_B(pe_b_01_11),.o_A(pe_a_11_12),.o_B(pe_b_11_21),.o_C(c11), .o_error(pe11_err));
  PE #(.W(W)) PE12(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(pe_a_11_12),.i_B(pe_b_02_12),.o_A(),          .o_B(pe_b_12_22),.o_C(c12), .o_error(pe12_err));

  PE #(.W(W)) PE20(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(a02),       .i_B(pe_b_10_20),.o_A(pe_a_20_21),.o_B(),          .o_C(c20), .o_error(pe20_err));
  PE #(.W(W)) PE21(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(pe_a_20_21),.i_B(pe_b_11_21),.o_A(pe_a_21_22),.o_B(),          .o_C(c21), .o_error(pe21_err));
  PE #(.W(W)) PE22(.i_clk(i_clk),.i_rst(i_rst),.i_en(i_en), .i_mode(i_mode), .i_A(pe_a_21_22),.i_B(pe_b_12_22),.o_A(),          .o_B(),          .o_C(c22), .o_error(pe22_err));

  
  // https://stackoverflow.com/questions/18067571/indexing-vectors-and-arrays-with
  // https://standards.ieee.org/ieee/1800/6700/
  // a_vect[ 0 +: 8] // == a_vect[ 7 : 0]
  //assign o_C[1 * O_VEC_WIDTH - 1 -: O_VEC_WIDTH] = c00;
  
  assign o_C[0 * O_VEC_WIDTH +: O_VEC_WIDTH] = c00;
  assign o_C[1 * O_VEC_WIDTH +: O_VEC_WIDTH] = c01;
  assign o_C[2 * O_VEC_WIDTH +: O_VEC_WIDTH] = c02;
  assign o_C[3 * O_VEC_WIDTH +: O_VEC_WIDTH] = c10;
  assign o_C[4 * O_VEC_WIDTH +: O_VEC_WIDTH] = c11;
  assign o_C[5 * O_VEC_WIDTH +: O_VEC_WIDTH] = c12;
  assign o_C[6 * O_VEC_WIDTH +: O_VEC_WIDTH] = c20;
  assign o_C[7 * O_VEC_WIDTH +: O_VEC_WIDTH] = c21;
  assign o_C[8 * O_VEC_WIDTH +: O_VEC_WIDTH] = c22;

  assign debug_pe_a = {pe_a_00_01, pe_a_01_02, pe_a_10_11, pe_a_11_12, pe_a_20_21, pe_a_21_22};
  assign debug_pe_b = {pe_b_00_10, pe_b_01_11, pe_b_02_12, pe_b_10_20, pe_b_11_21, pe_b_12_22};

endmodule
`endif
