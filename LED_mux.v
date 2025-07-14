`timescale 1ns / 1ps

module LED_mux
	#(parameter N=19) 
	(
	input clk,rst,
	input[4:0] in0,in1,in2,in3,in4,in5, 
	output reg[7:0] seg_out,
	output reg[5:0] sel_out
    );
	 
	 reg[N-1:0] r_reg=0;
	 reg[4:0] hex_out=0;
	 wire[N-1:0] r_nxt;
	 wire[2:0] out_counter; //last 3 bits to be used as output signal
	 
	 
	
	 always @(posedge clk,negedge rst)
	 if(!rst) r_reg<=0;
	 else r_reg<=r_nxt;
	 
	 assign r_nxt=(r_reg=={3'd5,{(N-3){1'b1}}})?19'd0:r_reg+1'b1; 
	 assign out_counter=r_reg[N-1:N-3];
	 
	 
	
	 always @(out_counter) begin
		 sel_out=6'b111_111;    //active low
		 sel_out[out_counter]=1'b0;
	 end
	  
	
	 always @* begin
		 hex_out=0;
			 casez(out_counter)
			 3'b000: hex_out=in0;
			 3'b001: hex_out=in1;
			 3'b010: hex_out=in2;
			 3'b011: hex_out=in3;
			 3'b100: hex_out=in4;
			 3'b101: hex_out=in5;
			 endcase
	 end
	 	 
	 
always @* begin
    case (hex_out[3:0])
        4'h0: seg_out[6:0] = 7'b1000000; // 0
        4'h1: seg_out[6:0] = 7'b1111001; // 1
        4'h2: seg_out[6:0] = 7'b0100100; // 2
        4'h3: seg_out[6:0] = 7'b0110000; // 3
        4'h4: seg_out[6:0] = 7'b0011001; // 4
        4'h5: seg_out[6:0] = 7'b0010010; // 5
        4'h6: seg_out[6:0] = 7'b0000010; // 6
        4'h7: seg_out[6:0] = 7'b1111000; // 7
        4'h8: seg_out[6:0] = 7'b0000000; // 8
        4'h9: seg_out[6:0] = 7'b0010000; // 9
        4'hA: seg_out[6:0] = 7'b0001000; // A
        4'hB: seg_out[6:0] = 7'b0000011; // b
        4'hC: seg_out[6:0] = 7'b1000110; // C
        4'hD: seg_out[6:0] = 7'b0100001; // d
        4'hE: seg_out[6:0] = 7'b0000110; // E
        4'hF: seg_out[6:0] = 7'b0001110; // F
        default: seg_out[6:0] = 7'b1111111;
    endcase

    
    seg_out[7] = ~hex_out[4];   
end

endmodule
