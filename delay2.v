`ifndef DELAY_2_V_
`define DELAY_2_V_

`timescale 1ns / 1ps
`default_nettype none

module delay2 #(
  parameter WIDTH = 16,
  parameter DEPTH = 3
) (
  input  wire                 clk,
  input  wire                 reset,
  input  wire [WIDTH - 1 : 0] data_in,
  output wire [WIDTH - 1 : 0] data_out
);

  wire [WIDTH - 1 : 0] connect_wire [DEPTH : 0];

  assign data_out        = connect_wire[DEPTH];
  assign connect_wire[0] = data_in;

  genvar i;
  generate
    for (i = 1; i <= DEPTH; i = i + 1) begin
      dff #(.WIDTH(WIDTH)) DFF(
        .clk(clk),
        .rst(reset),
        .inp(connect_wire[i-1]),
        .outp(connect_wire[i]));
    end
  endgenerate
endmodule

// D flip-flop with synchronous reset
module dff#(
    parameter WIDTH = 1
  ) (
    input wire clk,
    input wire rst,

    input wire [WIDTH-1:0] inp,
    output reg [WIDTH-1:0] outp
  );

  always @(posedge clk) begin
    outp <= rst ? 0 : inp;
  end

endmodule

`default_nettype wire
`endif
