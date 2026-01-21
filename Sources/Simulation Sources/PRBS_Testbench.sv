
/******************************************************************************

 BRBS_testbench.sv module

*******************************************************************************

 created on:    11/02/2025
 created by:    J.Faller
 last edit on:  1/14/2026
 last edit by:  J.Faller

*******************************************************************************
Bit error rate measurement FPGA
Generator and Receiver testbench

 This module is a testbench for PRBS_Generator.sv and PRBS_Receiver.sv
******************************************************************************/
 
`timescale 1ns / 1ps

module PRBS_testbench;
//*******************************************************************
// Define Variables
//*******************************************************************

    logic               clk             ;   
    logic               rst             ;
    logic    [15:0]     error_rate      ;
    logic               get_word        ;
    logic               bitstream       ;
    logic               send_data       ;
    logic   [31:0]      error_bits_out  ;
    logic   [31:0]      total_bits_out  ;
//    logic   [6:0]       wordtest        ;
//    logic   [15:0]      countertest     ;
//    logic               bitin           ;
//    logic               bitout          ;
//    logic   [15:0]      measured_error_rate;
// define clk frequency
    parameter       clk_period = 10; // 100 MHz

//*******************************************************************
//  instantiate generator and receiver
//*******************************************************************

    PRBS_Generator    PRBS_Generator_0    
    (
    .clk            (clk            ),
    .rst            (rst            ),          // input pin
    .error_rate     (error_rate     ),          // 16 bits
    .bitout         (bitstream      )           // output pin
    );
    
    PRBS_Receiver     PRBS_Receiver_0     
    (   
    .clk            (clk            ),          //100 Mhz
    .rst            (rst            ),          // input pin
    .bit_in         (bitstream      ),          // input pin
    .get_word       (get_word       ),          // input pin
    .error_bits_out (error_bits_out ),          // output pin
    .total_bits_out (total_bits_out ),          // output pin
    .send_data      (send_data      )           // output pin
//    .wordtest       (wordtest       ),
//    .countertest    (countertest    ),
//    .bitin          (bitin          ),
//    .bitout         (bitout         ) 
    ); 

//********************************************************************
// Implement clk
//********************************************************************

    initial clk = 0;
    always #(clk_period / 2) clk = ~clk;
 
//********************************************************************
// Begin test sequence
//********************************************************************  
    
    initial 
    begin
    // reset at start
        rst         =  1'b1;
        #50;

    // release reset
        rst         =  1'b0;
        #50;

    // set error rate and get word to start measuring ber
        error_rate  =  16'd1000;
        #10;
        get_word    =  1'b1;
        #50;
        get_word    =  1'b0;

    // let test run
        #2000000;
    
    // Change error rate
        error_rate = 16'd5000;
        
    // Let test run
        #2000000;
    end
    
endmodule
