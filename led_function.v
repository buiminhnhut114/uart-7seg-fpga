`timescale 1ns / 1ps

module led_function #(
    parameter turns = 25_000_000,   // 0.5 s @50 MHz
    parameter W     = 10,           // 5 bits per char
    parameter D     = 6             // display positions
)(
    input  wire       clk,     // 50 MHz
    input  wire       rst_n,   // active‑low reset
    input  wire       rx,      // UART RX (PC → FPGA)
    output wire       tx,      // UART TX (FPGA → PC)
    output reg [4:0]  in0, in1, in2, in3, in4, in5  // banner outputs
);

  // 1) Baud tick + UART RX
  wire        s_tick;
  wire        rx_done_tick;
  wire [7:0]  rx_data;
  wire        tx_done_tick;

  baud_generator #(.N(326), .N_width(9)) baud_gen (
    .clk    (clk), 
    .rst_n  (rst_n), 
    .s_tick (s_tick)
  );

  uart_rx #(.DBIT(8), .SB_TICK(16)) u_rx (
    .clk          (clk),
    .rst_n        (rst_n),
    .rx           (rx),
    .s_tick       (s_tick),
    .rx_done_tick (rx_done_tick),
    .dout         (rx_data)
  );

uart_tx #(.DBIT(8), .SB_TICK(16)) u_tx (
  .clk         (clk),
  .rst_n       (rst_n),
  .s_tick      (s_tick),
  .tx_start    (rx_done_tick),
  .din         (rx_data),
  .tx_done_tick(tx_done_tick),
  .tx          (tx)
);

  // 3) Banner rotation logic
  reg [24:0] ctr;
  wire       tick = (ctr == turns);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)            ctr <= 0;
    else if (ctr == turns) ctr <= 0;
    else                   ctr <= ctr + 1;
  end

  // Banner buffer & state
  reg [5*W-1:0] banner, banner_nxt;
  localparam [5*W-1:0] INIT = {
    {1'b0,4'h0},{1'b0,4'h1},{1'b0,4'h2},
    {1'b0,4'h3},{1'b0,4'h4},{1'b0,4'h5},
    {1'b0,4'h6},{1'b0,4'h7},{1'b0,4'h8},
    {1'b0,4'h9}
  };

  reg        play,        play_nxt;
  reg        sel,         sel_nxt;
  reg [2:0]  pos,         pos_nxt;
  reg        blink_flag,  blink_flag_nxt;
  reg        cmd_move,    cmd_insert;
  reg [3:0]  digit;

  // Decode commands on rx_done_tick
  always @* begin
    play_nxt       = play;
    sel_nxt        = sel;
    pos_nxt        = pos;
    blink_flag_nxt = blink_flag;
    cmd_move       = 1'b0;
    cmd_insert     = 1'b0;
    digit          = 4'b0;

    if (tick)
      blink_flag_nxt = ~blink_flag;

    if (rx_done_tick) begin
      case (rx_data)
        8'h67, 8'h47: begin // 'g' or 'G'
          play_nxt = 1'b1; sel_nxt = 1'b0;
        end
        8'h70, 8'h50: begin // 'p' or 'P'
          play_nxt = 1'b0; sel_nxt = 1'b0;
        end
        8'h6D, 8'h4D: cmd_move = 1'b1; // 'm' or 'M'
        default:
          if (sel && rx_data>=8'h30 && rx_data<=8'h39) begin
            cmd_insert = 1'b1;
            digit       = rx_data[3:0];
          end
      endcase
    end

    if (cmd_move) begin
      if (!sel) begin
        sel_nxt        = 1'b1;
        pos_nxt        = 3'd0;
        blink_flag_nxt = 1'b1;
      end else begin
        pos_nxt = (pos == D-1) ? 3'd0 : pos + 3'd1;
      end
    end
  end

  // State update & banner shift/insert
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      banner     <= INIT;
      play       <= 1'b0;
      sel        <= 1'b0;
      pos        <= 3'd0;
      blink_flag <= 1'b0;
    end else begin
      play       <= play_nxt;
      sel        <= sel_nxt;
      pos        <= pos_nxt;
      blink_flag <= blink_flag_nxt;

      if (tick && play && !sel)
        banner <= { banner[5*W-6:0], banner[5*W-1:5] };

      if (cmd_insert && sel) begin
        banner_nxt                 = banner;
        banner_nxt[5*(W-1-pos)+:5] = {1'b0, digit};
        banner                     <= banner_nxt;
      end
    end
  end

  // Drive 6 chars to 7‑seg
  always @* begin
    in5 = banner[5*W-1   -:5];
    in4 = banner[5*W-6   -:5];
    in3 = banner[5*W-11  -:5];
    in2 = banner[5*W-16  -:5];
    in1 = banner[5*W-21  -:5];
    in0 = banner[5*W-26  -:5];

    if (sel && !blink_flag) begin
      case (pos)
        3'd0: in5 = 5'b00000;
        3'd1: in4 = 5'b00000;
        3'd2: in3 = 5'b00000;
        3'd3: in2 = 5'b00000;
        3'd4: in1 = 5'b00000;
        3'd5: in0 = 5'b00000;
      endcase
    end
  end

endmodule
