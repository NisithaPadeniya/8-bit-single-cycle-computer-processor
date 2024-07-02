// CO224 - lab6 part3 
// GROUP 13
// corrected


`timescale  1ns/100ps

`include "cpu.v"
`include "datamemory.v"
`include "dataCache.v"
`include "instruction_mem.v"
`include "instruction_cache.v"


module cpu_tb;

    reg CLK, RESET, RESET_MEM;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;

    wire [7:0] ADDRESS, WRITEDATA, READDATA;
    wire WRITE, READ;
    wire BUSYWAIT, BUSYWAIT_ICACHE;

    wire BUSYWAIT_DM, READ_DM, WRITE_DM;
    reg RESET_CACHE;
    wire [31:0] WRITEDATA_DM, READDATA_DM;
    wire [5:0] ADDRESS_DM;

    reg RESET_ICACHE;
    wire BUSYWAIT_IM, READ_IM;
    wire [127:0] readinstruction;
    wire [5:0] ADDRESS_IM;
   
    // cpu
    cpu mycpu(PC,INSTRUCTION, CLK, RESET,BUSYWAIT, READDATA, WRITE, READ, WRITEDATA, ADDRESS,BUSYWAIT_ICACHE);
    
    // data cache
    data_cache dcache(CLK,RESET,READ,WRITE,ADDRESS,WRITEDATA,READDATA,BUSYWAIT,
    BUSYWAIT_DM,READDATA_DM,READ_DM,WRITE_DM,ADDRESS_DM,WRITEDATA_DM);

    //dcache dche(CLK,BUSYWAIT,READ,WRITE,WRITEDATA,READDATA,ADDRESS,RESET,BUSYWAIT_DM,READ_DM,WRITE_DM,WRITEDATA_DM,READDATA_DM,ADDRESS_DM);

    
    // data memory
    data_memory dmem(CLK, RESET,READ_DM, WRITE_DM, ADDRESS_DM, WRITEDATA_DM, READDATA_DM, BUSYWAIT_DM);

    // instruction cache
    instruction_cache icache(CLK,RESET,PC[9:0],BUSYWAIT_ICACHE,INSTRUCTION,BUSYWAIT_IM,readinstruction,READ_IM,ADDRESS_IM);


    
    // instruction memory
    instruction_memory imem(CLK,READ_IM,ADDRESS_IM,readinstruction,BUSYWAIT_IM);
    
    initial
    begin
        CLK = 1'b0;
        RESET = 1'b0;

        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #2
        RESET = 1'b1;
    
		#4
		RESET = 1'b0;
        

        // finish simulation after some time
        #5000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;


    
    
    initial begin
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);

    
    end
        

endmodule