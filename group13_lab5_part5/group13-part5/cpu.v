//lab 05 part 04 - Group 13

`include "alu.v"
`include "reg_file.v"
`include "unit2.v"
`include "pc_updating.v"
`include "offset_handling.v"

// Register File module to store output values from ALU
module cpu(PC,INSTRUCTION, CLK, RESET) ;

    //Declaring ports
    //input Instruction
    input [31:0] INSTRUCTION;
    // clock signal and reset signal
    input CLK;
    input RESET;
    //Output port - program counter
    output reg [31:0] PC;
    //Current OPCODE for the CPU
    reg [7:0] OPCODE;

    //Declaring Connections to other modules
    //  alu
    wire [7:0] DATA1,DATA2; // input operands to alu
    reg [2:0] ALUOP;       // select input to alu (for selecting operation)
    wire [7:0] ALURESULT;   // output from alu - Result

    // register file
    wire[2:0] WRITEREG;    // input address to register file
    /*                        output ALURESULT from alu as input to register file */
    wire[2:0] READREG1;    // output-1  address from register file
    wire[2:0] READREG2;    // output-2 address from register file
    wire[7:0] REGOUT2;     // output-2 from reg file
    /*                        output-1 from reg file REGOUT1[7:0] is DATA1 input to alu*/
    reg WRITEENABLE;       // Writeenable to reg file

    // immediate mux
    wire [7:0] IMMEDIATE;   // immediate value as input_1 to the immediate_mux
    wire [7:0] NEGMUXOUT;   // negation_mux output as input_2 to the immediate_mux
    /*OUTPUT                   output of the immediate mux is DATA2 input to the ALU */
    reg IMSELECT;           // Select bit input to the immediate_mux

    // negation mux
    wire [7:0] TWOSOUT  ;   // Output from the 2's compliment as input_1 to the negation_mux
    /*INPUT2                   REGOUT2[7:0] Output from the reg file as input_2 to the negation_mux */
    /*OUTPUT                   NEGMUXOUT[7:0] as the output from negation_mux */
    reg NEGSELECT;           // Select bit input to the negation mux

    // program counter
    wire [31:0] PCADDED;            // output from program_counter 
    wire [31:0] PCUPDATED;
    // jump/beq/bne
    wire [7:0] OFFSET;
    reg JUMPSELECT,BEQSELECT;
    wire [31:0] S_EXTENDED_OFFSET;
    wire [31:0] SE_OFFSET_SHIFTED;
    wire [31:0] PCADDED_J_BEQ;
    reg BNESELECT;

    reg DIRECTION;        // Select bit input for shift operation

    //assigning fields of instruction format
    /* |   Opcode   |   Rd/Imm(offset)    |    Rt    |  Rs/Imm  |   */

    assign WRITEREG=INSTRUCTION[23:16];  //Rd => destination register
    assign OFFSET = INSTRUCTION[23:16];  // offset value
    assign READREG1=INSTRUCTION[15:8];   //Rt => 1st operand register
    assign READREG2=INSTRUCTION[7:0];    //Rs => 2nd operand register
    assign IMMEDIATE=INSTRUCTION[7:0];   //immediate value register

    //Control Unit-Program Counter update
    // program counter adder
    pc_add cpu_pc_add(PC,PCADDED);

    // sign exted
    sign_extend cpu_sign_extend(OFFSET,S_EXTENDED_OFFSET);

    //shift
    shift cpu_shift(S_EXTENDED_OFFSET,SE_OFFSET_SHIFTED);

    // program counter adder for jump and beq
    pc_add_j_beq cpu_pc_add_j_beq(PCADDED,INSTRUCTION,SE_OFFSET_SHIFTED,PCADDED_J_BEQ);

    always @(posedge CLK) begin //always at the +ve edge of the clock pulse
      
        // if reset is high program counter value=>0
        if (RESET==1'b1)   begin 
        #1 PC =0;    //+1 time unit delay
        end
    end
    
    always @(posedge CLK) begin   // pc update
        #1 PC =PCUPDATED;           //+ 1 time unit delay
    end
    
    //calling all the cpu modules

    //register file
    regfile cpu_reg_file(ALURESULT,WRITEREG,READREG1,READREG2,CLK,RESET,WRITEENABLE,DATA1,REGOUT2);


    // 2's compliment
    twos_compliment cpu_tc(REGOUT2,TWOSOUT);

    // Negation mux
    mux cpu_neg_mux(REGOUT2,TWOSOUT,NEGSELECT,NEGMUXOUT);

    // Immediate mux
    mux cpu_im_mux(NEGMUXOUT,IMMEDIATE,IMSELECT,DATA2);

    //alu
    alu cpu_alu(DATA1,DATA2,ALURESULT,ALUOP,ZERO,DIRECTION);

   //jump or beq mux
    wire isBEQ,isJ_OR_BEQ,isBNE;
    assign isBEQ = BEQSELECT & ZERO;
    assign isBNE = (~ZERO) & BNESELECT;
    assign isJ_OR_BEQ = JUMPSELECT | isBEQ | isBNE;
    mux32 cpu_mux32(PCADDED,PCADDED_J_BEQ,PCUPDATED,isJ_OR_BEQ);

    
    //Instruction Decoding

    always @(INSTRUCTION)   //decoding process occurs continuosly
    begin
        OPCODE=INSTRUCTION[31:24];       //Opcode field in the instruction format
        #1                              //adding 1 time unit delay
    
        case(OPCODE)
            //loadi 
            8'b00000000:	begin
                                ALUOP = 3'b000;			//Set alu to FORWARD
                                IMSELECT = 1'b1;		//Set immeiate_mux to select immediate value
                                NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
                                WRITEENABLE = 1'b1;		//Enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
                            end
            
            //mov
			8'b00000001:	begin
								ALUOP = 3'b000;			//Set alu to FORWARD
								IMSELECT = 1'b0;		//Set imm_mux to select register i/p
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//Enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
							end
            
            //add
			8'b00000010:	begin
								ALUOP = 3'b001;			//Set alu to ADD
								IMSELECT= 1'b0;		    //Set imm_mux to select register i/p
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//Enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
							end	
		
			//sub 
			8'b00000011:	begin
								ALUOP = 3'b001;			//Set alu to ADD
								IMSELECT = 1'b0;		//Set imm_mux to select register input
								NEGSELECT = 1'b1;		//Set neg_mux to select negative sign
								WRITEENABLE = 1'b1;		//Enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
							end

			//and 
			8'b00000100:	begin
								ALUOP = 3'b010;			//Set alu to AND
								IMSELECT = 1'b0;		//Set imm_mux to select register input
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//Enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
							end
							
			//or 
			8'b00000101:	begin
								ALUOP = 3'b011;			//Set ALU to OR
								IMSELECT = 1'b0;		//Set imm_mux to select register input
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//Enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
							end
            // jump
            8'b00000110:	begin
								IMSELECT = 1'b0;		//Set imm_mux to select register input
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b0;		//disable writing to register
                                JUMPSELECT=1'b1;        //enable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
							end
            // beq
            8'b00000111:	begin
								ALUOP = 3'b001;			//Set ALU to add
								IMSELECT = 1'b0;		//Set imm_mux to select register input
								NEGSELECT = 1'b1;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b0;		//disable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b1;         //enable beq 
                                BNESELECT=1'b0;         //disable bne
							end
            
            // bne
            8'b00001100:	begin
								ALUOP = 3'b001;			//Set ALU to add
								IMSELECT = 1'b0;		//Set imm_mux to select register input
								NEGSELECT = 1'b1;		//Set neg_mux to select negative sign
								WRITEENABLE = 1'b0;		//disable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b1;         //enable bne

							end

            // mult
             8'b00001101:	begin
								ALUOP = 3'b100;			//Set ALU to mult
								IMSELECT = 1'b0;		//Set imm_mux to select register input
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//ensable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne

							end

            // left shift logical
             8'b00001110:	begin
								ALUOP = 3'b101;			//Set ALU to left shift
								IMSELECT = 1'b1;		//Set imm_mux to select immediate value
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
                                DIRECTION = 1'b0;       //select left shift

							end

            // right shift logical
             8'b00001111:	begin
								ALUOP = 3'b101;			//Set ALU to right shift
								IMSELECT = 1'b1;		//Set imm_mux to select immediate value
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne
                                DIRECTION = 1'b1;       //select right shift

							end

            // right shift arithmatic
            8'b00010000:	begin
								ALUOP = 3'b110;			//Set ALU to right shift arithmatic
								IMSELECT = 1'b1;		//Set imm_mux to select immediate value
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne

            				end

            // right rotate
            8'b00010001:	begin
								ALUOP = 3'b111;			//Set ALU to right shift arithmatic
								IMSELECT = 1'b1;		//Set imm_mux to select immediate value
								NEGSELECT = 1'b0;		//Set neg_mux to select positive sign
								WRITEENABLE = 1'b1;		//enable writing to register
                                JUMPSELECT=1'b0;        //disable jump
                                BEQSELECT=1'b0;         //disable beq 
                                BNESELECT=1'b0;         //disable bne

							end
			
        endcase
    end
    
endmodule