module top_de2 (
    input  wire        clk,        
    input  wire        rst_n,      
    input  wire        rx,         
    output wire        tx,

   
    output wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7
);
    wire [7:0] seg;
    wire [5:0] sel_n;
    wire [4:0] in0,in1,in2,in3,in4,in5;

    assign tx = 1'b1;              

    rotating_LED #(.turns(25_000_000)) core (
        .clk   (clk),
        .rst_n (rst_n),
        .rx    (rx),
        .in0(in0),.in1(in1),.in2(in2),.in3(in3),.in4(in4),.in5(in5)
    );

    LED_mux mux (
        .clk(clk), .rst(rst_n),
        .in0(in0), .in1(in1), .in2(in2),
        .in3(in3), .in4(in4), .in5(in5),
        .seg_out(seg), .sel_out(sel_n)
    );

    sevenseg_router r (
        .seg(seg), .sel_n(sel_n),
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3),
        .HEX4(HEX4), .HEX5(HEX5), .HEX6(HEX6), .HEX7(HEX7)
    );
endmodule
