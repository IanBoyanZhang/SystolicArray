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
    input i_mode
);

    localparam W = 16;
    localparam N = 3;
 
    reg [2:0] state;
    reg [2:0] next_state;
    reg [4:0] counter;
    reg [4:0] next_counter;

    reg  mode_reg;
    wire done_processing;
    reg  mult_enable;
    //reg start_memory_transaction;
    
    reg [31:0] base_pointer;
    
    //wire [0 +: 2 * W * N * N] input_registers;
    reg [2 * W * N * N - 1 : 0] input_registers;
   
    wire [W * N * N - 1 : 0] A_mat, B_mat;
    reg  [W * N * N - 1 : 0] C_mat_reg;
    wire [W * N * N - 1 : 0] C_mat;
    
    assign A_mat = input_registers[W * N * N - 1 : 0];
    //assign B_mat = input_registers[W * N * N +: 2 * W * N * N];
    assign B_mat = input_registers[2 * W * N * N - 1 : W * N * N];
    
    reg mode, next_mode;
    
    always @(posedge clk) begin
    	if(rst) begin
            state <= 0;
            counter <= 0;
            mode <= 0;
            input_registers <= 0;
        end
        else begin
            state <= next_state;
            counter <= next_counter;
            mode <= next_mode;
            input_registers <= next_input_registers;
        end
    end
    
    localparam START = 0;
    localparam LOAD0 = 1;
    localparam LOAD1 = 2;
    localparam PROCESS = 3;
    localparam STORE0 = 4;
    localparam STORE1 = 5;
    
    always @(*) begin
    	next_state = state;
        next_counter = counter;
        next_input_registers = input_registers;
        next_base_pointer = base_pointer;
    	next_mode = mode;
    
    	case (state)
             START: begin
            	if(start_multiply) begin
                    next_state = LOAD0;
                    next_base_pointer = address_in;
                    next_mode = i_mode;
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
    
                    case(counter)
                    	0: begin
                            input_registers[0 * W +: W] = data_in;
                        end
                        1: begin
                            input_registers[1 * W +: W] = data_in;
                        end
                        2: begin
                            input_registers[2 * W +: W] = data_in;
                        end
                        3: begin
                            input_registers[3 * W +: W] = data_in;
                        end
                        4: begin
                            input_registers[4 * W +: W] = data_in;
                        end
                        5: begin
                            input_registers[5 * W +: W] = data_in;
                        end
                        6: begin
                            input_registers[6 * W +: W] = data_in;
                        end
                        7: begin
                            input_registers[7 * W +: W] = data_in;
                        end
                        8: begin
                            input_registers[8 * W +: W] = data_in;
                        end
                        9: begin
                            input_registers[9 * W +: W] = data_in;
                        end
                        10: begin
                            input_registers[10 * W +: W] = data_in;
                        end
                        11: begin
                            input_registers[11 * W +: W] = data_in;
                        end
                        12: begin
                            input_registers[12 * W +: W] = data_in;
                        end
                        13: begin
                            input_registers[13 * W +: W] = data_in;
                        end
                        14: begin
                            input_registers[14 * W +: W] = data_in;
                        end
                        15: begin
                            input_registers[15 * W +: W] = data_in;
                        end
                        16: begin
                            input_registers[16 * W +: W] = data_in;
                        end
                        17: begin
                            input_registers[17 * W +: W] = data_in;
                        end
                    endcase
                    
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
                    case(counter)
                    	0: begin
                            data_out = C_mat[0 * W +: W];
                        end
                        1: begin
                            data_out = C_mat[1 * W +: W];
                        end
                        2: begin
                            data_out = C_mat[2 * W +: W];
                        end
                        3: begin
                            data_out = C_mat[3 * W +: W];
                        end
                        4: begin
                            data_out = C_mat[4 * W +: W];
                        end
                        5: begin
                            data_out = C_mat[5 * W +: W];
                        end
                        6: begin
                            data_out = C_mat[6 * W +: W];
                        end
                        7: begin
                            data_out = C_mat[7 * W +: W];
                        end
                        8: begin
                            data_out = C_mat[8 * W +: W];
                        end
                    endcase
                    // data_out = C_mat[counter * W +: (counter + 1) * W]; 
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
        .i_mode(i_mode),
        
        .i_A(A_mat),
        .i_B(B_mat),
        .o_C(C_mat),
        
        .o_done(done_processing)
    );

endmodule
