//2x1 MUX Module
module mux2x1(out, in0,in1,s);
	//declaring ports
    input in0, in1,s;
    output out ;
    wire orIn0 ,orIn1;

	//mux circuit
    and (orIn0,in0,!s);
    and (orIn1,in1,s);
    or (out , orIn0,orIn1);
	
endmodule


// function for LEFT SHIFT operation
module LOgical_SHIFT(data , shift_amount , OutPut,direction);

	//Declaration of input and output ports
    input [7:0] data ,shift_amount ;
    input direction;       // 0 for left shift, 1 for right shift
    output [7:0] OutPut;
    
	//Intermediate connections between MUX layers 
    wire [7:0] lOut [2:0];     // three 8 bit wires
    wire s[7:0];


    // MUX Level 1
    mux2x1 mux00(lOut[0][0], data[0], (direction ? data[1] : 1'b0), shift_amount[0]);
    mux2x1 mux01(lOut[0][1], data[1], (direction ? data[2] : data[0]), shift_amount[0]);
    mux2x1 mux02(lOut[0][2], data[2], (direction ? data[3] : data[1]), shift_amount[0]);
    mux2x1 mux03(lOut[0][3], data[3], (direction ? data[4] : data[2]), shift_amount[0]);
    mux2x1 mux04(lOut[0][4], data[4], (direction ? data[5] : data[3]), shift_amount[0]);
    mux2x1 mux05(lOut[0][5], data[5], (direction ? data[6] : data[4]), shift_amount[0]);
    mux2x1 mux06(lOut[0][6], data[6], (direction ? data[7] : data[5]), shift_amount[0]);
    mux2x1 mux07(lOut[0][7], data[7], (direction ? 1'b0 : data[6]), shift_amount[0]);
  
	// MUX Level 2
    mux2x1 mux10(lOut[1][0], lOut[0][0], (direction ? lOut[0][2] : 1'b0), shift_amount[1]);    
    mux2x1 mux11(lOut[1][1], lOut[0][1], (direction ? lOut[0][3] : 1'b0), shift_amount[1]);
    mux2x1 mux12(lOut[1][2], lOut[0][2], (direction ? lOut[0][4] : lOut[0][0]), shift_amount[1]);
    mux2x1 mux13(lOut[1][3], lOut[0][3], (direction ? lOut[0][5] : lOut[0][1]), shift_amount[1]);
    mux2x1 mux14(lOut[1][4], lOut[0][4], (direction ? lOut[0][6] : lOut[0][2]), shift_amount[1]);
    mux2x1 mux15(lOut[1][5], lOut[0][5], (direction ? lOut[0][7] : lOut[0][3]), shift_amount[1]);
    mux2x1 mux16(lOut[1][6], lOut[0][6], (direction ? 1'b0 : lOut[0][4]), shift_amount[1]);
    mux2x1 mux17(lOut[1][7], lOut[0][7], (direction ? 1'b0 : lOut[0][5]), shift_amount[1]);

    // MUX Level 3
    mux2x1 mux20(lOut[2][0], lOut[1][0], (direction ? lOut[1][4] : 1'b0), shift_amount[2]);    
    mux2x1 mux21(lOut[2][1], lOut[1][1], (direction ? lOut[1][5] : 1'b0), shift_amount[2]);
    mux2x1 mux22(lOut[2][2], lOut[1][2], (direction ? lOut[1][6] : 1'b0), shift_amount[2]);
    mux2x1 mux23(lOut[2][3], lOut[1][3], (direction ? lOut[1][7] : 1'b0), shift_amount[2]);
    mux2x1 mux24(lOut[2][4], lOut[1][4], (direction ? 1'b0 : lOut[1][0]), shift_amount[2]);
    mux2x1 mux25(lOut[2][5], lOut[1][5], (direction ? 1'b0 : lOut[1][1]), shift_amount[2]);
    mux2x1 mux26(lOut[2][6], lOut[1][6], (direction ? 1'b0 : lOut[1][2]), shift_amount[2]);
    mux2x1 mux27(lOut[2][7], lOut[1][7], (direction ? 1'b0 : lOut[1][3]), shift_amount[2]);

	//Assigning final output after 2 time unit delay
	//If shift amount is 0x08 output is all zeros
    assign #2 OutPut= (shift_amount==8'd8)? 8'b00000000:lOut[2];
	
endmodule


module Arithmetic_Shift_Right(data, shift_amount, result);

    // Input and output declarations
    input [7:0] data;
    input [7:0] shift_amount;
    output [7:0] result;

    // Intermediate wires for connecting MUX layers
    wire [7:0] lOut [2:0];

    // Sign bit replication (for arithmetic shift)
    wire sign = data[7];

    // MUX Level 1
    mux2x1 mux0(lOut[0][0], data[0], data[1], shift_amount[0]);
    mux2x1 mux1(lOut[0][1], data[1], data[2], shift_amount[0]);
    mux2x1 mux2(lOut[0][2], data[2], data[3], shift_amount[0]);
    mux2x1 mux3(lOut[0][3], data[3], data[4], shift_amount[0]);
    mux2x1 mux4(lOut[0][4], data[4], data[5], shift_amount[0]);
    mux2x1 mux5(lOut[0][5], data[5], data[6], shift_amount[0]);
    mux2x1 mux6(lOut[0][6], data[6], data[7], shift_amount[0]);
    mux2x1 mux7(lOut[0][7], data[7], sign, shift_amount[0]);

    // MUX Level 2
    mux2x1 mux8(lOut[1][0], lOut[0][0], lOut[0][2], shift_amount[1]);
    mux2x1 mux9(lOut[1][1], lOut[0][1], lOut[0][3], shift_amount[1]);
    mux2x1 mux10(lOut[1][2], lOut[0][2], lOut[0][4], shift_amount[1]);
    mux2x1 mux11(lOut[1][3], lOut[0][3], lOut[0][5], shift_amount[1]);
    mux2x1 mux12(lOut[1][4], lOut[0][4], lOut[0][6], shift_amount[1]);
    mux2x1 mux13(lOut[1][5], lOut[0][5], lOut[0][7], shift_amount[1]);
    mux2x1 mux14(lOut[1][6], lOut[0][6], sign, shift_amount[1]);
    mux2x1 mux15(lOut[1][7], lOut[0][7], sign, shift_amount[1]);

    // MUX Level 3
    mux2x1 mux16(lOut[2][0], lOut[1][0], lOut[1][4], shift_amount[2]);
    mux2x1 mux17(lOut[2][1], lOut[1][1], lOut[1][5], shift_amount[2]);
    mux2x1 mux18(lOut[2][2], lOut[1][2], lOut[1][6], shift_amount[2]);
    mux2x1 mux19(lOut[2][3], lOut[1][3], lOut[1][7], shift_amount[2]);
    mux2x1 mux20(lOut[2][4], lOut[1][4], sign, shift_amount[2]);
    mux2x1 mux21(lOut[2][5], lOut[1][5], sign, shift_amount[2]);
    mux2x1 mux22(lOut[2][6], lOut[1][6], sign, shift_amount[2]);
    mux2x1 mux23(lOut[2][7], lOut[1][7], sign, shift_amount[2]);

    // Assign the final result with a 2 time unit delay
    assign #2 result = lOut[2];

endmodule


module right_rotate(data, shift_amount, result);

    // Input and output declarations
    input [7:0] data;
    input [7:0] shift_amount;
    output [7:0] result;

    // Intermediate wires for connecting MUX layers
    wire [7:0] lOut [2:0];

    // MUX Level 1
    mux2x1 mux0(lOut[0][0], data[0], data[1], shift_amount[0]);
    mux2x1 mux1(lOut[0][1], data[1], data[2], shift_amount[0]);
    mux2x1 mux2(lOut[0][2], data[2], data[3], shift_amount[0]);
    mux2x1 mux3(lOut[0][3], data[3], data[4], shift_amount[0]);
    mux2x1 mux4(lOut[0][4], data[4], data[5], shift_amount[0]);
    mux2x1 mux5(lOut[0][5], data[5], data[6], shift_amount[0]);
    mux2x1 mux6(lOut[0][6], data[6], data[7], shift_amount[0]);
    mux2x1 mux7(lOut[0][7], data[7], data[0], shift_amount[0]);

    // MUX Level 2
    mux2x1 mux8(lOut[1][0], lOut[0][0], lOut[0][2], shift_amount[1]);
    mux2x1 mux9(lOut[1][1], lOut[0][1], lOut[0][3], shift_amount[1]);
    mux2x1 mux10(lOut[1][2], lOut[0][2], lOut[0][4], shift_amount[1]);
    mux2x1 mux11(lOut[1][3], lOut[0][3], lOut[0][5], shift_amount[1]);
    mux2x1 mux12(lOut[1][4], lOut[0][4], lOut[0][6], shift_amount[1]);
    mux2x1 mux13(lOut[1][5], lOut[0][5], lOut[0][7], shift_amount[1]);
    mux2x1 mux14(lOut[1][6], lOut[0][6], lOut[0][0], shift_amount[1]);
    mux2x1 mux15(lOut[1][7], lOut[0][7], lOut[0][1], shift_amount[1]);

    // MUX Level 3
    mux2x1 mux16(lOut[2][0], lOut[1][0], lOut[1][4], shift_amount[2]);
    mux2x1 mux17(lOut[2][1], lOut[1][1], lOut[1][5], shift_amount[2]);
    mux2x1 mux18(lOut[2][2], lOut[1][2], lOut[1][6], shift_amount[2]);
    mux2x1 mux19(lOut[2][3], lOut[1][3], lOut[1][7], shift_amount[2]);
    mux2x1 mux20(lOut[2][4], lOut[1][4], lOut[1][0], shift_amount[2]);
    mux2x1 mux21(lOut[2][5], lOut[1][5], lOut[1][1], shift_amount[2]);
    mux2x1 mux22(lOut[2][6], lOut[1][6], lOut[1][2], shift_amount[2]);
    mux2x1 mux23(lOut[2][7], lOut[1][7], lOut[1][3], shift_amount[2]);

    // Assign the final result with a 2 time unit delay
    assign #2 result = lOut[2];

endmodule

