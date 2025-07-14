`timescale 1ns/1ps
module tb_uart;
  // Tham số phải khớp với module uart
  parameter DBIT        = 8;
  parameter SB_TICK     = 16;
  parameter DVSR        = 326;
  parameter DVSR_WIDTH  = 9;
  parameter FIFO_W      = 2;
  // Tính chu kỳ bit (DVSR × SB_TICK × 20ns)
  localparam integer BIT_PERIOD = DVSR * SB_TICK * 20;
  // Test vector chỉ in hoa
  reg [7:0] test_chars [0:2];
  integer   i, num_pass, num_fail;

  // Clock & reset & handshake
  reg        clk = 0;
  reg        rst_n;
  reg        rd_uart;
  reg        rx;
  wire [7:0] rd_data;
  wire       rx_empty;

  // Hierarchical signals để monitor
  wire       s_tick        = uut.s_tick;
  wire       rx_done_tick  = uut.rx_done_tick;
  wire [7:0] dout          = uut.dout;
  wire       fifo_full     = uut.m2.full;
  wire [1:0] wr_ptr        = uut.m2.wr_ptr;
  wire [1:0] rd_ptr        = uut.m2.rd_ptr;

  // Instantiate UART (bao gồm baud_generator, uart_rx, fifo bên trong)
  uart #(
    .DBIT(DBIT),
    .SB_TICK(SB_TICK),
    .DVSR(DVSR),
    .DVSR_WIDTH(DVSR_WIDTH),
    .FIFO_W(FIFO_W)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .rd_uart(rd_uart),
    .rx(rx),
    .rd_data(rd_data),
    .rx_empty(rx_empty)
  );

  // 50 MHz clock
  always #10 clk = ~clk;

  initial begin
    // Khởi tạo counters
    num_pass = 0;
    num_fail = 0;
    // Test only uppercase
    test_chars[0] = "M";
    test_chars[1] = "P";
    test_chars[2] = "G";
    // Init signals
    rst_n   = 0;
    rd_uart = 0;
    rx      = 1;
    #100;
    rst_n = 1;
    #100;

    // Gửi và kiểm tra từng ký tự
    for (i = 0; i < 3; i = i + 1) begin
      send_byte(test_chars[i]);
      // Chờ có dữ liệu trong FIFO
      wait (rx_empty == 0);
      // Đợi thêm 1 BIT_PERIOD để dữ liệu chắc chắn ổn định
      #BIT_PERIOD;
      // Đọc ra
      @(posedge clk) rd_uart = 1;
      @(posedge clk) rd_uart = 0;
      #50;
      // So sánh và cập nhật pass/fail
      if (rd_data === test_chars[i]) begin
        num_pass = num_pass + 1;
        $display(">>> PASS: sent '%c', received '%c' @%0t", test_chars[i], rd_data, $time);
      end else begin
        num_fail = num_fail + 1;
        $display("!!! FAIL: sent '%c', received '%c' @%0t", test_chars[i], rd_data, $time);
      end
      #150;
    end

    // In tổng kết
    #200;
    $display("======== TEST SUMMARY ========");
    $display("  Total sent  : %0d", 3);
    $display("  Passed      : %0d", num_pass);
    $display("  Failed      : %0d", num_fail);
    if (num_fail == 0)
      $display("  RESULT      : ALL PASSED");
    else
      $display("  RESULT      : SOME FAILED");
    $display("==============================");
    #50;
    $finish;
  end

  // Task sinh sóng UART (1 start, 8 data, 1 stop)
  task send_byte(input [7:0] data);
    integer k;
    begin
      // Start bit
      rx = 0; #BIT_PERIOD;
      // Data bits, LSB trước
      for (k = 0; k < DBIT; k = k + 1) begin
        rx = data[k];
        #BIT_PERIOD;
      end
      // Stop bit
      rx = 1; #BIT_PERIOD;
    end
  endtask

  // Monitor chi tiết nội bộ mỗi chu kỳ clock
  always @(posedge clk) begin
    if (s_tick)
      $display(">>> s_tick @%0t", $time);
    if (rx_done_tick)
      $display(">>> rx_done_tick @%0t, dout=0x%h ('%c')", $time, dout, dout);
    if (fifo_full)
      $display(">>> WARNING: FIFO FULL @%0t", $time);
    if (rx_empty)
      $display(">>> INFO:    FIFO EMPTY @%0t", $time);
    $display("    FIFO ptrs: wr_ptr=%0d rd_ptr=%0d", wr_ptr, rd_ptr);
  end

endmodule
