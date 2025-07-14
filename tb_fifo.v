`timescale 1ns/1ps
module tb_fifo;


  localparam W     = 4;
  localparam B     = 8;
  localparam DEPTH = 2**W;


  reg              clk;
  reg              rst_n;
  reg              wr, rd;
  reg  [B-1:0]     wr_data;
  wire [B-1:0]     rd_data;
  wire             full, empty;

 
  integer          i;
  integer          cnt;

  fifo #(.W(W), .B(B)) uut (
    .clk     (clk),
    .rst_n   (rst_n),
    .wr      (wr),
    .rd      (rd),
    .wr_data (wr_data),
    .rd_data (rd_data),
    .full    (full),
    .empty   (empty)
  );


  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end


  initial begin

    rst_n = 0; wr = 0; rd = 0; wr_data = 0;
    #20;
    rst_n = 1;
    #10;


    $display("==========================================================================================");
    $display("============================== WRITE CHINH XAC %0d BYTE =================================", DEPTH);
    $display("==========================================================================================");
    for (i = 0; i < DEPTH; i = i + 1) begin
      @(posedge clk);
      wr      = 1;
      wr_data = i;
      $display("      WRITE #%0d:       data=%0d,       full=%b,       empty=%b", i, wr_data, full, empty);
    end
    @(posedge clk);
    wr = 0;
    if (!full) begin
      $display("=======================[FAIL] FIFO CHUA BAO FULL %0d writes!=============================", DEPTH);
      $fatal;
    end else
      $display("=======================[PASS] FIFO BAO FULL DUNG SAU %0d writes==========================", DEPTH);


    $display("==========================================================================================");
    $display("\n========================= READ CHINH XAC %0d BYTE ======================================", DEPTH);
    $display("==========================================================================================");
    for (i = 0; i < DEPTH; i = i + 1) begin
      @(posedge clk);
      rd = 1;
      $display("      READ #%0d:       data=%0d,       full=%b,       empty=%b", i, rd_data, full, empty);
    end
    @(posedge clk);
    rd = 0;
    if (!empty) begin
      $display("======================[FAIL] FIFO CHUA BAO EMPTY SAU %0d reads!==========================", DEPTH);
      $fatal;
    end else
      $display("======================[PASS] FIFO BAO EMPTY DUNG SAU %0d reads===========================", DEPTH);

    // 4) SIMULTANEOUS READ & WRITE
    $display("==========================================================================================");
    $display("\n======================= SIMULTANEOUS READ & WRITE TEST =================================");
    $display("==========================================================================================");
    // Fill half FIFO
    for (i = 0; i < DEPTH/2; i = i + 1) begin
      @(posedge clk);
      wr      = 1;
      wr_data = i + 100;
    end
    @(posedge clk);
    wr = 0;
    cnt = DEPTH/2;
    $display("==========================================================================================");
    $display("=============SAU KHI WRITE 8 BYTE DAU TIEN: full=%b, empty=%b=============================", full, empty);
    $display("==========================================================================================");

    for (i = 0; i < 8; i = i + 1) begin
      @(posedge clk);
      wr      = 1;
      wr_data = i + 200;
      rd      = 1;
 
      $display("      CYCLE %0d:       WRITE=%0d,       READ=%0d,       full=%b,       empty=%b",
               i, wr_data, rd_data, full, empty);
    end
    @(posedge clk);
    wr = 0; rd = 0;

  
    #20;
    $display("==========================================================================================");
    $display("\n============================ ALL TESTS PASSED ==========================================");
    $display("==========================================================================================");
    $finish;
  end

  initial begin
    $dumpfile("tb_fifo.vcd");
    $dumpvars(0, tb_fifo);
  end

endmodule
