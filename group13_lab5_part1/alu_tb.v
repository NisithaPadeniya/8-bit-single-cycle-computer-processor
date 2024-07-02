//group 13

`include "alu.v"   // Include the ALU module

module alu_tb;

	// Input ports 
	reg [7:0] op1, op2;   // 8-bit operands
	reg [2:0] sel;         // 3-bit selection signal for choosing operation

	wire [7:0] result;    // Output port for the result

	alu alu_test(op1, op2, result, sel);   // Instantiate the ALU module

    // Initial block to monitor changes and dump wavedata to a VCD file
	initial begin
		$dumpfile("alu_wv.vcd");   // Set the name of the VCD file
		$dumpvars(0, alu_test);     // Dump the variables in the ALU module
		$monitor("TIME = %g OP1 = %d OP2 = %d SEL = %b RESULT = %d", $time, op1, op2, sel, result);   // Monitor changes and display relevant information
	end
	
	initial begin
		// Forwarding operation
		op1 = 8'b00000101;   // Set operand 1
		op2 = 8'b00000111;   // Set operand 2
		sel = 3'b000;        // Set selection signal for forwarding operation
		
		#5   // Wait for 5 time units
		
		// Add operation
		op1 = 8'b1010_0000;   // Set operand 1
		op2 = 8'b0000_1010;   // Set operand 2
		sel = 3'b001;         // Set selection signal for addition operation
		
		#10   // Wait for 10 time units
		
		// AND operation 
		op1 = 8'b00010101;   // Set operand 1
		op2 = 8'b00011101;   // Set operand 2
		sel = 3'b010;        // Set selection signal for bitwise AND operation
		
		#15   // Wait for 15 time units
		
		// OR operation
		op1 = 8'b00010101;   // Set operand 1
		op2 = 8'b00100100;   // Set operand 2
		sel = 3'b011;        // Set selection signal for bitwise OR operation
		
	end	

endmodule
