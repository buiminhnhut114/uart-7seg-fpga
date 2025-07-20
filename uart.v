`timescale 1ns/1ps
module uart #(
  parameter CLOCK_FREQ = 50_000_000,  // 50 MHz
  parameter BAUD       = 9600,        // baud rate
  parameter DBIT       = 8,           // data bits
  parameter SB_TICK    = 16           // oversampling ticks per stop bit
)(
  input  wire              clk,
  input  wire              rst_n,

  // RX side
  input  wire              rx,
  output wire [DBIT-1:0]   rx_data,
  output wire              rx_valid,

  // TX side
  input  wire              tx_start,
  input  wire [DBIT-1:0]   tx_data,
  output wire              tx,
  output wire              tx_done
);

  //==================================================================
  // 1) Baud‐rate generator
  //==================================================================
  localparam integer DIV = CLOCK_FREQ / BAUD;
  reg [31:0] cnt;
  reg        baud_tick;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt       <= 0;
      baud_tick <= 0;
    end
    else if (cnt == DIV/2) begin
      cnt       <= 0;
      baud_tick <= 1;
    end
    else begin
      cnt       <= cnt + 1;
      baud_tick <= 0;
    end
  end

  //==================================================================
  // 2) UART Receiver
  //==================================================================
  uart_rx #(
    .DBIT    (DBIT),
    .SB_TICK (SB_TICK)
  ) u_rx (
    .clk          (clk),
    .rst_n        (rst_n),
    .rx           (rx),
    .s_tick       (baud_tick),
    .dout         (rx_data),
    .rx_done_tick (rx_valid)
  );

  //==================================================================
  // 3) UART Transmitter
  //==================================================================
  uart_tx #(
    .DBIT    (DBIT),
    .SB_TICK (SB_TICK)
  ) u_tx (
    .clk          (clk),
    .rst_n        (rst_n),
    .s_tick       (baud_tick),
    .tx_start     (tx_start),
    .din          (tx_data),
    .tx           (tx),
    .tx_done_tick (tx_done)
  );

endmodule
