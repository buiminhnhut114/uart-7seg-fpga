`timescale 1ns / 1ps
module rotating_LED #(
    parameter turns = 25_000_000,  
    parameter W     = 10,          
    parameter D     = 6            
)(
    input            clk,
    input            rst_n,
    input            rx,           
    output reg [4:0] in0,
    output reg [4:0] in1,
    output reg [4:0] in2,
    output reg [4:0] in3,
    output reg [4:0] in4,
    output reg [4:0] in5
);

  //==================================================================
  //                           UART + FIFO
  //==================================================================
  reg        rd_uart;
  wire       rx_empty;
  wire [7:0] rd_data;

  uart #(
    .DBIT        (8),
    .SB_TICK     (16),
    .DVSR        (326),
    .DVSR_WIDTH  (9),
    .FIFO_W      (4)
  ) u_uart (
    .clk      (clk),
    .rst_n    (rst_n),
    .rd_uart  (rd_uart),
    .rx       (rx),
    .rd_data  (rd_data),
    .rx_empty (rx_empty)
  );

  //==================================================================
  //                           Tick generator 
  //==================================================================
  reg [24:0] ctr;
  wire       tick = (ctr == turns);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)            ctr <= 0;
    else if (ctr == turns) ctr <= 0;
    else                   ctr <= ctr + 1;
  end

  //==================================================================
  //                           Banner FIFO 
  //==================================================================
  reg [5*W-1:0] banner, banner_nxt;
  localparam [5*W-1:0] INIT = {
    {1'b0,4'h0},{1'b0,4'h1},{1'b0,4'h2},{1'b0,4'h3},{1'b0,4'h4},
    {1'b0,4'h5},{1'b0,4'h6},{1'b0,4'h7},{1'b0,4'h8},{1'b0,4'h9}
  };

  reg       play,        play_nxt;
  reg       sel,         sel_nxt;      // select mode (move_mode)
  reg [2:0] pos,         pos_nxt;      // chỉ 0..D-1
  reg       blink_flag,  blink_flag_nxt;

  reg       cmd_move,    cmd_insert;
  reg [3:0] digit;

  integer i;

  //==================================================================
  //                            decode UART 
  //==================================================================
  always @* begin
    // defaults
    play_nxt       = play;
    sel_nxt        = sel;
    pos_nxt        = pos;
    blink_flag_nxt = blink_flag;
    rd_uart        = 0;
    cmd_move       = 0;
    cmd_insert     = 0;
    digit          = 0;

    
    if (tick)
      blink_flag_nxt = ~blink_flag;

    
    if (!rx_empty) begin
      rd_uart = 1;
      case (rd_data)
        
        8'h67,8'h47: begin 
          play_nxt = 1; 
          sel_nxt  = 0; 
        end
        
        8'h70,8'h50: begin 
          play_nxt = 0; 
          sel_nxt  = 0; 
        end
       
        8'h6D,8'h4D: begin 
          cmd_move = 1; 
        end
        default: 
          
          if (sel && rd_data>=8'h30 && rd_data<=8'h39) begin
            cmd_insert = 1;
            digit       = rd_data[3:0];
          end
      endcase
    end

    
    if (cmd_move) begin
      if (!sel) begin
        sel_nxt        = 1;
        pos_nxt        = 0;
        blink_flag_nxt = 1;
      end else begin
        pos_nxt        = (pos == D-1) ? 0 : pos + 1;
      end
    end

    
  end

  //==================================================================
  //                  state, rotate, insert
  //==================================================================
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      banner     <= INIT;
      play       <= 0;
      sel        <= 0;
      pos        <= 0;
      blink_flag <= 0;
      
    end else begin
      // cập nhật flags
      play       <= play_nxt;
      sel        <= sel_nxt;
      pos        <= pos_nxt;
      blink_flag <= blink_flag_nxt;

      
      if (tick && play && !sel) begin
        banner <= {banner[5*W-6:0], banner[5*W-1:5]};
      end

      
      if (cmd_insert && sel) begin
        banner_nxt = banner;
        banner_nxt[5*(W-1-pos)+:5] = {1'b0, digit};
        banner <= banner_nxt;
      end
    end
  end

  //==================================================================
  //                                Output 
  //==================================================================
  always @(*) begin
    // 6 ký tự đầu từ banner
    in5 = banner[5*W-1   -:5];
    in4 = banner[5*W-6   -:5];
    in3 = banner[5*W-11  -:5];
    in2 = banner[5*W-16  -:5];
    in1 = banner[5*W-21  -:5];
    in0 = banner[5*W-26  -:5];

    
    if (sel && !blink_flag) begin
      case (pos)
        0: in5 = 5'b00000;
        1: in4 = 5'b00000;
        2: in3 = 5'b00000;
        3: in2 = 5'b00000;
        4: in1 = 5'b00000;
        5: in0 = 5'b00000;
      endcase
    end
  end

endmodule
