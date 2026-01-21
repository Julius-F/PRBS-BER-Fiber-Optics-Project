`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 04:05:18 PM
// Design Name: 
// Module Name: control
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

module control_bresp_sm
    (
        input   wire            clk_100         ,
        input   wire            reset           ,
        input   wire            m_axi_bvalid    ,
        output  logic           m_axi_bready    
    );
    
    typedef enum    logic   [1:0]
    {
        state_bresp_idle           = 0,
        state_bresp_assert         = 1,
        state_bresp_wait_valid     = 2
    }
    e_state_bresp_index;
    
    logic   [2:0]   state_bresp_current = 3'b001; 
    logic   [2:0]   state_bresp_next;
    
    always_comb 
        begin
        state_bresp_next = 3'b000; // clear all bits at beginning of always_comb - this assures that only 1 bit will be set

        // case statement to determine next state
        // the condition is 1'b1 - only 1 of the cases will meet this condition, so that case will be acted on
        // in each case, variable is state_awaddr_current, index is state name in enum
        case (1'b1)

//            state_bresp_current[state_awaddr_idle          ] : // if current state is the idle state, this case will match and acted on
//                begin
//                    if (bresp_start)
//                        state_awaddr_next[state_awaddr_assert       ] = 1'b1; // if awaddr_start is asserted, go to assert state
//                    else
//                        state_awaddr_next[state_awaddr_idle         ] = 1'b1; // otherwise, stay in idle state
//                end

            state_bresp_current[state_bresp_idle           ] :
                begin
                    if (m_axi_bvalid    )
                        state_bresp_next[state_bresp_assert     ] = 1'b1;
                    else
                        state_bresp_next[state_bresp_idle       ] = 1'b1;
                end

            state_bresp_current[state_bresp_assert         ] :   
                begin
                    state_bresp_next[state_bresp_wait_valid     ] = 1'b1;
                end
                          
            state_bresp_current[state_bresp_wait_valid     ] :
                begin
                    if (m_axi_bvalid   )
                        state_bresp_next[state_bresp_wait_valid ] = 1'b1;
                    else
                        state_bresp_next[state_bresp_idle       ] = 1'b1;
                end                                        
        endcase // 1'b1
        end
        
        always_ff @(posedge clk_100)
            if(reset)
                begin
                    state_bresp_current                         <= 3'b000           ;
                    state_bresp_current[state_bresp_idle    ]   <= 1'b1             ;
                end
            else
                begin
                    state_bresp_current                         <= 3'b000           ;
                    state_bresp_current                         <= state_bresp_next ;
                end
                
        always_ff @(posedge clk_100)
            begin
                unique case (1'b1) 
                                
                    state_bresp_current[state_bresp_idle        ]:
                        begin
                            m_axi_bready <= 1'b0;
                        end
                        
                    state_bresp_current[state_bresp_assert      ]:
                        begin
                            m_axi_bready <= 1'b1;
                        end
                    state_bresp_current[state_bresp_wait_valid  ]:
                        begin
                        end
                        
                endcase 
             end
                       
endmodule: control_bresp_sm   
 
/*************************************************************
        awaddr
*************************************************************/

module control_awaddr_sm
    (
        input   wire            clk_100         ,
        input   wire            reset           ,
        input   wire            awaddr_start    ,
        output  logic   [31:0]  m_axi_awaddr    ,
        output  logic           m_axi_awvalid   ,
        input   wire            m_axi_awready   
        // add ports here
    );

    typedef enum    logic   [1:0]
    {
        state_awaddr_idle           = 0,
        state_awaddr_assert         = 1,
        state_awaddr_wait_ready     = 2
    }
    e_state_awaddr_index;

    // state machine signals, current and next
    // width is the same as the size of the enum, in this case 3
    // state signal is 1-hot, meaning that only 1 bit will be set at a time

    logic   [2:0]   state_awaddr_current = 3'b001; // initialize to 3'b001, the idle state
    logic   [2:0]   state_awaddr_next;

    // determine next state based on current state and conditions
    // this is in an always_comb block
    always_comb
    begin
        state_awaddr_next = 3'b000; // clear all bits at beginning of always_comb - this assures that only 1 bit will be set

        // case statement to determine next state
        // the condition is 1'b1 - only 1 of the cases will meet this condition, so that case will be acted on
        // in each case, variable is state_awaddr_current, index is state name in enum
        case (1'b1)

            state_awaddr_current[state_awaddr_idle          ] : // if current state is the idle state, this case will match and acted on
                begin
                    if (awaddr_start)
                        state_awaddr_next[state_awaddr_assert       ] = 1'b1; // if awaddr_start is asserted, go to assert state
                    else
                        state_awaddr_next[state_awaddr_idle         ] = 1'b1; // otherwise, stay in idle state
                end

            state_awaddr_current[state_awaddr_assert        ] : // if current state is assert this case will match
                begin
                    state_awaddr_next[state_awaddr_wait_ready       ] = 1'b1; // go to wait_ready state
                end

            state_awaddr_current[state_awaddr_wait_ready    ] : // if current state is wait_ready, this case will match
                begin
                    if (m_axi_awready)
                        state_awaddr_next[state_awaddr_idle         ] = 1'b1; // if ready is asserted, go to idle state
                    else
                        state_awaddr_next[state_awaddr_wait_ready   ] = 1'b1; // otherwise, stay in wait_ready state
                end
        endcase // 1'b1
    end

    // register value of next state into current state on every clock
    always_ff @(posedge clk_100)
        if (reset) // on reset, set current state to idle
            begin
                state_awaddr_current                              <= 3'b000; // first reset all bits to 0
                state_awaddr_current[state_awaddr_idle          ] <= 1'b1;   // set current state to idle
            end
        else
            begin
                state_awaddr_current                              <= 3'b000; // reset all bits to 0
                state_awaddr_current                              <= state_awaddr_next; // set current state to next state
            end

    // add actions for each state in an always_ff block
    always_ff @(posedge clk_100)
    begin
        unique case (1'b1) // unique case because only 1 of the cases will match the condition

            state_awaddr_current[state_awaddr_idle              ] : // if current state is idle state, this block will be executed
                begin
                    m_axi_awaddr    <= 32'b0;   // assign awaddr to 0 when in the idle state
                    m_axi_awvalid   <= 1'b0;    // assign valid to 0 when in the idle state
                end

            state_awaddr_current[state_awaddr_assert            ] : // if current state is assert state, this block will be executed
                begin
                    m_axi_awaddr    <= 4'h04;     // tx fifo address
                    m_axi_awvalid   <= 1'b1;             // assert valid
                end

            state_awaddr_current[state_awaddr_wait_ready        ] : // if current state is wait_ready, this block will be executed
                begin
                end
        endcase // 1'b1
    end

endmodule: control_awaddr_sm

/*************************************************************
        araddr
*************************************************************/

module control_araddr_sm
    (
        input   wire            clk_100         ,
        input   wire            reset           ,
        input   wire            araddr_start    ,
        input   wire            this_araddr     ,
        output  logic   [31:0]  m_axi_araddr    ,
        output  logic           m_axi_arvalid   ,
        input   wire            m_axi_arready   
        // add ports here
    );


typedef enum    logic   [1:0]
    {
        state_araddr_idle           = 0,
        state_araddr_assert         = 1,
        state_araddr_wait_ready     = 2
    }
    e_state_araddr_index;

    // declare state machine signals, current and next
    // width is the same as the size of the enum, in this case 3
    // state signal is 1-hot, meaning that only 1 bit will be set at a time

    logic   [2:0]   state_araddr_current = 3'b001; // initialize to 3'b001, the idle state
    logic   [2:0]   state_araddr_next;

    // determine next state based on current state and conditions
    // this is in an always_comb block
    always_comb
    begin
        state_araddr_next = 3'b000; // clear all bits at beginning of always_comb - this assures that only 1 bit will be set

        // case statement to determine next state
        // the condition is 1'b1 - only 1 of the cases will meet this condition, so that case will be acted on
        // in each case, variable is state_awaddr_current, index is state name in enum
        case (1'b1)

            state_araddr_current[state_araddr_idle          ] : // if current state is the idle state, this case will match and acted on
                begin
                    if (araddr_start)
                        state_araddr_next[state_araddr_assert       ] = 1'b1; // if awaddr_start is asserted, go to assert state
                    else
                        state_araddr_next[state_araddr_idle         ] = 1'b1; // otherwise, stay in idle state
                end

            state_araddr_current[state_araddr_assert        ] : // if current state is assert this case will match
                begin
                    state_araddr_next[state_araddr_wait_ready       ] = 1'b1; // go to wait_ready state
                end

            state_araddr_current[state_araddr_wait_ready    ] : // if current state is wait_ready, this case will match
                begin
                    if (m_axi_arready)
                        state_araddr_next[state_araddr_idle         ] = 1'b1; // if ready is asserted, go to idle state
                    else
                        state_araddr_next[state_araddr_wait_ready   ] = 1'b1; // otherwise, stay in wait_ready state
                end
        endcase // 1'b1
    end

    // register value of next state into current state on every clock
    always_ff @(posedge clk_100)
        if (reset) // on reset, set current state to idle
            begin
                state_araddr_current                              <= 3'b000; // first reset all bits to 0
                state_araddr_current[state_araddr_idle          ] <= 1'b1;   // set current state to idle
            end
        else
            begin
                state_araddr_current                              <= 3'b000; // reset all bits to 0
                state_araddr_current                              <= state_araddr_next; // set current state to next state
            end

    // add actions for each state in an always_ff block
    always_ff @(posedge clk_100)
    begin
        unique case (1'b1) // unique case because only 1 of the cases will match the condition

            state_araddr_current[state_araddr_idle              ] : // if current state is idle state, this block will be executed
                begin
                    m_axi_araddr    <= 32'b0;   // assign awaddr to 0 when in the idle state
                    m_axi_arvalid   <= 1'b0;    // assign valid to 0 when in the idle state
                end

            state_araddr_current[state_araddr_assert            ] : // if current state is assert state, this block will be executed
                begin
                    m_axi_araddr    <= this_araddr;     // this will come from master sm
                    m_axi_arvalid   <= 1'b1;             // assert valid
                end

            state_araddr_current[state_araddr_wait_ready        ] : // if current state is wait_ready, this block will be executed
                begin
                end
        endcase // 1'b1
    end


endmodule : control_araddr_sm

/************************************************

************************************************/

module control_wdata_sm
    (
        input   wire            clk_100         ,
        input   wire            reset           ,
        input   wire            wdata_start     ,
        input   wire    [7:0]   send_data       ,
        output  logic   [31:0]   m_axi_wdata    ,
        output  logic           m_axi_awvalid   ,
        input   wire            m_axi_awready   
        // add ports here
    );

    typedef enum    logic   [1:0]
    {
        state_wdata_idle           = 0,
        state_wdata_assert         = 1,
        state_wdata_wait_ready     = 2
    }
    e_state_wdata_index;

    // declare state machine signals, current and next
    // width is the same as the size of the enum, in this case 3
    // state signal is 1-hot, meaning that only 1 bit will be set at a time

    logic   [2:0]   state_wdata_current = 3'b001; // initialize to 3'b001, the idle state
    logic   [2:0]   state_wdata_next;

    // determine next state based on current state and conditions
    // this is in an always_comb block
    always_comb
    begin
        state_wdata_next = 3'b000; // clear all bits at beginning of always_comb - this assures that only 1 bit will be set

        // case statement to determine next state
        // the condition is 1'b1 - only 1 of the cases will meet this condition, so that case will be acted on
        // in each case, variable is state_wdata_current, index is state name in enum
        case (1'b1)

            state_wdata_current[state_wdata_idle          ] : // if current state is the idle state, this case will match and acted on
                begin
                    if (wdata_start)
                        state_wdata_next[state_wdata_assert       ] = 1'b1; // if wdata_start is asserted, go to assert state
                    else
                        state_wdata_next[state_wdata_idle         ] = 1'b1; // otherwise, stay in idle state
                end

            state_wdata_current[state_wdata_assert        ] : // if current state is assert this case will match
                begin
                    state_wdata_next[state_wdata_wait_ready       ] = 1'b1; // go to wait_ready state
                end

            state_wdata_current[state_wdata_wait_ready    ] : // if current state is wait_ready, this case will match
                begin
                    if (m_axi_awready)
                        state_wdata_next[state_wdata_idle         ] = 1'b1; // if ready is asserted, go to idle state
                    else
                        state_wdata_next[state_wdata_wait_ready   ] = 1'b1; // otherwise, stay in wait_ready state
                end
        endcase // 1'b1
    end

    // register value of next state into current state on every clock
    always_ff @(posedge clk_100)
        if (reset) // on reset, set current state to idle
            begin
                state_wdata_current                              <= 3'b000; // first reset all bits to 0
                state_wdata_current[state_wdata_idle          ] <= 1'b1;   // set current state to idle
            end
        else
            begin
                state_wdata_current                              <= 3'b000; // reset all bits to 0
                state_wdata_current                              <= state_wdata_next; // set current state to next state
            end

    // add actions for each state in an always_ff block
    always_ff @(posedge clk_100)
    begin
        unique case (1'b1) // unique case because only 1 of the cases will match the condition

            state_wdata_current[state_wdata_idle              ] : // if current state is idle state, this block will be executed
                begin
                    m_axi_wdata    <= 32'b0;   // assign wdata to 0 when in the idle state
                    m_axi_awvalid   <= 1'b0;    // assign valid to 0 when in the idle state
                end

            state_wdata_current[state_wdata_assert            ] : // if current state is assert state, this block will be executed
                begin
                    m_axi_wdata    <= 4'h04;     // tx fifo address
                    m_axi_awvalid   <= 1'b1;             // assert valid
                end

            state_wdata_current[state_wdata_wait_ready        ] : // if current state is wait_ready, this block will be executed
                begin
                end
        endcase // 1'b1
    end

endmodule: control_wdata_sm
