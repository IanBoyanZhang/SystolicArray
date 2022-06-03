// Derived from Intel example
`ifndef UNSIG_ALTMULT_ACCUM_V_
`define UNSIG_ALTMULT_ACCUM_V_

`timescale 1ns / 1ps
`default_nettype none

module unsig_altmult_accum # (
  parameter W = 32
) (
  input wire [    W - 1 : 0] dataa,
  input wire [    W - 1 : 0] datab,
  input wire                 clk,
  input wire                 aclr,      // async clear
  input wire                 clken,     // clk enable
  input wire                 sload,     // sync load
  output reg [2 * W - 1 : 0] adder_out
);

  // Declare registers and wires
  reg  [2 * W - 1:0] dataa_reg;
  reg  [2 * W - 1:0] datab_reg;
  reg                sload_reg;
  reg  [2 * W - 1:0] old_result;
  wire [2 * W - 1:0] multa;

  // Store the results of the operations on the current data
  //assign multa = dataa_reg * datab_reg;
  assign multa = dataa_reg;

  // Store the value of the accumulation (or clear it)
  always @ (adder_out, sload_reg)
  begin
    if (sload_reg)
      old_result <= 0;
    else
      old_result <= adder_out;
    end

    // Clear or update data, as appropriate
    always @ (posedge clk or posedge aclr)
    begin
      if (aclr)
      begin
        dataa_reg <= 0;
        datab_reg <= 0;
        sload_reg <= 0;
        adder_out <= 0;
      end
      else if (clken)
      begin
        dataa_reg <= dataa;
        datab_reg <= datab;
        sload_reg <= sload;
        adder_out <= old_result + multa;
      end
      else begin
        dataa_reg <= 32'bz;
        datab_reg <= 32'bz;
      end
    end
endmodule

`default_nettype wire
`endif
