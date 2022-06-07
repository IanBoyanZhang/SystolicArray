`include "control.v"
module matrix_mult_top (
	input clk,
    input rst,
    
    
    input [31:0] address_in,
    output reg [31:0] address_out,
    input [31:0] data_in,
    output reg [31:0] data_out,
    input start_multiply,
    output reg done_multiply,
    output reg start_memory_transaction,
    input done_memory_transaction,
    input mode
);

    localparam W = 16;
    localparam N = 3;
 
    reg [2:0] state;
    reg [2:0] next_state;
    reg [4:0] counter;
    reg [4:0] next_counter;

    reg mode_reg;
    wire done_processing;
    reg mult_enable;
    //reg start_memory_transaction;
    
    reg [31:0] base_pointer;
    
    //wire [0 +: 2 * W * N * N] input_registers;
    wire [2 * W * N * N - 1 : 0] input_registers;
   
    wire [W * N * N - 1 : 0] A_mat, B_mat;
    reg [W * N * N - 1 : 0] C_mat_reg;
    wire [W * N * N - 1 : 0] C_mat;
    
    assign A_mat = input_registers[W * N * N - 1 : 0];
    //assign B_mat = input_registers[W * N * N +: 2 * W * N * N];
    assign B_mat = input_registers[2 * W * N * N - 1 : W * N * N];
    
    always @(posedge clk) begin
    	if(rst) begin
        	state <= 0;
            counter <= 0;
        end
        else begin
        	state <= next_state;
            counter <= next_counter;
        end
    end
    
    localparam START = 0;
    localparam LOAD0 = 1;
    localparam LOAD1 = 2;
    localparam PROCESS = 3;
    localparam STORE0 = 4;
    localparam STORE1 = 5;
    
    always @(*) begin
    	case (state)
             START: begin
            	if(start_multiply) begin
                	next_state = LOAD0;
                    base_pointer = address_in;
                    mode_reg = mode;
                    next_counter = 0;
                end
            end
         
            LOAD0: begin
            	if(counter >= 2 * N * N) begin
                	next_state = PROCESS;
                end
                else begin
            		start_memory_transaction = 1;
                	address_out = base_pointer + (4 * counter) + 0;
            		next_state = LOAD1;
                end
            end
            LOAD1: begin
            	if(done_memory_transaction) begin
                	next_state = LOAD0;
                    input_registers[counter * W +: (counter + 1) * W] = data_in; 
                	next_counter = counter + 1;
                end
            end
            PROCESS: begin
            	next_counter = 0;
                if(done_processing) begin
                	C_mat_reg = C_mat;
                	next_state = STORE0;
                    mult_enable = 0;
                end
            end
            STORE0: begin
                done_multiply = 1;
				
                if(counter >= N * N) begin
                	next_state = START;
                end
                else begin
            		start_memory_transaction = 1;
                	address_out = base_pointer + (4 * counter) + 0;
            		next_state = STORE1;
                end
            	
            end
            STORE1: begin
            	if(done_memory_transaction) begin
                	next_state = STORE0;
                    data_out = C_mat[counter * W +: (counter + 1) * W]; 
                	next_counter = counter + 1;
                end
            end
	    default: begin
		next_state = state;
            	next_counter = counter;
	    end
        endcase
    end
    
        // only valid N == 3
	control #(.W(W), .N(3)) matrix_mult_inner(
    	.i_clk(clk),
        .i_rst(rst),
        
        .i_en(mult_enable),
        .i_mode(mode_reg),
        
        .i_A(A_mat),
        .i_B(B_mat),
        .o_C(C_mat),
        
        .o_done(done_processing)
    );

endmodule
