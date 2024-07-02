module comparator(IN1,IN2,OUT);
	input[2:0] IN1,IN2;
	output OUT;

	//xnor each bit and did and operation 
	assign #0.9 OUT = IN1[0]~^IN2[0] && IN1[1]~^IN2[1] && IN1[2]~^IN2[2];   
endmodule