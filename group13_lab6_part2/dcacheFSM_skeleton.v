`timescale  1ns/100ps
/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. 
Note that this code is not complete.
*/


`include "mux4to1.v"


module dcache (
    // ports to communicate with CPU
    CLOCK,
    BUSYWAIT,
    READ,
    WRITE,
    WRITEDATA,
    READDATA,
    ADDRESS,
    RESET_CACHE,
    // ports to communicate with memory
    m_busywait,
    m_read,
    m_write,
    m_writedata,
    m_readdata,
    m_address
);

    //port decclaration
    // ports to communicate with CPU
    input CLOCK, READ, WRITE, RESET_CACHE;
    input[7:0] WRITEDATA, ADDRESS;
    output reg BUSYWAIT;
    output reg [7:0] READDATA;
    // ports to communicate with memory
    input m_busywait;
    input [31:0] m_readdata;
    output reg m_read, m_write;
    output reg [31:0] m_writedata;
    output reg [5:0] m_address;

    
    //*******************************************************************
    // declare cache array
    /*
    Column vectors are created for valid bits, dirty bits, tags and data blocks.
    each vector has 8 elements(since there are 8 indices).
    element size
        valid bit - 1 bit
        dirty bit - 1 bit
        tag       - 3 bits
        data block- 32 bits (4 words x 8 bits/word)
    */
    reg valid_bits[7:0]; 
    reg dirty_bits[7:0];
    reg [2:0] tags[7:0];
    reg [31:0] data_blocks[7:0];

  
    //Detecting an incoming memory access
    always @(READ, WRITE)
    begin
        if (WRITE || READ) begin
          BUSYWAIT = 1;  
        end
        
        // BUSYWAIT = (READ || WRITE)? 1 : 0;
        
    end
    // assign BUSYWAIT = (READ || WRITE)? 1 : 0;


    //*************************************************************************
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    */
   

    // memory address splitting
    wire [2:0] address_tag, index;
    wire [1:0] offset;
    
    assign {address_tag, index, offset} = {ADDRESS[7:5], ADDRESS[4:2], ADDRESS[1:0]};
   
    //***************************************************************
    // indexing
    wire valid, dirty;
    wire [2:0] cache_tag;
    wire [31:0] data_block;

    // indexing latency = #1
    // whenever the values in the cache entry changes, the wires will be updated asynchronously
    assign #1 {valid, dirty, cache_tag, data_block} =  {valid_bits[index], dirty_bits[index], tags[index], data_blocks[index]};


    //****************************************************************
    // hit detection = valid check + tag comparison
    reg tag_comparison, hit;

    // tag comparison latency = #0.9
    // assign #0.9 tag_comparison =  ~(cache_tag ^ address_tag);
    // assign hit = valid && tag_comparison && (READ||WRITE);
    
    always @(*) begin
        if (READ || WRITE) begin
            #0.9 
            tag_comparison =  ~(cache_tag ^ address_tag);
            hit = valid && tag_comparison && (READ||WRITE);
        end
    end

    
    // async actions after a miss
    always @(hit) begin
        //If the existing block is not dirty, the missing data block should be fetched from memory. 
        //For this, cache controller should assert the memory READ control signal as soon as the miss is detected.
        if ((hit == 0) && (READ || WRITE) && (dirty == 0)) begin
            m_read = 1;
            m_write = 0;
            m_address = {address_tag, index};
            m_writedata = 32'dx;
            BUSYWAIT = 1; 
        end
        // If the existing block is dirty, 
        // that block must be written back to the memory before fetching the missing block. 
        //For this, cache controller should assert the memory WRITE control signal as soon as the miss is detected.
        if ((hit == 0) && (READ || WRITE) && (dirty == 1)) begin
            m_read = 0;
            m_write = 1;
            m_address = {cache_tag, index};
            m_writedata = data_block;
            BUSYWAIT = 1;  
        end

        // if (hit == 1) begin
        //     BUSYWAIT = 0;
        //     m_read = 0; // m_read might be triggered for unstable hit signal
        //     m_write = 0;
        // end
    end


    






    //**************************************************************
    // data word selection (from the selected block)

    //selection latency = #1 (included inside the mux)
    wire [7:0] selected_word;
    mux4to1 dataWordSelectionMux(data_block[31:24], data_block[23:16], data_block[15:8], data_block[7:0], offset, selected_word);

    // if READ and hit, send data to CPU (asynchronously)
    always @(*) begin
        if (READ && !WRITE && hit) begin
            BUSYWAIT = 0;
            READDATA = selected_word; 
        end
    end

    // if WRITE and hit, write the data to the cache at the positive edge of the next cycle
    always @(posedge CLOCK) begin
        if (!READ && WRITE && hit) begin
            BUSYWAIT = 0;
            valid_bits[index] = 1;
            dirty_bits[index] = 1;
            
            case (offset)
                2'b00:   data_blocks[index][31:24] = #1 WRITEDATA; 
                2'b01:   data_blocks[index][23:16] = #1 WRITEDATA; 
                2'b10:   data_blocks[index][15:8]  = #1 WRITEDATA; 
                2'b11:   data_blocks[index][7:0]   = #1 WRITEDATA; 
            endcase
        end
    end

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010, CACHE_UPDATE = 3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((READ || WRITE) && !dirty && !hit)  
                    next_state = MEM_READ;
                else if ((READ || WRITE) && dirty && !hit)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!m_busywait)
                    next_state = CACHE_UPDATE;
                else    
                    next_state = MEM_READ;
            
            MEM_WRITE:
                if (!m_busywait)
                    next_state = MEM_READ;
                else
                    next_state = MEM_WRITE;

            CACHE_UPDATE:
                next_state = IDLE;
            
        endcase
    end

    // combinational output logic
    always @(state)
    begin
        case(state)
            IDLE:
            begin
                m_read = 0;
                m_write = 0;
                m_address = 8'dx;
                m_writedata = 32'dx;
                BUSYWAIT = 0;
            end
         
            MEM_READ: 
            begin
                m_read = 1;
                m_write = 0;
                m_address = {address_tag, index};
                m_writedata = 32'dx;
                BUSYWAIT = 1;       
            end

            CACHE_UPDATE: 
            begin
                m_read = 0;
                m_write = 0;
                m_address = 8'dx;
                m_writedata = 32'dx;;
                BUSYWAIT = 1; 
                
                #1
                {valid_bits[index], dirty_bits[index], tags[index], data_blocks[index]} = {1'b1, 1'b0, address_tag, m_readdata};     
                BUSYWAIT = 0; 
                
            end



            MEM_WRITE: 
            begin
                m_read = 0;
                m_write = 1;
                m_address = {cache_tag, index};
                m_writedata = data_block;
                BUSYWAIT = 1;
            end
            
        endcase
    end

    // If the FSM is in MEM_READ state,
    // when m_busywait gets deasserted(memory reading is over),
    // the cache should be updated
    // always @(m_readdata) begin
    //     if (!m_busywait) begin
    //         #1
    //         {valid_bits[index], dirty_bits[index], tags[index], data_blocks[index]} = {1'b1, 1'b0, address_tag, m_readdata};
    //     end


    // end

    // sequential logic for state transitioning 
    always @(posedge CLOCK, RESET_CACHE)
    begin
        if(RESET_CACHE)
            state = IDLE;
        else
            state = next_state;
    end

    /* Cache Controller FSM End */



    //Reset cache
    integer i;
    always @(posedge CLOCK)
    begin
        if (RESET_CACHE)
        begin
            for (i=0;i<8; i=i+1) begin                
                valid_bits[i] = 0;
                dirty_bits[i] = 0;
                //tags[i] =0;
                //data_blocks[i] = 0;
            end
        end
    end


    initial
    begin 
    $dumpfile("cpu_wavedata.vcd");
    for(i=0;i<8;i++)
        $dumpvars(1,valid_bits[i],tags[i],data_blocks[i],dirty_bits[i]);
    end
   

endmodule