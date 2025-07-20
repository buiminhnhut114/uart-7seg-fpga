`timescale 1ns / 1ps

module tb_led_function;

  //================================================================
  // PARAMETERS & SIGNAL DECLARATION
  //================================================================
  localparam turns       = 25_000_000; // matches DUT parameter
  localparam BAUD_PERIOD = 20;         // 20 ns per UART bit at 50 MHz

  // DUT inputs
  reg        clk;
  reg        rst_n;
  reg        rx;

  // DUT outputs
  wire [4:0] in0, in1, in2, in3, in4, in5;

  //================================================================
  // DUT INSTANTIATION
  //================================================================
  led_function #(.turns(turns)) uut (
    .clk   (clk),
    .rst_n (rst_n),
    .rx    (rx),
    .in0   (in0),
    .in1   (in1),
    .in2   (in2),
    .in3   (in3),
    .in4   (in4),
    .in5   (in5)
  );

  //================================================================
  // CLOCK GENERATOR (50 MHz)
  //================================================================
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  //================================================================
  // WAVEFORM DUMP
  //================================================================
  initial begin
    $dumpfile("tb_rotating_LED.vcd");
    $dumpvars(0, tb_rotating_LED);
  end

  //================================================================
  // TASK: SEND ONE BYTE OVER UART ON 'rx'
  //================================================================
  task send_uart_byt(input [7:0] byt);
    integer b;
    begin
      // start bit
      rx = 0; #(BAUD_PERIOD);
      // eight data bits, LSB first
      for (b = 0; b < 8; b = b + 1) begin
        rx = byt[b];
        #(BAUD_PERIOD);
      end
      // stop bit + idle
      rx = 1; #(BAUD_PERIOD);
      #(BAUD_PERIOD);
    end
  endtask

  //================================================================
  // MAIN TEST SEQUENCE
  //================================================================
  initial begin
    // 1) RESET
    rst_n = 0; rx = 1;
    #100;                    // hold reset for 100 ns
    rst_n = 1;
    $display("\n[Test] Reset released at time %0t", $time);

    // 2) AUTO-ROTATION VERIFICATION (no UART traffic)
    #turns;
    $display("[T0] after 1 turn:   in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);
    #turns;
    $display("[T0] after 2 turns:  in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);

    // 3) PLAY: uppercase 'G' (0x47)
    $display("\n[Test] Sending 'G' (0x47) ? PLAY");
    send_uart_byt(8'h47);
    #turns;
    $display("[T1] play (G):      in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);

    // 4) PLAY: lowercase 'g' (0x67)
    $display("\n[Test] Sending 'g' (0x67) ? PLAY");
    send_uart_byt(8'h67);
    #turns;
    $display("[T2] play (g):      in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);

    // 5) PAUSE: uppercase 'P' (0x50)
    $display("\n[Test] Sending 'P' (0x50) ? PAUSE");
    send_uart_byt(8'h50);
    #turns;
    $display("[T3] pause (P):     in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);

    // 6) PAUSE: lowercase 'p' (0x70)
    $display("\n[Test] Sending 'p' (0x70) ? PAUSE");
    send_uart_byt(8'h70);
    #turns;
    $display("[T4] pause (p):     in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);

    // 7) REVERSE: uppercase 'D' (0x44)
    $display("\n[Test] Sending 'D' (0x44) ? REVERSE");
    send_uart_byt(8'h44);
    #turns;
    $display("[T5] reverse (D):   in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);

    // 8) REVERSE: lowercase 'd' (0x64)
    $display("\n[Test] Sending 'd' (0x64) ? REVERSE");
    send_uart_byt(8'h64);
    #turns;
    $display("[T6] reverse (d):   in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);

    // 9) MULTI-DIGIT INSERTION: '4','5','6'
    $display("\n[Test] Sending '4','5','6'");
    send_uart_byt(8'h34);
    send_uart_byt(8'h35);
    send_uart_byt(8'h36);
    #turns;
    $display("[T7] after 4,5,6:    in5..in0 = %b %b %b %b %b %b",
             in5, in4, in3, in2, in1, in0);

    // FINISH
    #100;
    $display("\n=== ALL TESTS COMPLETE ===");
    $finish;
  end

endmodule

