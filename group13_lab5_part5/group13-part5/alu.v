//lab 05 part 04 - Group 13

`include "multUnit.v"
`include "shiftUnit.v"

module alu(Data1, Data2, Result, Select,Zero,DIRECTION);
	
	// Input ports
	input [7:0] Data1, Data2;   // 8-bit data inputs
	input [2:0] Select;          // 3-bit selection input for choosing operation
	input DIRECTION;            // 1-bit Selection input for choosing shift operation
	
	output reg [7:0] Result;     // Output port for the result
	output reg Zero;	

	wire [7:0] forwardWire, addWire, andWire, orWire, multWire,shiftWire,shiftWire_AR,shiftWire_ror ;   // Wires for outputs of each functional unit
	
	// Functional units to forward the results of the units to corresponding wire
	FORWARD forwardUnit(Data2, forwardWire);   // Forwarding unit
	ADD addUnit(Data1, Data2, addWire);        // Addition unit
	AND andUnit(Data1, Data2, andWire);        // Bitwise AND unit
	OR orUnit(Data1, Data2, orWire);           // Bitwise OR unit
	MULT multUnit(Data1,Data2,multWire);		   // multiplying unit
	LOgical_SHIFT shiftUnit(Data1,Data2,shiftWire,DIRECTION);
	Arithmetic_Shift_Right sra(Data1, Data2, shiftWire_AR);
	right_rotate ror(Data1,Data2,shiftWire_ror);
	
	// RESULT output must be updated whenever any of the inputs or functional outputs changes
	always @ (forwardWire, addWire, andWire, orWire, multWire) 
	begin
		// Select the operation based on the value of Select input
		case (Select)		
			3'b000 :	Result = forwardWire;   // SELECT = 0 : FORWARD operation
			3'b001 :	Result = addWire;       // SELECT = 1 : ADD operation
			3'b010 :	Result = andWire;       // SELECT = 2 : AND operation
			3'b011 :	Result = orWire;        // SELECT = 3 : OR operation
			3'b100 : 	Result = multWire;      // SELECT = 4 : MULT
			3'b101 :	Result = shiftWire;
			3'b110 :	Result = shiftWire_AR;
			3'b111 :	Result = shiftWire_ror;
		endcase
	end

    //check the sub of two inputs is zero
	always @(addWire) 
	begin
		if(addWire == 8'b00000000)
		begin
			Zero = 1'b1;
		end

		else
		begin
			Zero = 1'b0;
		end
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


