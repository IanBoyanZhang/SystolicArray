// Code your testbench here
// or browse Examples

// First attempt of formal verification
`include "control.v"

module verification();
  
  localparam FORCED_DELAY = 5;
  localparam clock_period = 10;
  
  //bit clk, reset, en;
  reg clk, reset, en;
  reg mode;
  
  localparam W = 16;
  localparam N = 3;
  localparam BIT_MAT_DIM = W * N * N;
  reg  [    BIT_MAT_DIM - 1 : 0] A_mat;
  reg  [    BIT_MAT_DIM - 1 : 0] B_mat;
  wire [    BIT_MAT_DIM - 1 : 0] C_mat;
  
  integer iter_cnt;
  
  wire [W - 1 : 0] o_d_a00;
  wire o_done;
  // clock generation
  always #(clock_period/2) clk <= ~clk;
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1);
    en = 0;

    A_mat = {
        16'h0000, 16'h0000, 16'h3c00,
        16'h0000, 16'h0000, 16'h3c00,
        16'h0000, 16'h0000, 16'h3c00
    };

    B_mat = {
        16'h0000, 16'h0000, 16'h3c00,
        16'h0000, 16'h0000, 16'h3c00,
        16'h0000, 16'h0000, 16'h3c00
    };

    iter_cnt = 0;
    mode = 1;
    #(clock_period);

   
    clk      = 1'b0;
    reset    = 1'b1;
    #(3 * clock_period);
    #(clock_period) reset = 0; en = 0;
    #(clock_period) reset = 0; en = 1;

    #(20 * clock_period);
    en = 0;
    $finish;
  end
  
  always @(posedge clk) begin
    iter_cnt <= iter_cnt + 1;
  end
  
  /*always @(iter_cnt) begin
    if (iter_cnt > 100) begin
      assert_1 : assert (C_mat != 32'b0);
    end
    if (iter_cnt >= 350) begin
      $stop;
      $finish;
    end
  end
  */

  control #(.W(W), .N(N)) control_unit(
    .i_clk(clk),
    .i_rst(reset),
    .i_en(en),
    .i_mode(mode),
    .i_A(A_mat),
    .i_B(B_mat),
    .o_C(C_mat),
    .o_done(o_done),
    // debug
    .o_d_a00(o_d_a00)
  );
endmodule
