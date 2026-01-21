
/******************************************************************************

 PRBS_Generator.sv module

*******************************************************************************

 created on:    11/05/2025
 created by:    J.Faller
 last edit on:  1/8/2026
 last edit by:  J.Faller

*******************************************************************************
Bit error rate measurement FPGA
PRBS receiver module

 This module receives a pseudo random bit stream and generates
 an equivalent prbs to compare with the received and calculate ber
 ******************************************************************************/
 
`timescale 1ns / 1ps

module PRBS_Receiver(
input   wire                clk             ,   //100 Mhz
input   wire                rst             ,
input   wire                bit_in          ,   // received bitstream
input   wire                get_word        ,   // signal to pull word from received bitstream
output  logic               send_data       ,   // Signal to send data through uart
output  logic   [31:0   ]   error_bits_out  ,   // incorrect bits received
output  logic   [31:0   ]   total_bits_out      // total bits received

// Outputs used for troubleshooting
//output  logic   [6:0    ]   wordtest        ,   // for testing
//output  logic   [23:0   ]   countertest     ,   // for testing
//output  logic               bitout          ,
//output  logic               bitin
    );
    
    timeunit 1ns;
    timeprecision 1ps;
    
    logic   [6:0    ]   word            = 7'b0  ; // word to generate prbs to compare to bit_in
    logic   [2:0    ]   word_index      = 3'b0  ; // used for capturing word
    logic               word_flag       = 1'b0  ; // set until word is captured
    logic   [31:0   ]   error_bits      = 32'd0 ; // error bit counter
    logic   [31:0   ]   total_bits      = 32'd0 ; // total bit counter
    logic               bit_compare             ; // generated bit from current word
    logic               bit_in_1        = 1'b0  ; // Delay bit in by 1 clk cycle
    logic   [23:0   ]   output_counter  = 1'b0  ; // defines how frequently count is output
    
    logic   [31:0   ]   error_bits_reg          ; // save bit count for output
    logic   [31:0   ]   total_bits_reg          ; // saved bit count for output
    logic               data_flag       = 1'b0  ; // used to tell sm to send data
    /* 
    bits_reg used to output more accurate count values as values are not
    instantly output so the second value would change before output
    using a separate variable to capture a set of values fixes this
    */
    
    // assign outputs
    assign error_bits_out   =   error_bits_reg  ;
    assign total_bits_out   =   total_bits_reg  ;
    assign send_data        =   data_flag       ;
    
// Outputs used for troubleshooting   
//    //Testing values
//    assign  wordtest    =   word            ;
//    assign  countertest =   output_counter  ;
//    assign  bitin       =   bit_in_1        ;
//    assign  bitout      =   bit_compare     ;
    
    
    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            word_flag   <= 1'b1 ; // On reset pull new word
            word_index  <= 3'b0 ;   
            total_bits  <= 32'b0; // reset bit count
            error_bits  <= 32'b0; // reset error count
        end
// Get a word from the received bitstream
        if(get_word == 1'b1)
        begin
            word_flag   <= 1'b1; // will pull bits for word while flag is high
            word_index  <= 3'b0; // keeps track of how many bits have been saved to word
        end
        else
        begin
            if(word_flag == 1'b1) // save bits to word while high
            begin
                // reset counters for new word
                total_bits <= 32'b0;
                error_bits <= 32'b0;
                if(word_index < 3'd7) // save values until a 7 value word is captured
                begin
                    word <= {word[5:0],bit_in}; // add bit to word and shift existing bits
                    word_index <= word_index + 1'b1; // increment index
                end
                else if(word_index == 3'd7)
                begin
                    word_flag <= 1'b0; // stop capturing bits after 7 bit word is captured        
                end
            end
// Generate a prbs to compare to the received
             else
            begin
                bit_compare <= word[6] ^ word[5]; // generate next bit in sequence
                word <= {word[5:0],bit_compare}; // update word with new bit
            end
        end
// Tabulate generated and received bits
            if (word_flag == 1)
                begin
                total_bits  <=  32'b0                           ;
                end
            else
                begin
                total_bits  <=  total_bits + 1'b1               ;
                end
            if (bit_in_1 !== bit_compare) // if generated and received bit are different increment error counter
            begin
                error_bits  <= error_bits + 1'b1;
            end
            bit_in_1    <= bit_in                               ;
// Take snapshot of bit counts for output
// only output bit count every n clk cycles
            if(output_counter < 32'd100) 
            begin
                output_counter  <=  output_counter + 1'b1   ; // increment counter if below interval
                data_flag       <=  1'b0                    ; // signal to send data is low
            end
            else
            begin
                output_counter  <=  1'b0                    ; // reset counter
                total_bits_reg  <=  total_bits              ; // capture total bits count to output reg
                error_bits_reg  <=  error_bits              ; // capture error bits count to output reg
                data_flag       <=  1'b1                    ; // signal to send data high
            end
        end
endmodule
