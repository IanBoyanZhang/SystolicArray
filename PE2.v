`ifndef PE_2_V_
`define PE_2_V_

`include "unsig_altmult_accum.v"
`include "delay2.v"

`timescale 1ns / 1ps
`default_nettype none

module PE #(
  parameter W = 32
) (
  input  wire                 i_clk,
  input  wire                 i_rst,
  input  wire                 i_sync,
  input  wire                 i_en,
  input  wire [    W - 1 : 0] i_A,
  input  wire [    W - 1 : 0] i_B,
  output wire [    W - 1 : 0] o_A,
  output wire [    W - 1 : 0] o_B,
  output wire [2 * W - 1 : 0] o_C
);

  wire sync_load;
  assign o_A = i_A;
  assign o_B = i_B;
  assign sync_load = i_sync | i_rst;
  
  wire [W - 1 : 0] i_A_buffered;
  wire [W - 1 : 0] i_B_buffered;

  // Buffered in MAC
  delay2 #(.WIDTH(W), .DEPTH(1)) delayA(.clk(i_clk), .reset(i_rst), .data_in(i_A), .data_out(i_A_buffered));
  delay2 #(.WIDTH(W), .DEPTH(1)) delayB(.clk(i_clk), .reset(i_rst), .data_in(i_B), .data_out(i_B_buffered));
  
  // Fix
  unsig_altmult_accum #(.W(W)) u_mac(
    .dataa(i_A_buffered),
    .datab(i_B_buffered),
    .clk(i_clk),
    .aclr(i_rst),
    .clken(i_en),
    .sload(sync_load),
    .adder_out(o_C)
  );

endmodule

`default_nettype wire
`endif
