//lab 05 part 03 - Group 13

module regfile(IN,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,CLK,RESET,WRITE,REGOUT1,REGOUT2,INSTRUCTION);

    input [7:0] IN;   // 8-bit input data to be written into the register
    input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;   // 3-bit input addresses for IN, OUT1, and OUT2
    input CLK, RESET, WRITE;   // Clock signal, Reset signal, Write enable signal

    output reg [7:0] REGOUT1, REGOUT2; // Output data from registers specified by OUT1ADDRESS and OUT2ADDRESS

    reg [7:0] regArray [0:7];   // 8-element array of 8-bit registers

	input [31:0] INSTRUCTION;

    integer i;  // Loop variable for iterating through the array of registers

    // Reading the OUTADDRESSES and asynchronously loading values to OUT1 and OUT2 with a delay of 2 time units
	always @(INSTRUCTION)
	begin
		 REGOUT1 <= #2 regArray[OUT1ADDRESS];		
		 REGOUT2 <= #2 regArray[OUT2ADDRESS];		
	end

	// Write and Reset (synchronous operations)
	always @ (posedge CLK)
	begin
	    // When RESET is high, clear all values of the registers to zero
		if (RESET)			
		begin
		    #1 for (i = 0; i < 8; i = i + 1)    // Iterate over all 8 register addresses with a delay of 1 time unit
			begin
				regArray[i] <= 8'b00000000;    // Reset all registers to zero
			end
		end


     	// If the WRITE signal is high, store the input data IN into the target register specified by INADDRESS
		else if (WRITE)  
		begin		
			#1
			regArray[INADDRESS] <= IN;    // Write operation with a delay of 1 time unit
			
		end
		
	end
	
endmodule