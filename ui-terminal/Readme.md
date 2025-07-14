# UI Terminal – Hướng dẫn người dùng

Ứng dụng **UI Terminal** là công cụ Windows Forms để giao tiếp UART giữa máy tính và FPGA. Dưới đây là hướng dẫn cài đặt, chạy và cấu hình.

---

## 1. Yêu cầu hệ thống

- **Hệ điều hành**: Windows 10 trở lên  
- **.NET Runtime**: .NET 6.0 (hoặc mới hơn)  
  Tải tại: https://dotnet.microsoft.com/download/dotnet/6.0  

---

## 2. Cài đặt

1. **Tải bản phát hành**  
   - Truy cập trang **Releases** của project:  
     https://github.com/buiminhnhut114/uart-banner-fpga/releases  
   - Tải file ZIP phù hợp, ví dụ `UI_Terminal_v1.0.0.zip`.

2. **Giải nén**  
   - Chuột phải → **Extract All…** (Windows) hoặc dùng công cụ ZIP bất kỳ.  
   - Ví dụ giải vào thư mục `C:\Tools\UI_Terminal\`.

3. **Chuẩn bị môi trường**  
   - Đảm bảo máy đã cài .NET 6.0 runtime.  
   - Kết nối cáp USB-UART giữa máy tính và board DE2.

---

## 3. Khởi chạy ứng dụng

1. Mở thư mục vừa giải nén và **double-click** vào `UI_Terminal.exe`.  
2. Giao diện chính sẽ hiển thị:

   - **COM Port**: chọn cổng COM của USB-UART (nhấn **Refresh** trước nếu không thấy).  
   - **Baud rate**: mặc định 9600 (phải trùng với thiết lập trong FPGA).  
   - **Data bits**: 8  
   - **Stop bits**: 1  
   - **Parity**: None  
   - **Flow control**: None  

   ![Giao diện UI Terminal và cấu hình COM port](images/fig1_2.png)

3. Nhấn **Connect** để mở kênh UART. Khi kết nối thành công, bạn sẽ thấy log thông báo ở ô log bên dưới.

4. Gửi lệnh hoặc dữ liệu bằng ô nhập phía dưới, nhấn **Send**. Dữ liệu nhận về sẽ hiển thị trong khung log.

---

## 4. Các tính năng bổ sung

- **Go / Pause / Move / Insert Digit**: các nút điều khiển gửi lệnh đặc biệt tới FPGA.  
- **Logs**: toàn bộ phiên làm việc được ghi vào file `logs/log_YYYYMMDD_HHMMSS.txt` để tra cứu sau.

---

## 5. Khắc phục sự cố

- **Không thấy COM Port**:  
  - Kiểm tra driver USB-UART đã cài chưa.  
  - Thử nhấn **Refresh** nhiều lần.  

- **Kết nối thất bại**:  
  - Đảm bảo Baud rate và các tham số (data bits, stop bits, parity) trùng khớp với FPGA.  

- **Ứng dụng không khởi động**:  
  - Kiểm tra đã cài .NET 6.0 runtime chưa.  
  - Mở PowerShell và chạy `.\UI_Terminal.exe` để xem thông báo lỗi.

---

## 6. Liên hệ

Mọi thắc mắc hoặc góp ý, vui lòng tạo **Issue** trên GitHub:  
https://github.com/buiminhnhut114/uart-banner-fpga/issues  
