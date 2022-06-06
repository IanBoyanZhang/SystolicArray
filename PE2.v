`ifndef PE_2_V_
`define PE_2_V_

`include "mac_unit.v"
`include "delay2.v"

`timescale 1ns / 1ps
`default_nettype none

module PE #(
  //parameter W = 32
  parameter W = 16
) (
  input  wire                 i_clk,
  input  wire                 i_rst,
  input  wire                 i_sync,  // or load?
  input  wire                 i_en,
  input  wire                 i_mode,
  input  wire [    W - 1 : 0] i_A,
  input  wire [    W - 1 : 0] i_B,
  output wire [    W - 1 : 0] o_A,
  output wire [    W - 1 : 0] o_B,
  //output wire [    W - 1 : 0] o_C
  output reg  [    W - 1 : 0] o_C
);

  //wire mode;
  //assign mode = 1;

  wire sync_load;
  assign o_A = i_A_buffered;
  assign o_B = i_B_buffered;
  assign sync_load = i_sync | i_rst | ~i_en;

  wire [W - 1 : 0] i_A_buffered;
  wire [W - 1 : 0] i_B_buffered;

  reg  [15 : 0] accu;
  wire [15 : 0] mac_out;

  // Buffered in MAC
  delay2 #(.WIDTH(W), .DEPTH(1)) delayA(.clk(i_clk), .reset(i_rst), .data_in(i_A), .data_out(i_A_buffered));
  delay2 #(.WIDTH(W), .DEPTH(1)) delayB(.clk(i_clk), .reset(i_rst), .data_in(i_B), .data_out(i_B_buffered));

  always @(posedge i_clk) begin
    if (sync_load) begin
      accu <= 1'b0;
      o_C  <= 0;
    end
    else begin
      accu <= mac_out;
      o_C  <= mac_out;
    end
  end

  // Optional: making it clocked
  mac_unit u0_mac(
    .in_a    (i_A_buffered),
    .in_b    (i_B_buffered),
    .in_c    (accu),
    .mode    (i_mode),
    .mac_out (mac_out)
  );

endmodule

`default_nettype wire
`endif
