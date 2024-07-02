module cmp(IN1,IN2,OUT);
	input[2:0] IN1,IN2;
	output OUT;

	//xnor each bit and did and operation 
	assign OUT = &(IN1 ~^ IN2);  
endmodule

