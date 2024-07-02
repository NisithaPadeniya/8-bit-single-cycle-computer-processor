//lab 06 part 01 - Group 13

`include "cpu.v"
`include "datamemory.v"
`include "dataCache.v"


`timescale 1ns/100ps

module cpu_tb;

    reg CLK, RESET,RESET_MEM;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;

    wire BUSYWAIT,BUSYWAIT_DM;
	wire [7:0] READDATA;
	wire [31:0] READDATA_DM;
	wire WRITE, READ, WRITE_DM, READ_DM;
	wire [7:0] WRITEDATA, ADDRESS;
	wire [31:0] WRITEDATA_DM;
	wire [5:0] ADDRESS_DM;
    reg RESET_CACHE;

    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
	reg[7:0] instr_mem[0:1023];
	
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
	assign #2 INSTRUCTION = {instr_mem[PC+3], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};
    
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        //{instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000000001000000000000000101;
        //{instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000100000000000001001;
        //{instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010000001100000010000000010;
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        $readmemb("instr_mem.mem", instr_mem);
    end
    
    // CPU
    cpu mycpu(PC, INSTRUCTION, CLK, RESET,BUSYWAIT,READDATA,WRITE,READ,WRITEDATA,ADDRESS);
    
    

    // Data cache
    data_cache dcache(CLK,RESET_CACHE,READ,WRITE,ADDRESS,WRITEDATA,READDATA,BUSYWAIT,BUSYWAIT_DM,
    READDATA_DM,READ_DM,WRITE_DM,ADDRESS_DM,WRITEDATA_DM);

    // Data memory
    data_memory dmem(CLK, RESET_MEM, READ_DM, WRITE_DM, ADDRESS_DM, WRITEDATA_DM, READDATA_DM, BUSYWAIT_DM);

    integer n;

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        // Dump register file variables for waveform analysis
        // for(n=0;n<8;n=n+1)
        //     $dumpvars(1,mycpu.cpu_reg_file.regArray[n]);

        CLK = 1'b0;
        RESET = 1'b1;
        RESET_MEM = 1'b0;
        RESET_CACHE = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
		#2
        RESET = 1'b1;
        RESET_MEM = 1'b1;
        RESET_CACHE = 1'b1;
		#4
		RESET = 1'b0;
        RESET_MEM = 1'b0;
        RESET_CACHE = 1'b0;
        
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule