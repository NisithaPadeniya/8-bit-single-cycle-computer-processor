`include "comparator_instrmem.v"
`include "mux4x1_instrmem.v"

`timescale  1ns/100ps


module instruction_cache (
  input clock,
  input reset,
  input [9:0] address,
  output reg busywait,
  output reg [31:0] instruction,

  input mem_BusyWait,
  input [127:0] mem_instr_Block,
  output reg mem_Read,
  output reg [5:0] mem_Address

  
);

  // declare instruction cache array 128x8-bits and other arrays
  reg [127:0] cacheBlocks [7:0];
  reg [2:0] cacheTags [0:7];
  reg cacheValid [0:7];

  // memory address splitting and indexing
  wire [1:0] offset;
  wire [2:0] index;
  wire [2:0] addressTag;

  wire valid;
  wire [127:0] cacheBlock;
  wire [2:0] cacheTag;

  // Detecting an incoming cache memory access
  always @(address) begin
    busywait =  1'b1;
  end

  assign {addressTag, index, offset} = address[9:2];

  // indexing latency = #1
    assign #1 cacheBlock = cacheBlocks[index];
    assign #1 cacheTag = cacheTags[index];
	  assign #1 valid = cacheValid[index];


  // check whether there is a hit
  wire comparatorOut;
  reg hit;
  cmp comparator_icache(addressTag, cacheTag, comparatorOut);
  always@(*)begin
     #0.9
     hit = valid && comparatorOut;
  end

  // Extract instruction from instruction block and assign
  wire [31:0] MuxOut;
  mux4_instr_mem mux4to1_inst(cacheBlock[31:0], cacheBlock[63:32], cacheBlock[95:64], cacheBlock[127:96], offset, MuxOut);


  // READ & HIT 
  always @(*) begin
      if (hit) begin
          busywait = 1'b0;
          mem_Read = 0;
          instruction = MuxOut; 
      end
  end


  // // if MISS occur
  always @(hit) begin
      if ((hit == 0)) begin
        mem_Read  = 1;
        mem_Address   = {addressTag, index};
        //mem_instr_Block = 128'dx;
        busywait = 1; 
      end
  end  

   //UPDATING CACHE AFTER READING FROM MEMORY
  always @(mem_BusyWait) begin
    #1
    if (!mem_BusyWait) begin
      {cacheValid[index], cacheTags[index], cacheBlocks[index]} = {1'b1, addressTag, mem_instr_Block};     
        
    end
     
    
  end



  /* dcache FSM Start */
  //IDLE = not performing any operation, MEM_READ = Memory Read, MEM_WRITE = Memory Write
    parameter IDLE = 3'b000, MEM_READ = 3'b001;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:                                             // While in this state
                if (hit)                                     // if hit 
                    next_state = IDLE;                    // remain in IDLE state  
                                 
                else                                          // else
                    next_state = MEM_READ;                        // goto state -> MEM_READ
            
            MEM_READ:                                         // while in this state
                if (mem_BusyWait)                            // if memory is signaling busy 
                    next_state = MEM_READ;                        // remain in MEM_READ state
                else                                          // else if memory is signaling not busy
                    next_state = IDLE;                    // goto IDLE
            
        endcase
    end

    // combinational output logic
    always @(state)
    begin
        case(state)
            IDLE:
            begin
                mem_Read = 0;
                mem_Address = 6'dx;                  
                
            end
         
            MEM_READ: 
            begin
                mem_Read = 1;
                mem_Address = {addressTag, index};         // Memory address based on adressTag and index bits                 
                busywait = 1;       

                // #1
                // if(mem_BusyWait==0)
                // begin
                //     mem_Read = 0;
                //     mem_Address = 8'dx;
                //     cacheBlocks[index] = mem_instr_Block;
                //     cacheTags[index]   = addressTag;
                //     cacheValid[index]  = 1'b1;
                // end
            end
   
        endcase
    end


    // Sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)
            state = IDLE;
        else
            state = next_state;
    end
    /* dcache FSM End */


  // Reset cache memory
  integer i;
  always @(posedge reset) begin
    if (reset) begin
      for (i = 0; i < 8; i = i + 1) begin
        cacheValid[i] = 0;
      end
    end
  end
  

  initial
    begin 
    $dumpfile("cpu_wavedata.vcd");
    for(i=0;i<8;i++)
        $dumpvars(1,cacheValid[i],cacheTags[i],cacheBlocks[i]);
  end


endmodule