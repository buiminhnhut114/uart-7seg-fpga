`timescale 1ns/1ps
module tb_baud_generator;
  localparam CLK_PER  = 20;
  localparam N        = 326;
  localparam N_width  = 9;
  localparam TEST_CYC = 1000;     

  reg        clk     = 0;
  reg        rst_n   = 0;
  wire       s_tick;


  reg [31:0] clk_cnt   = 0;
  reg [31:0] tick_seen = 0;
  time       last_tick_time, period_tick;
  integer    expected_tick_cnt;


  baud_generator #(.N(N), .N_width(N_width)) dut (
    .clk(clk), .rst_n(rst_n), .s_tick(s_tick)
  );

  always #(CLK_PER/2) clk = ~clk;

  initial begin
    rst_n = 0;
    repeat (3) @(posedge clk);
    rst_n = 1;

    @(posedge clk);
    last_tick_time = $time;

    repeat (TEST_CYC) begin
      @(posedge clk);
      clk_cnt = clk_cnt + 1;

      if (s_tick) begin
        tick_seen = tick_seen + 1;
        if (tick_seen > 1) begin
          period_tick = $time - last_tick_time;
          if (period_tick !== N*CLK_PER) begin
            $display("[FAIL] Period mismatch: %0t ns (expect %0d ns)",
                     period_tick, N*CLK_PER);
            $fatal;
          end
        end
        last_tick_time = $time;
      end
    end

    expected_tick_cnt = (TEST_CYC + N - 1) / N;
    if (tick_seen == expected_tick_cnt) begin
      $display("[PASS] %0d tick_seen sau %0d chu kỳ clock – OK!",
               tick_seen, clk_cnt);
    end else begin
      $display("[FAIL] Tick đếm sai: tick_seen=%0d expected=%0d clk=%0d",
               tick_seen, expected_tick_cnt, clk_cnt);
    end
    $finish;
  end
endmodule
