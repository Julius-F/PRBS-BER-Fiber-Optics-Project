
/******************************************************************************

 PRBS_Generator.sv module

*******************************************************************************

 created on:    10/17/2025
 created by:    J.Faller
 last edit on:  1/20/2026
 last edit by:  J.Faller

*******************************************************************************
Bit error rate measurement FPGA
PRBS generator module

 This module generates a pseudo random bitstream with an injected error rate
 ******************************************************************************/
 
 `timescale 1ns / 1ps

module PRBS_Generator(
    input   wire        clk         ,   // 100 MHz
    input   wire        rst         ,
    input   wire [15:0] error_rate  ,   // input from control.sv
    output  logic       bitout         // output PRBS
    );
    
    timeunit 1ns;
    timeprecision 1ps;
    
    logic [6:0] word = 7'h7f; // Word used to generate PRBS
    logic [15:0] bit_count = 7'd0; // Used for injected error rate
    logic next_bit = 1'b0; // Next bit in sequence
    logic output_bit = 1'b0; // Next bit to be output
    assign bitout = output_bit; 
    always_ff @(posedge clk)
    begin
        // reset module values
        if (rst)
        begin
            word <= 7'h7f;
            bit_count <= 7'd0;
        end   
        
        next_bit <= word[6] ^ word[5]; // equation for next bit in PRBS
        word <= {word[5:0],next_bit}; // update word with next bit in sequence
        
        // inject incorrect bit at defined error rate
        if (bit_count >= error_rate) // When bit count matchs or exceeds error rate inject incorrect bit
        // Exceed case included for if the error rate is changed live 
        // to a value less than the counters current value
        begin
            bit_count <= 16'b1; // reset bit count
            output_bit <= !next_bit; // Flip output bit to be incorrect
        end
        else
        // increment bit count and set correct bit for output          
        begin           
            bit_count <= bit_count + 1'd1;
            output_bit <= next_bit; // queue correct bit for output
        end          
    end
endmodule
