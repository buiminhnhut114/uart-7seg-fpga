module top_de2 (
    input  wire        clk,        // 50 MHz
    input  wire        rst_n,      // active-low reset
    input  wire        rx,         // UART RX from PC
    output wire        tx,         // UART TX to PC
    output wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7
);
    // Banner characters from core
    wire [4:0] in0, in1, in2, in3, in4, in5;

    // Two-way UART + banner logic in led_function core
    led_function #(
        .turns(25_000_000),
        .W    (10),
        .D    (6)
    ) core (
        .clk   (clk),
        .rst_n (rst_n),
        .rx    (rx),
        .tx    (tx),
        .in0   (in0),
        .in1   (in1),
        .in2   (in2),
        .in3   (in3),
        .in4   (in4),
        .in5   (in5)
    );

    // 7-segment mux and router
    wire [7:0] seg;
    wire [5:0] sel_n;
    LED_mux mux (
        .clk     (clk),
        .rst     (rst_n),
        .in0     (in0),
        .in1     (in1),
        .in2     (in2),
        .in3     (in3),
        .in4     (in4),
        .in5     (in5),
        .seg_out (seg),
        .sel_out (sel_n)
    );

    sevenseg_router r (
        .seg   (seg),
        .sel_n (sel_n),
        .HEX0  (HEX0),
        .HEX1  (HEX1),
        .HEX2  (HEX2),
        .HEX3  (HEX3),
        .HEX4  (HEX4),
        .HEX5  (HEX5),
        .HEX6  (HEX6),
        .HEX7  (HEX7)
    );

endmodule
