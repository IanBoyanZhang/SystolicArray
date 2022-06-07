module matrix_mult_top (
	input clk,
    input rst,
    
    
    input [31:0] address_in,
    output [31:0] address_out,
    input [31:0] data_in,
    output [31:0] data_out,
    input start_multiply,
    output done_multiply,
    input start_memory_transaction,
    output done_memory_transaction,
    input mode,
)
	reg [2:0] state;
    reg [4:0] counter;

	reg mode_reg;
    wire done_processing;
    
    reg [31:0] base_pointer;
    
    wire [0 +: 2 * W * N * N] input_registers;
   
    wire [0 +: W * N * N] A_mat, B_mat;
    reg [0 +: W * N * N] C_mat_reg;
    
    assign A_mat = input_registers[0 +: W * N * N];
    assign B_mat = input_registers[W * N * N +: 2 * W * N * N];
    
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
        	next_state = state;
            next_counter = counter;
        
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
                    inputs_registers[counter * W +: (counter + 1) * W] = data_in; 
                	next_counter = counter + 1;
                end
            end
            PROCESS: begin
            	next_counter = 0;
                if(done_processing) begin
                	c_mat_reg = c_mat;
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
                    data_out = c_mat[counter * W +: (counter + 1) * W]; 
                	next_counter = counter + 1;
                end
            end
        endcase
    end
    
	control matrix_mult_inner(
    	.i_clk(clk),
        .i_rst(rst),
        
        .i_en(mult_enable),
        .i_mode(mode_reg),
        
        .i_A(A_mat),
        .i_B(B_mat),
        .o_C(C_mat_reg),
        
        .o_done(done_processing)
    )

endmodule
