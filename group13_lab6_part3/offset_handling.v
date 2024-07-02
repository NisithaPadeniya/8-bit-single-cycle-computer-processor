//lab 06 part 01 - Group 13

module sign_extend(IN,OUT);
    //declaring ports
    input [7:0] IN;
    output reg [31:0] OUT;

    //always block to offset
    always @(IN) begin
        OUT={{24{IN[7]}},IN};
    end
endmodule

module shift(OFFSET,SHIFTED_OFFSET);
    //declaring ports 
    input [31:0]   OFFSET;
    output reg [31:0]   SHIFTED_OFFSET;

    //always block
    always @(OFFSET) begin
        SHIFTED_OFFSET=OFFSET<<2;
    end
endmodule