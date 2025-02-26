#include <Trade/Trade.mqh>

CTrade trade;

// Mảng để lưu trữ thời gian của nến hiện tại
datetime currentBarTimeArray[1];
static datetime previousBarTime = 0;

bool hitOverBoughtZone=false;
bool hitOverSaleZone=false;

int rsiHandle;
double rsiArr[];
double prevRsiValue;
double rsiValue;

double lastPrice;
double entryPrice;
double prevHighPrice;
double prevOpenPrice;
double prevClosePrice;
double prevLowPrice;

double peak=0;
double bottom=0;

string statePositions="Non";
double pip_value;
double tpPrice;
double slPrice;
input double lotSize=0.05;

ulong ticket0;
ulong ticket1;
CPositionInfo position;

int OnInit(){
   rsiHandle = iRSI(Symbol(), PERIOD_CURRENT, 14, PRICE_CLOSE);
   ArraySetAsSeries(rsiArr, true);
   
   pip_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Giá trị của 1 pip
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){}


void OnTick(){
   updatePrice();
   updateRSI();
   
   if(isNewBar() && PositionsTotal() == 0){
      updatePrevPrice();
      
      if(prevRsiValue >= 70 && !hitOverBoughtZone) hitOverBoughtZone = true;
      if(prevRsiValue <= 30 && !hitOverSaleZone) hitOverSaleZone = true;
      
      if(hitOverBoughtZone) findPeak();
      if(hitOverSaleZone) findBottom();
      
      if(hitOverBoughtZone && prevRsiValue <= 60){
         Sell();
         statePositions="Sell";
         hitOverBoughtZone = false;
         addArrowDown(iTime(Symbol(), 0, 1), prevHighPrice);
         peak=0;
      }
      
      if(hitOverSaleZone && prevRsiValue >= 40){
         Buy();
         statePositions="Buy";
         hitOverSaleZone = false;
         addArrowUp(iTime(Symbol(), 0, 1),prevLowPrice);
         bottom=0;
      }
   }
   
   if(PositionsTotal() > 0){
      if(PositionsTotal() == 1 && entryPrice != slPrice) ChangeSL();
      if((PositionSelectByTicket(ticket1)&&statePositions=="Buy"&&rsiValue>=70)||
         (PositionSelectByTicket(ticket1)&&statePositions=="Sell"&&rsiValue<=30))
      {
         Close();
         Print("Close");
      }
   }
   
   Comment(
        "lastPrice: ", lastPrice, "\n",
        "prevRsiValue: " , prevRsiValue , "\n",
        "ticket0: ", ticket0, "\n",
        "ticket1: ", ticket1, "\n"
   );
}


void updateRSI() {
   if (CopyBuffer(rsiHandle, 0, 0, 2, rsiArr) < 2) {
      Print("Lỗi sao chép RSI: ", GetLastError());
      return;
   } else {
      prevRsiValue = rsiArr[1];
      rsiValue = rsiArr[0];
   }
}

void updatePrice(){
   lastPrice = SymbolInfoDouble(Symbol(), SYMBOL_LAST);
}

void updatePrevPrice(){
   prevOpenPrice = iOpen(Symbol(), PERIOD_CURRENT, 1);
   prevHighPrice = iHigh(Symbol(), PERIOD_CURRENT, 1);
   prevLowPrice = iLow(Symbol(), PERIOD_CURRENT, 1);
   prevClosePrice = iClose(Symbol(), PERIOD_CURRENT, 1);
}

void Buy(){
   slPrice = bottom-50*pip_value;
   tpPrice = 2*lastPrice-slPrice;

   if(!trade.Buy(lotSize, Symbol(), 0, slPrice, tpPrice) || !trade.Buy(lotSize, Symbol(), 0, slPrice, 0))
      Print("Lỗi mở lệnh Buy: ", GetLastError());
   else{
      ticket0 = PositionGetTicket(0);
      ticket1 = PositionGetTicket(1);
      Print("Buy");
   }
}

void Sell(){
   slPrice = peak+50*pip_value;
   tpPrice = 2*lastPrice-slPrice;

   if(!trade.Sell(lotSize, Symbol(), 0, slPrice, tpPrice) || !trade.Sell(lotSize, Symbol(), 0, slPrice, 0))
      Print("Lỗi mở lệnh Sell: ", GetLastError());
   else{
      ticket0 = PositionGetTicket(0);
      ticket1 = PositionGetTicket(1);
      Print("Sell");
   }
}

void Close(){
   trade.PositionClose(ticket1);
}

void ChangeSL(){
   if (position.SelectByTicket(PositionGetTicket(0)))
   {
      entryPrice = position.PriceOpen();
      if (trade.PositionModify(PositionGetTicket(0), entryPrice, tpPrice)){
         slPrice = entryPrice;
         Print("Thay đổi Stop Loss thành công.");
      } else
         Print("Lỗi khi thay đổi Stop Loss: ", GetLastError());
   }
   
}

void findPeak(){
   if(prevHighPrice >= peak || peak == 0) peak = prevHighPrice;
   Print("Find Peak:", peak);
}

void findBottom(){
   if(prevLowPrice <= bottom || bottom == 0) bottom = prevLowPrice;
   Print("Find Bottom", bottom);
}

bool isNewBar(){   
   // Sao chép thời gian của nến hiện tại vào mảng
   if (CopyTime(Symbol(), Period(), 0, 1, currentBarTimeArray) > 0){
      datetime currentBarTime = currentBarTimeArray[0];
      
      // Kiểm tra xem thời gian nến hiện tại có khác với thời gian nến trước đó
      if (currentBarTime != previousBarTime){
         // Cập nhật thời gian nến trước đó
         previousBarTime = currentBarTime;
         
         // Thực hiện các hành động cần thiết khi có nến mới
         return true;
         // ...
      }
   }
   else{
      Print("Lỗi khi sao chép thời gian nến: ", GetLastError());
   }
   return false;
}

void addArrowUp(datetime time, double lowPrice) {
   // Tạo tên duy nhất cho đối tượng mũi tên
   string arrowName = "PinBarArrow_" + IntegerToString(time);
   
   // Xóa đối tượng cũ nếu đã tồn tại
   if (ObjectFind(0, arrowName) != -1) {
     ObjectDelete(0, arrowName);
   }
   
   // Tạo đối tượng mũi tên
   if (!ObjectCreate(0, arrowName, OBJ_ARROW_UP, 0, time, lowPrice)) {
     Print("Lỗi khi tạo đối tượng mũi tên: ", GetLastError());
     return;
   }
   
   // Thiết lập thuộc tính cho mũi tên
   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, arrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 233); // Mã mũi tên lên
}

void addArrowDown(datetime time, double highPrice) {
   // Tạo tên duy nhất cho đối tượng mũi tên
   string arrowName = "PinBarArrowDown_" + IntegerToString(time);
   
   // Xóa đối tượng cũ nếu đã tồn tại
   if (ObjectFind(0, arrowName) != -1) {
     ObjectDelete(0, arrowName);
   }
   
   // Tạo đối tượng mũi tên xuống
   if (!ObjectCreate(0, arrowName, OBJ_ARROW_DOWN, 0, time, highPrice)) {
     Print("Lỗi khi tạo đối tượng mũi tên: ", GetLastError());
     return;
   }
   
   // Thiết lập thuộc tính cho mũi tên
   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrRed); // Mũi tên màu đỏ
   ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, arrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 234); // Mã mũi tên xuống
}
