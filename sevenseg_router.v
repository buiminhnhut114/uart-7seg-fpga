module sevenseg_router (
    input  wire [7:0] seg,        
    input  wire [5:0] sel_n,      
    output reg  [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output     [6:0] HEX6, HEX7   
);
    
    always @(*) begin
        {HEX0,HEX1,HEX2,HEX3,HEX4,HEX5} = {6{7'h7f}};
        if (!sel_n[0]) HEX0 = seg[6:0];
        if (!sel_n[1]) HEX1 = seg[6:0];
        if (!sel_n[2]) HEX2 = seg[6:0];
        if (!sel_n[3]) HEX3 = seg[6:0];
        if (!sel_n[4]) HEX4 = seg[6:0];
        if (!sel_n[5]) HEX5 = seg[6:0];
    end
    assign HEX6 = 7'h7f;   
    assign HEX7 = 7'h7f;
endmodule
