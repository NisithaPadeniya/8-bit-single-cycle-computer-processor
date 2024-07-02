`timescale  1ns/100ps

module mux4to1(IN1, IN2, IN3, IN4, SELECT, OUT);
    input [7:0] IN1, IN2, IN3, IN4;  // 4 inputs
    input [1:0] SELECT;              // select bit input
    output reg [7:0] OUT;            // output

    always @(IN1, IN2, IN3, IN4, SELECT)
    begin
        case (SELECT)
            2'b00: #1 OUT = IN1;  // switch to IN1
            2'b01: #1 OUT = IN2;  // switch to IN2
            2'b10: #1 OUT = IN3;  // switch to IN3
            2'b11: #1 OUT = IN4;  // switch to IN4
            default: OUT = 8'b0;  // default case
        endcase
    end
endmodule







 