`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2025 10:56:00 PM
// Design Name: 
// Module Name: PRBS_Receiver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PRBS_Receiver(
input wire clk, //100 Mhz
input wire rst,
input wire bit_in,
input wire get_word,
output wire error_bits_out,
output wire total_bits_out
    );
    
    timeunit 1ns;
    timeprecision 1ps;
    
    logic [6:0] word;
    logic word_index = 3'h0;
    logic word_flag = 1'b0;
    logic [31:0] error_bits = 1'b0;
    logic [31:0] total_bits;
    logic bit_compare;
    logic [23:0] output_counter = 0;
    logic [31:0] error_bits_reg;
    logic[31:0] total_bits_reg;
    
    assign error_bits_out = error_bits_reg;
    assign total_bits_out = total_bits_reg;

    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            
        end
// Get a word from the received bitstream
        if(get_word == 1'b1)
        begin
            word_flag <= 1'b1;
            word_index <= 0;
        end
        else
        begin
            if(word_flag == 1'b1)
            begin
                total_bits <= 1'b0;
                error_bits <= 1'b0;
                if(word_index < 7)
                begin
                    word <= {word[5:0],bit_in};
                    word_index <= word_index + 1;
                end
                else if(word_index == 7)
                begin
                    word_flag <= 0;         
                end
            end
// Generate a prbs to compare to the received
             else
            begin
                bit_compare <= word[6] ^ word[5] ^ 1'b1;
                word <= {word[5:0],bit_compare};
            end
        end
// Tabulate generated and received bits
            total_bits <= total_bits + 1'b1;
            error_bits <= error_bits + (bit_in ^ bit_compare);
// Take snapshot of bit counts for output
            if(output_counter < 10000000)
            begin
                output_counter <= output_counter + 1'b1;
            end
            else
            begin
                output_counter <= 0;
                total_bits_reg <= total_bits;
                error_bits_reg <= error_bits;
            end
        end
endmodule
