// Code your testbench here
// or browse Examples

// First attempt of formal verification
`include "control.v"

module verification();
  
  localparam FORCED_DELAY = 5;
  localparam clock_period = 10;
  
  bit clk, reset, en;
  
  localparam W = 32;
  localparam N = 3;
  localparam BIT_MAT_DIM = W * N * N;
  reg  [    BIT_MAT_DIM - 1 : 0] A_mat;
  reg  [    BIT_MAT_DIM - 1 : 0] B_mat;
  wire [2 * BIT_MAT_DIM - 1 : 0] C_mat;
  
  integer iter_cnt;
  
  wire o_d_a00;
  // clock generation
  always #(clock_period/2) clk <= ~clk;
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1);

    A_mat = {
        32'hffffffff, 32'hffffffff, 32'hffffffff,
        32'hffffffff, 32'hffffffff, 32'hffffffff,
        32'hffffffff, 32'hffffffff, 32'hffffffff
    };

    B_mat = {
        32'hffffffff, 32'hffffffff, 32'hffffffff,
        32'hffffffff, 32'hffffffff, 32'hffffffff,
        32'hffffffff, 32'hffffffff, 32'hffffffff
    };
    #(clock_period);
    iter_cnt = 0;    
    clk      = 1'b1;
    reset    = 1'b1;
    #(10 * clock_period);
    #(clock_period) reset = 0; en = 0;
    #(clock_period) reset = 0; en = 1;
    
    //C_mat = 32'b0;
    
//     #(FORCED_DELAY * CLK_INT_2) assert_1: assert (C_mat != 32'b0);
  end
  
  always @(posedge clk) begin
    iter_cnt <= iter_cnt + 1;
  end
  
  always @(iter_cnt) begin
    if (iter_cnt > 100) begin
      assert_1 : assert (C_mat != 32'b0);
    end
    if (iter_cnt == 350) begin
      $stop;
    end
  end
  
  control #(.W(W), .N(N)) control_unit(
    .i_clk(clk),
    .i_rst(reset),
    .i_en(en),
    .i_A(A_mat),
    .i_B(B_mat),
    .o_C(C_mat),
    // debug
    .o_d_a00(o_d_a00)
  );
endmodule
