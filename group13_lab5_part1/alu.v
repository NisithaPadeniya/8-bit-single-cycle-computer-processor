//Lab 05 - part 01 (ALU)
//Group 13 

module alu(Data1, Data2, Result, Select);
	
	// Input ports
	input [7:0] Data1, Data2;   // 8-bit data inputs
	input [2:0] Select;          // 3-bit selection input for choosing operation
	
	output reg [7:0] Result;     // Output port for the result
	
	wire [7:0] forwardWire, addWire, andWire, orWire;   // Wires for outputs of each functional unit
	
	// Functional units to forward the results of the units to corresponding wire
	FORWARD forwardUnit(Data2, forwardWire);   // Forwarding unit
	ADD addUnit(Data1, Data2, addWire);        // Addition unit
	AND andUnit(Data1, Data2, andWire);        // Bitwise AND unit
	OR orUnit(Data1, Data2, orWire);           // Bitwise OR unit
	
	
	// RESULT output must be updated whenever any of the inputs or functional outputs changes
	always @ (*) 
	begin
		// Select the operation based on the value of Select input
		case (Select)		
			3'b000 :	Result = forwardWire;   // SELECT = 0 : FORWARD operation
			3'b001 :	Result = addWire;       // SELECT = 1 : ADD operation
			3'b010 :	Result = andWire;       // SELECT = 2 : AND operation
			3'b011 :	Result = orWire;        // SELECT = 3 : OR operation
		endcase
	end
		
endmodule


// Forwarding unit
module FORWARD(Data2, Result);

	input [7:0] Data2;     // Input port for forwarding
	output [7:0] Result;   // Output port for forwarding

	// Assigns value of Data2 to the Result for forwarding after 1 time delay
	assign #1 Result = Data2;

endmodule

// Addition unit
module ADD(Data1, Data2, Result);

	input [7:0] Data1, Data2;    // 8-bit input ports for addition
	output [7:0] Result;         // Output port for addition
	
	// Assigns addition of Data1 and Data2 to Result after 2 time unit delay
	assign #2 Result = Data1 + Data2;

endmodule

// Bitwise AND unit
module AND(Data1, Data2, Result);

	input [7:0] Data1, Data2;    // 8-bit input ports for AND operation
	output [7:0] Result;         // Output port for AND operation
	
	// Assigns logical AND result of Data1 and Data2 to Result after 1 time unit delay
	assign #1 Result = Data1 & Data2;

endmodule

// Bitwise OR unit
module OR(Data1, Data2, Result);

	input [7:0] Data1, Data2;    // Input ports for OR operation
	output [7:0] Result;         // Output port for OR operation
	
	// Assigns logical OR result of Data1 and Data2 to Result after 1 time unit delay
	assign #1 Result = Data1 | Data2;

endmodule
