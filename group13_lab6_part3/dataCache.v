`include "comparator.v"
`include "mux4to1.v"

`timescale  1ns/100ps


module data_cache (
  input clock,
  input reset,
  input read,
  input write,
  input [7:0] address,
  input [7:0] writedata,
  output reg [7:0] readdata,
  output reg busywait,

  input mem_BusyWait,
  input [31:0] mem_Readdata,
  output reg mem_Read,
  output reg mem_Write,
  output reg [5:0] mem_Address,
  output reg [31:0] mem_Writedata
  
);

  // declare cache memory array 32x8-bits and other arrays
  reg [31:0] cacheBlocks [7:0];
  reg [2:0] cacheTags [0:7];
  reg cacheDirty [0:7];
  reg cacheValid [0:7];

  // memory address splitting and indexing
  wire [1:0] offset;
  wire [2:0] index;
  wire [2:0] addressTag;

  wire valid,dirty;
  wire [31:0] data;
  wire [2:0] cacheTag;

  // Detecting an incoming cache memory access
  always @(read, write) begin
    busywait = (read || write) ? 1 : 0;
  end

  assign {addressTag, index, offset} = address;

  // indexing latency = #1
  assign #1 data = cacheBlocks[index];
	assign #1 cacheTag = cacheTags[index];
	assign #1 valid = cacheValid[index];
	assign #1 dirty = cacheDirty[index];


  // check whether there is a hit
  wire comparatorOut;
  reg hit;
  comparator comparator_inst(addressTag, cacheTag, comparatorOut);

  always @(*) begin
    if (read||write) begin
      hit = valid && comparatorOut;
    end
  end



  // Extract data from data block and assign
  wire [7:0] dataExtractMuxOut;
  mux4to1 mux4to1_inst(data[31:24], data[23:16], data[15:8], data[7:0], offset, dataExtractMuxOut);


  // READ & HIT -> Send data to CPU 
  always @(*) begin
      if (read && !write && hit) begin
          busywait = 0;
          readdata = dataExtractMuxOut; 
      end
  end

  // WRITE & HIT -> write data to cache 
  always @(posedge clock) begin
    if (!read && write && hit) begin
      busywait = 0;
      cacheValid[index] = 1;
      cacheDirty[index] = 1; // Set dirty bit to 1 as cache and memory inconsistent           
      
      // Write data to the correct block in cache
      case (offset)                         
        2'b00: cacheBlocks[index][31:24] = #1 writedata;
        2'b01: cacheBlocks[index][23:16] = #1 writedata;
        2'b10: cacheBlocks[index][15:8]  = #1 writedata;
        2'b11: cacheBlocks[index][7:0]   = #1 writedata;
      endcase 
    end
  end


  // if MISS occur
  always @(hit) begin
      //If the block is not dirty
      if ((hit == 0) && (read || write) && (dirty == 0)) begin
        mem_Read  = 1;
        mem_Write = 0;
        mem_Address   = {addressTag, index};
        mem_Writedata = 32'dx;
        busywait = 1; 
      end
  
      // If the block is dirty (Complete WRITE_BACK state)
      if ((hit == 0) && (read || write) && (dirty == 1)) begin
          mem_Read = 0;
          mem_Write = 1;
          mem_Address = {cacheTag, index};
          mem_Writedata = data;
          busywait = 1;  
      end
  end  


  

  /* dcache FSM Start */
  //IDLE = not performing any operation, MEM_READ = Memory Read, MEM_WRITE = Memory Write
    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010, CACHE_UPDATE = 3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:                                             // While in this state
                if ((read || write ) && !dirty && !hit)       // if not dirty and not hit and ( read signal or write signal )
                    next_state = MEM_READ;                    // goto state -> MEM_READ 
                else if ((read || write) && dirty && !hit)    // else if dirty and not hit and ( read signal or write signal )
                    next_state = MEM_WRITE;                   // goto state -> MEM_WRITE
                else                                          // else
                    next_state = IDLE;                        // remain in IDLE state
            
            MEM_READ:                                         // while in this state
                if (!mem_BusyWait)                            // if memory is signaling not busy 
                    next_state = CACHE_UPDATE;                // goto CACHE_UPDATE
                else                                          // else if memory is signaling busy
                    next_state = MEM_READ;                    // goto MEM_READ
            
            MEM_WRITE:                                        // while in this state
                if (!mem_BusyWait)                            // if memory is signaling not busy
                    next_state = MEM_READ;                    // goto MEM_READ
                else                                          // else if memory is signaling busy
                    next_state = MEM_WRITE;                   // stay in MEM_WRITE

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
                mem_Read = 0;
                mem_Write = 0;
                mem_Address = 8'dx;                         // Placeholder value for memory address
                mem_Writedata = 32'dx;                      // Placeholder value for data to be written
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_Read = 1;
                mem_Write = 0;
                mem_Address = {addressTag, index};         // Memory address based on adressTag and index bits
                mem_Writedata = 32'dx;                     // Placeholder value for data to be written
                busywait = 1;       
            end

            CACHE_UPDATE: 
            begin
                mem_Read = 0;
                mem_Write = 0;
                mem_Address = 8'dx;
                mem_Writedata = 32'dx;;
                busywait = 1; 
                
                #1
                cacheBlocks[index] = mem_Readdata;
                cacheValid[index]  = 1'b1;    
                cacheDirty[index]  = 1'b0;
                cacheTags[index]   = addressTag;

                busywait = 0; 
                
            end



            MEM_WRITE: 
            begin
                mem_Read = 0;
                mem_Write = 1;
                mem_Address = {cacheTag, index};              // Memory address based on cacheTag and index bits
                mem_Writedata = data;                         // Data to be written to memory
                busywait = 1;
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
        cacheDirty[i] = 0;
        cacheValid[i] = 0;
      end
    end
  end
  

  initial
    begin 
    $dumpfile("cpu_wavedata.vcd");
    for(i=0;i<8;i++)
        $dumpvars(1,cacheValid[i],cacheTags[i],cacheDirty[i],cacheBlocks[i]);
  end


endmodule

