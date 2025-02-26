# FRSI_Gold
# Bot Giao Dịch Vàng H4

**Bot Giao Dịch Vàng H4** là một bot giao dịch tự động được thiết kế để giao dịch vàng (XAU/USD) trên khung thời gian 4 giờ, sử dụng chỉ báo RSI (Relative Strength Index) làm cơ sở xác định điểm vào lệnh. Bot hoạt động theo chiến lược đơn giản nhưng hiệu quả:  
- **Mua**: Khi giá thoát khỏi vùng quá bán (RSI dưới 30 và tăng qua 40).  
- **Bán**: Khi giá rời vùng quá mua (RSI trên 70 và giảm qua 60).  

## Tính năng chính
- **Quản lý lệnh**: Bot mở hai lệnh giao dịch đồng thời với kích thước lô tùy chỉnh (mặc định 0.05 lot), kèm theo mức chốt lời (Take Profit) và dừng lỗ (Stop Loss) được tính toán dựa trên giá cực đại (peak) hoặc cực tiểu (bottom) gần nhất, Take Profit 1 và Stop Loss theo tỷ lệ 1:1, Take Profit 2 khi RSI chạm vùng quá mua hoặc quá bán.
- **Điều chỉnh Stop Loss**: Tự động di chuyển Stop Loss về điểm vào lệnh khi giá chạm Take Profit 1, giúp bảo toàn vốn.  
- **Trực quan hóa tín hiệu**: Các điểm vào lệnh được đánh dấu bằng mũi tên trên biểu đồ (mũi tên xanh cho lệnh mua, đỏ cho lệnh bán), hỗ trợ theo dõi dễ dàng.

## Mục đích sử dụng
Bot này là công cụ lý tưởng cho những ai muốn tự động hóa giao dịch vàng theo xu hướng RSI trên khung thời gian H4, phù hợp với cả người mới bắt đầu và nhà giao dịch có kinh nghiệm.

## Yêu cầu
- Nền tảng: MetaTrader 4 hoặc 5.  
- Cặp tiền: XAU/USD (vàng).  
- Khung thời gian: H4 (4 giờ).  

## Hướng dẫn cài đặt
1. Sao chép mã nguồn vào thư mục `Experts` của MetaTrader.  
2. Biên dịch tệp trong MetaEditor.  
3. Gắn bot vào biểu đồ XAU/USD khung H4 và điều chỉnh thông số (nếu cần).  

## Lưu ý
- Kiểm tra kỹ trên tài khoản demo trước khi sử dụng trên tài khoản thực.  
- Tùy chỉnh kích thước lô (`lotSize`) theo khả năng quản lý vốn của bạn.  

---
Bot được phát triển bởi [Tên của bạn] - Ngày cập nhật: 26/02/2025.
