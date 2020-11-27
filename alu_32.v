`timescale 1ns / 1ps
module alu_32(
    input [31:0] A_in, B_in,
    input [3:0] ALU_Sel,
    output [31:0] ALU_Out,
    output reg Carry_Out,
    output Zero,
    output reg Overflow = 1'b0
    );
reg [ 31 : 0 ] ALU_Result ;
reg [ 32 : 0 ] temp ;
reg [ 32 : 0 ] twos_com ; // to hold 2 'sc of second source of ALU

assign ALU_Out = ALU_Result ; // ALU Out
assign Zero = ( ALU_Result == 0); // Zero Flag
    
always @ (*)
    begin
        Overflow = 1'b0;
        Carry_Out = 1'b0;
        case ( ALU_Sel )
            4'b0000 : // and
                ALU_Result = A_in & B_in ;

            4'b0001 : // or
                ALU_Result = A_in | B_in ;

            4'b0010 : // Signed Addition with Overflow and Carry_out checking
                begin
                    ALU_Result = $signed ( A_in ) + $signed ( B_in );
                    temp = {1'b0 , A_in } + {1'b0 , B_in };
                    Carry_Out = temp [ 32 ] ;
                    if (( A_in [ 31 ] & B_in [ 31 ] & ~ ALU_Out [ 31 ] ) |
                    (~ A_in [ 31 ] & ~ B_in [ 31 ] & ALU_Out [ 31 ] ))
                        Overflow = 1'b1;
                    else
                        Overflow = 1'b0;
                end
                
            4'b0110 : // Signed Subtraction with Overflow checking
                begin
                    ALU_Result = $signed ( A_in ) - $signed ( B_in ) ;
                    twos_com = ~( B_in ) + 1'b1;
                    if (( A_in [ 31 ] & twos_com [ 31 ] & ~ ALU_Out [ 31 ] ) |
                    (~ A_in [ 31 ] & ~ twos_com [ 31 ] & ALU_Out [ 31 ] ))
                        Overflow = 1'b1;
                    else
                        Overflow = 1'b0;
                end
                
            4'b0111 : // Signed less than comparison
                ALU_Result = ( $signed ( A_in ) < $signed ( B_in ))?32'd1: 32'd0;

            4'b1100 : // nor
                ALU_Result = ~( A_in | B_in );

            4'b1111 : // Equal comparison
                ALU_Result = ( A_in == B_in )?32'd1: 32'd0 ;
    
            default : ALU_Result = A_in + B_in ;
        endcase
    end

endmodule
