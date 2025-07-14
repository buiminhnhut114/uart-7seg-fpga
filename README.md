# PHỤC LỤC

---

## Phụ lục A. Mã nguồn Verilog

Tất cả các file Verilog của đồ án được lưu tại GitHub:  
https://github.com/buiminhnhut114/uart-banner-fpga

| Mục | Tên file             | Mô tả ngắn                                   | Liên kết                                                     |
| --- | -------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| A.1 | `top_de2.v`          | Top-level kết nối các module                | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/top_de2.v) |
| A.2 | `baud_generator.v`   | Bộ tạo Baud rate và oversampling             | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/baud_generator.v) |
| A.3 | `uart_rx.v`          | Module nhận UART                             | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/uart_rx.v)   |
| A.4 | `uart_tx.v`          | Module truyền UART                           | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/uart_tx.v)   |
| A.5 | `fifo.v`             | FIFO độ sâu 16 byte trên BRAM                | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/fifo.v)      |
| A.6 | `rotating_LED.v`     | FSM điều khiển banner 7-seg                  | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/rotating_LED.v) |
| A.7 | `sevenseg_router.v`  | Giải mã giá trị thành mã 7-seg               | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/sevenseg_router.v) |
| A.8 | `LED_mux.v`          | Bộ đa chọn (multiplexer) hiển thị LED/7-seg   | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/LED_mux.v)   |
| A.9 | `uart.v`             | Module UART chính (tích hợp UART Rx & Tx)    | [Xem trên GitHub](https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/uart.v)      |

---

## Phụ lục B. Kịch bản mô phỏng chi tiết

Tất cả các file testbench và stimulus dùng cho mô phỏng trên ModelSim được lưu tại:  
https://github.com/buiminhnhut114/uart-banner-fpga/tree/main/simulation

- **B.1** Testbench UART  
- **B.2** Testbench rotating_LED  
- **B.3** Testbench baud_generator  
- **B.4** Testbench FIFO  

---

## Phụ lục C. Hướng dẫn sử dụng

Hướng dẫn cài đặt Quartus, nạp code lên DE2 và chạy ứng dụng Windows Forms có tại:  
https://github.com/buiminhnhut114/uart-banner-fpga/blob/main/docs/UserGuide.pdf

- **C.1** Cài đặt Quartus II 13.0 SP1  
- **C.2** Nạp file `.sof` lên Board DE2  
- **C.3** Chạy ứng dụng GUI và cấu hình COM port  
