`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2025 09:24:47 PM
// Design Name: 
// Module Name: PRSB Generator
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


module PRBS_Generator(
    input wire clk,
    input wire rst,
    input wire [15:0] error_rate,
    output wire bitout
    );
    
    timeunit 1ns;
    timeprecision 1ps;
    
    logic [6:0] word = 7'h7f;
    logic [15:0] bit_count = 7'd0;
    assign bitout = word[6] ^ word[5] ^ 1'd1;
    
    always_ff @(posedge clk)
    begin
        if (rst)
        begin
            word <= 7'h7f;
            bit_count <= 7'd0;
        end   
          
        word = word << 1;
        
        if (bit_count == error_rate) 
        begin
            bit_count <= 0;
            word <= {word[5:0],!bitout};
        end
        else          
        begin           
            bit_count <= bit_count + 1'd1;
            word <= {word[5:0],bitout};
        end   
    end
endmodule
