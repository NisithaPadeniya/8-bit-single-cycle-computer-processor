//lab 05 part 03 - Group 13

module twos_compliment(IN,OUT);
    // declaring ports
    input [7:0] IN;
    output [7:0] OUT;

    // 2's complement operation
        //adding artificial delay of 1 second
        // Out = (fipping the bits in IN) + 1
    assign #1 OUT =(~IN)+1;

endmodule

module mux(IN1,IN2,SELECT,OUT);

    //declaring ports
    input [7:0] IN1, IN2;   // 2 inputs
    input SELECT;           // select bit input
    output reg [7:0] OUT;   // output

    // always taking inputs and updating the regarding output accordingly
    always @(IN1,IN2,SELECT)

    begin
        //if select bit is low
        if (SELECT==1'b0)
            begin
                assign OUT = IN1;  //switch to IN1
            end
        // else select bit is high
        else
            begin
                assign OUT = IN2;  //switch to IN2
            end
    end

endmodule


/*

//test twos_compliment
module stimulus;

    reg [7:0] IN;
    wire [7:0] OUT;

    twos_compliment test_tc(IN,OUT);

    initial begin
        IN=8'b00001111;
        #5
        $display("%b",OUT);

    end
endmodule 
*/