//lab 06 part 01 - Group 13

module pc_add(PC,PCADDED); 
    

    // declaring ports
    input [31:0] PC;    //initial PC value
    output reg [31:0] PCADDED;  //final PC value

    always @(PC) begin
    // assign PC_value +1 with 1 s  artificial delay
        #1 PCADDED=PC+4;
    end

endmodule

module pc_add_j_beq (PC,INSTRUCTION,OFFSET,PCADDED);
    //declaring ports
    input [31:0] PC;
    input [31:0] INSTRUCTION;
    input [31:0] OFFSET;
    output reg [31:0] PCADDED;

    //always read INSTRUCTION
    always @(INSTRUCTION)   begin
        #2 PCADDED=PC+OFFSET;
    end

endmodule

module mux32(IN1,IN2,OUT,SELECT);
    input [31:0] IN1, IN2;
	input SELECT;
	output reg [31:0] OUT;

    always @(*) begin 
        if (SELECT) begin 
            OUT = IN2; 
        end 

        else OUT = IN1;  
    end	
endmodule