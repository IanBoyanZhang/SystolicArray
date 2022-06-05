`ifndef CONTROL_V_
`define CONTROL_V_

`include "delay2.v"
`include "systolic.v"

`timescale 1ns / 1ps
`default_nettype none

// Really 3x3, a done output??

module control #(
  parameter W = 32,
  parameter N = 3
) (
  input  wire                         i_clk,
  input  wire                         i_rst,
  input  wire                         i_en,
  input  wire                         i_mode,
  input  wire [    W * N * N - 1 : 0] i_A,
  input  wire [    W * N * N - 1 : 0] i_B,
  output wire [    W * N * N - 1 : 0] o_C,
  // debug
  output wire [    W - 1 : 0] o_d_a00
);
  
  reg [2 : 0] states, next_states;

  wire [W * N - 1 : 0] A_in;
  wire [W * N - 1 : 0] B_in;


  reg  [W - 1 : 0] a00, a10, a20;
  wire [W - 1 : 0] a10_q, a20_q;

  reg  [W - 1 : 0] b00, b01, b02;
  wire [W - 1 : 0] b01_q, b02_q;

  assign A_in = {a20_q, a10_q, a00};
  assign B_in = {b02_q, b01_q, b00};  

  // fix the 
  always @(posedge i_clk) begin
    if (i_rst) begin
      states <= 3'b000;
    end
    else begin
      states <= next_states;
    end
  end

  reg sync;
  
  always @(*) begin
    if (next_states == 3'b101) begin
      next_states = 3'b000;
      // Force to sync after computation
      sync = 1'b1;
    end else begin
      next_states = states + 1;
    end
  end
  
  always @(*) begin
    case (states)
      3'b000: begin
        a00 = i_A[    W - 1 : 0 * W];
        a10 = i_A[2 * W - 1 : 1 * W];
        a20 = i_A[3 * W - 1 : 2 * W];
       
        
        b00 = i_B[    W - 1 : 0 * W];
        b01 = i_B[2 * W - 1 : 1 * W];
        b02 = i_B[3 * W - 1 : 2 * W];
      end
      3'b001: begin
        a00 = i_A[4 * W - 1 : 3 * W];
        a10 = i_A[5 * W - 1 : 4 * W];
        a20 = i_A[6 * W - 1 : 5 * W];
  
        b00 = i_B[4 * W - 1 : 3 * W];
        b01 = i_B[5 * W - 1 : 4 * W];
        b02 = i_B[6 * W - 1 : 5 * W];
      end
      3'b010: begin
        a00 = i_A[7 * W - 1 : 6 * W];
        a10 = i_A[8 * W - 1 : 7 * W];
        a20 = i_A[9 * W - 1 : 8 * W];
        
        b00 = i_B[7 * W - 1 : 6 * W];
        b01 = i_B[8 * W - 1 : 7 * W];
        b02 = i_B[9 * W - 1 : 8 * W];
      end
      default: begin
      end
    endcase
  end

  systolic #(.W(W), .N(N)) sys(.i_clk(i_clk), .i_rst(i_rst), .i_en(i_en), i_mode(i_mode), .i_sync(sync), .i_A(A_in), .i_B(B_in), .o_C(o_C),
                               .d_a00(o_d_a00)
                              );

  delay2 #(.WIDTH(W), .DEPTH(1)) delayA1(.clk(i_clk), .reset(i_rst), .data_in(a10), .data_out(a10_q));
  delay2 #(.WIDTH(W), .DEPTH(2)) delayA2(.clk(i_clk), .reset(i_rst), .data_in(a20), .data_out(a20_q));

  delay2 #(.WIDTH(W), .DEPTH(1)) delayB1(.clk(i_clk), .reset(i_rst), .data_in(b01), .data_out(b01_q));
  delay2 #(.WIDTH(W), .DEPTH(2)) delayB2(.clk(i_clk), .reset(i_rst), .data_in(b02), .data_out(b02_q));


endmodule
`default_nettype wire
`endif
