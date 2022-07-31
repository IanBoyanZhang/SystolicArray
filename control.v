`ifndef CONTROL_V_
`define CONTROL_V_

`include "delay2.v"
`include "systolic.v"

`timescale 1ns / 1ps
`default_nettype none

// Really 3x3, a done output??


// 6 logic cycles + 2 (buffered?) delay cycles
module control #(
  parameter W = 16,
  parameter N = 3
) (
  input  wire                         i_clk,
  input  wire                         i_rst,
  input  wire                         i_en,
  input  wire                         i_mode,
  input  wire [    W * N * N - 1 : 0] i_A,
  input  wire [    W * N * N - 1 : 0] i_B,
  output wire [    W * N * N - 1 : 0] o_C,
  output wire                         o_done,

  // debug
  output wire [    W * N * 2 - 1 : 0] debug_pe_a,
  output wire [    W * N * 2 - 1 : 0] debug_pe_b
);
  
  reg [3 : 0] states, next_states;

  reg  [W - 1 : 0] a00, a01, a02;
  wire [W - 1 : 0] a01_q, a02_q;

  reg  [W - 1 : 0] b00, b01, b02;
  wire [W - 1 : 0] b01_q, b02_q;

  wire [W * N - 1 : 0] A_in;
  wire [W * N - 1 : 0] B_in;
	
  assign A_in = {a02_q, a01_q, a00};
  assign B_in = {b02_q, b01_q, b00};  

  // 0000 is the idle / standby state
  always @(posedge i_clk) begin
    if (i_rst | ~i_en) begin
      states <= 4'b0000;
    end
    else if (i_en) begin
      states <= next_states;
    end
  end
  
  always @(*) begin
    if (next_states == 4'b1001) begin
      // Done: Force waiting
      // This can also be done by switching off input
      next_states = 4'b1001;
    end else begin
      next_states = states + 4'b0001;
    end
  end

  assign o_done = (states == 4'b1001);	
  
  always @(*) begin
    case (states)
      4'b0001: begin
        a00 = i_A[    W - 1 : 0 * W];
        a01 = i_A[2 * W - 1 : 1 * W];
        a02 = i_A[3 * W - 1 : 2 * W];
       
        
        b00 = i_B[    W - 1 : 0 * W];
        b01 = i_B[2 * W - 1 : 1 * W];
        b02 = i_B[3 * W - 1 : 2 * W];
      end
      4'b0010: begin
        a00 = i_A[4 * W - 1 : 3 * W];
        a01 = i_A[5 * W - 1 : 4 * W];
        a02 = i_A[6 * W - 1 : 5 * W];
  
        b00 = i_B[4 * W - 1 : 3 * W];
        b01 = i_B[5 * W - 1 : 4 * W];
        b02 = i_B[6 * W - 1 : 5 * W];
      end
      4'b0011: begin
        a00 = i_A[7 * W - 1 : 6 * W];
        a01 = i_A[8 * W - 1 : 7 * W];
        a02 = i_A[9 * W - 1 : 8 * W];
        
        b00 = i_B[7 * W - 1 : 6 * W];
        b01 = i_B[8 * W - 1 : 7 * W];
        b02 = i_B[9 * W - 1 : 8 * W];
      end
      default: begin
	a00 = 0;
	a01 = 0;
	a02 = 0;
	      
	b00 = 0;
	b01 = 0;
	b02 = 0;
      end
    endcase
  end

  systolic #(.W(W), .N(N)) sys(.i_clk(i_clk), .i_rst(i_rst), .i_en(i_en), .i_mode(i_mode), .i_A(A_in), .i_B(B_in), .o_C(o_C), .debug_pe_a(debug_pe_a), .debug_pe_b(debug_pe_b));

  delay2 #(.WIDTH(W), .DEPTH(1)) delayA1(.clk(i_clk), .reset(i_rst), .data_in(a01), .data_out(a01_q));
  delay2 #(.WIDTH(W), .DEPTH(2)) delayA2(.clk(i_clk), .reset(i_rst), .data_in(a02), .data_out(a02_q));

  delay2 #(.WIDTH(W), .DEPTH(1)) delayB1(.clk(i_clk), .reset(i_rst), .data_in(b01), .data_out(b01_q));
  delay2 #(.WIDTH(W), .DEPTH(2)) delayB2(.clk(i_clk), .reset(i_rst), .data_in(b02), .data_out(b02_q));


endmodule
`default_nettype wire
`endif
