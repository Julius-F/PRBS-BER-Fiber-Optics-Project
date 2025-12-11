`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 03:17:42 PM
// Design Name: 
// Module Name: Top
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


module Top(
    input   wire        clk_in1 ,
    input   wire        bit_in  ,
    input   wire        rx      ,
    output  logic       tx      ,
    output  logic       bitout
           );
    
    logic               clk_100     ;
    logic    [15:0]     error_rate  ;
    logic               rst         ;
    
    
    
    
    
    PRBS_Generator    PRBS_Generator_0    
    (
    .clk            (clk_100        ),
    .rst            (rst            ),          // input pin
    .error_rate     (error_rate     ),      
    .bitout         (bitout         )           // output pin
    );
    
    PRBS_Receiver     PRBS_Receiver_0     
    (   
    .clk            (clk_100        ),          //100 Mhz
    .rst            (rst            ),          // input pin
    .bit_in         (bit_in         ),          // input pin
    .get_word       (get_word       ),          // input pin
    .error_bits_out (error_bits_out ),          // output pin
    .total_bits_out (total_bits_out )           // output pin
    );
    
    
    axi_uartlite_0    uartlite_0           
    (
    .s_axi_aclk     (clk_100        ),          // input wire s_axi_aclk
    .s_axi_aresetn  (~rst           ),          // input wire s_axi_aresetn
    .interrupt      (interrupt      ),          // output wire interrupt goes high when data to read
    
    .s_axi_awaddr   (s_axi_awaddr   ),          // input wire [3 : 0] s_axi_awaddr * tx fifio
    .s_axi_awvalid  (s_axi_awvalid  ),          // input wire s_axi_awvalid * handshake signal
    .s_axi_awready  (s_axi_awready  ),          // output wire s_axi_awready * handshake signal
    
    .s_axi_wdata    (s_axi_wdata    ),          // input wire [31 : 0] s_axi_wdata
    .s_axi_wstrb    (s_axi_wstrb    ),          // input wire [3 : 0] s_axi_wstrb * leave all 1s
    .s_axi_wvalid   (s_axi_wvalid   ),          // input wire s_axi_wvalid * handshake signal
    .s_axi_wready   (s_axi_wready   ),          // output wire s_axi_wready * handshake signal
    
    .s_axi_bresp    (s_axi_bresp    ),          // output wire [1 : 0] s_axi_bresp * status of burst (lite no burst?)
    .s_axi_bvalid   (s_axi_bvalid   ),          // output wire s_axi_bvalid * handshake signal
    .s_axi_bready   (s_axi_bready   ),          // input wire s_axi_bready * handshhake signal
    
    .s_axi_araddr   (s_axi_araddr   ),          // input wire [3 : 0] s_axi_araddr * rx fifo
    .s_axi_arvalid  (s_axi_arvalid  ),          // input wire s_axi_arvalid * handshake signal
    .s_axi_arready  (s_axi_arready  ),          // output wire s_axi_arready * handshake signal
    
    .s_axi_rdata    (s_axi_rdata    ),          // output wire [31 : 0] s_axi_rdata
    .s_axi_rresp    (s_axi_rresp    ),          // output wire [1 : 0] s_axi_rresp * status of burst
    .s_axi_rvalid   (s_axi_rvalid   ),          // output wire s_axi_rvalid * handshake signal
    .s_axi_rready   (s_axi_rready   ),          // input wire s_axi_rready * handshake signal
    
    .rx             (rx             ),          // input wire rx
    .tx             (tx             )           // output wire tx
    );


    clk_wiz_1         clk_wizard_0
    (
    // Clock out ports
    .clk_out1       (clk_100        ),          // output clk_out1
                                                // Status and control signals
    .reset          (rst            ),          // input reset
    .locked         (locked         ),          // output locked
                                                // Clock in ports
    .clk_in1        (clk_in1        )           // input clk_in1
    );              

endmodule
