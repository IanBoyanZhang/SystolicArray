// Code your testbench here
// or browse Examples

// First attempt of formal verification
`include "mat_mul_generated.v"

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
  
  wire o_done;
  // clock generation
  always #(clock_period/2) clk <= ~clk;
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1);
    en = 0;

    /*
    A_mat = {
        16'h, 16'h0000, 16'h3c00,
        16'h, 16'h0000, 16'h3c00,
        16'h, 16'h0000, 16'h3c00
    };

    B_mat = {
        16'h, 16'h0000, 16'h3c00,
        16'h, 16'h0000, 16'h3c00,
        16'h, 16'h0000, 16'h3c00
    };
    */

    A_mat = {
        16'h3c00, 16'h3c00, 16'h3c00,
        16'h3c00, 16'h3c00, 16'h3c00,
        16'h3c00, 16'h3c00, 16'h3c00
    };

    B_mat = {
        16'h3c00, 16'h3c00, 16'h3c00,
        16'h3c00, 16'h3c00, 16'h3c00,
        16'h3c00, 16'h3c00, 16'h3c00
    };

    /*
    A_mat = {
  	//1.126105
  	16'h3c81,
  	//0.407351
  	16'h3685,
  	//2.315680
  	16'h40a2,
  	//0.930338
  	16'h3b71,
  	//2.542255
  	16'h4116,
  	//1.070112
  	16'h3c48,
  	//1.107074
  	16'h3c6e,
  	//1.020977
  	16'h3c15,
  	//2.659628
  	16'h4152
    };

    B_mat = {
  	//1.435914
  	16'h3dbe,
  	//1.319322
  	16'h3d47,
  	//0.348074
  	16'h3592,
  	//1.898164
  	16'h3f98,
  	//1.588423
  	16'h3e5b,
  	//0.815995
  	16'h3a87,
  	//2.724823
  	16'h4173,
  	//0.130791
  	16'h302f,
  	//2.339815
  	16'h40ae
    };
    */

    iter_cnt = 0;
    mode = 1;
    #(clock_period);

   
    clk      = 1'b0;
    reset    = 1'b1;
    #(3 * clock_period);
    #(clock_period) reset = 0; en = 0;
    #(clock_period) reset = 0; en = 1;

    #(30 * clock_period);
    en = 0;
    $finish;
  end
  
  /*
  always @(posedge clk) begin
    iter_cnt <= iter_cnt + 1;
    if (o_done) begin
      //en <= 0;
      A_mat <= 0;
      B_mat <= 0;
    end
  end
  */
  
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

  wire [W * N * 2 - 1 : 0] debug_pe_a;
  wire [W * N * 2 - 1 : 0] debug_pe_b;

  control #(.W(W), .N(N)) control_unit(
    .i_clk(clk),
    .i_rst(reset),
    .i_en(en),
    .i_mode(mode),
    .i_A(A_mat),
    .i_B(B_mat),
    .o_C(C_mat),
    .o_done(o_done),
    .debug_pe_a(debug_pe_a),
    .debug_pe_b(debug_pe_b)
  );
endmodule
