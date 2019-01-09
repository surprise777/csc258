module Morse(SW, KEY, LEDR, CLOCK_50);
	input [3:0] SW;
	input [1:0] KEY;
	input CLOCK_50;
	output [0:0] LEDR;
	
	assign enable = SW[3];
	assign reset = KEY[0];
	assign load = KEY[1];
	
	wire [14:0] LutOut;
	wire [0:0] EN;
	wire [0:0] ShifterOut;
	
	LUT L0(
		.in(SW[2:0]), 
		.out(LutOut[14:0]));
	
	rate_divider RD0(
					.EN(EN), 
					.clock(CLOCK_50), 
					.clear_b(reset), 
					.enable(enable));
	
	ShiftRegister SR0(
					.in(LutOut[14:0]), 
					.load(load), 
					.reset(reset), 
					.clk(CLOCK_50), 
					.en(EN), 
					.out(ShifterOut));
	
	assign LEDR[0] = ShifterOut;


endmodule


module LUT(in, out);
	input [2:0] in;
	output reg [14:0] out;
	
	always @(*)
	begin
		case (in[2:0])
			3'b000: out = 15'b010101000000000;
			3'b001: out = 15'b011100000000000;
			3'b010: out = 15'b010101110000000;
			3'b011: out = 15'b010101011100000;
			3'b100: out = 15'b010111011100000;
			3'b101: out = 15'b011101010111000;
			3'b110: out = 15'b011101011101110;
			3'b111: out = 15'b011101110100000;
			default: out = 15'b000000000000000;
		endcase
	end

endmodule


module rate_divider(EN, clock, clear_b, enable);
    output EN;
    input clock;
    input clear_b;
	 input enable;

	 reg [3:0] count;

    always @(posedge clock)
	 begin
	     if (clear_b == 1'b0)
		      count <= 4'd9;
			
		  else if (count == 0)
            count <= 4'd9;
				
        else if (enable == 1'b1)
				count <= count - 1'd1;
	 end
	 
	 assign EN = (count == 4'd0) ? 1 : 0;
endmodule


module ShiftRegister(in, load, reset, clk, en, out);
	input [14:0] in;
	input load;
	input reset;
	input clk;
	input en;
	output out;
	
	reg [14:0] register;
	
	always @(posedge clk, negedge reset, negedge load)
	begin
		if (reset == 1'b0)
			register <= 15'b000000000000000;
		
		else if (load == 1'b0)
			register <= in;
		
		else if (en == 1'b1)
			register <= {register[13:0], 1'b0};
	
	end
	
	assign out = register[14];

endmodule 
