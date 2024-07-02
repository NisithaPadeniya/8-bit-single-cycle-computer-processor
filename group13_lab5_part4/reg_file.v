//lab 05 part 04 - Group 13

module regfile(

    input [7:0] IN,   // 8-bit input data to be written into the register
    input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS,    // 3-bit input addresses for IN, OUT1, and OUT2
    input CLK, RESET, WRITE,   // Clock signal, Reset signal, Write enable signal

    output [7:0] REGOUT1, REGOUT2  // Output data from registers specified by OUT1ADDRESS and OUT2ADDRESS
);

    reg [7:0] regArray [0:7];   // 8-element array of 8-bit registers

    integer i;  // Loop variable for iterating through the array of registers

    // Reading the OUTADDRESSES and asynchronously loading values to OUT1 and OUT2 with a delay of 2 time units
	assign #2 REGOUT1 = regArray[OUT1ADDRESS];		
	assign #2 REGOUT2 = regArray[OUT2ADDRESS];		
	
	// Write and Reset (synchronous operations)
	always @ (posedge CLK)
	begin
        // If the WRITE signal is high, store the input data IN into the target register specified by INADDRESS
		if (WRITE)  
		begin		
			#1
			regArray[INADDRESS] <= IN;    // Write operation with a delay of 1 time unit
			
		end

        // When RESET is high, clear all values of the registers to zero
		else if (RESET)			
		begin
		    #1 for (i = 0; i < 8; i = i + 1)    // Iterate over all 8 register addresses with a delay of 1 time unit
			begin
				regArray[i] <= 8'b00000000;    // Reset all registers to zero
			end
		end
		
	end

	/* START DEBUGGING CODE*/ 
	initial 
	begin
// monitor changes in reg file content and print (used to check whether the CPU is running properly)
	#5;
	$display("\n\t\t\t==============");
	$display("\t\t\t Change of Register Content Starting from Time #5");
	$display ("\t\t\t=================================================/n");
	$display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
	$display("\t\t---------------------------------------------------------------------");
	$monitor ($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", regArray[0], regArray[1], regArray[2], regArray[3], regArray[4], regArray[5], regArray[6], regArray[7]);
	end

initial
begin $dumpfile("cpu_wavedata.vcd");
for (i=0;i<8;i++)
	$dumpvars (1, regArray[i]);
end
	
endmodule