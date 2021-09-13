#include "IdentityV7.mq4"
double Risk = 0.02;
double AccountSize = 10000;
double Commission = 0;

void PlaceLimit(double price,double stoploss,double takeprofit)
{
   double Lots = LotSize(price,stoploss);
   
   if(stoploss < price)
     {
      OrderSend(_Symbol,OP_BUYLIMIT,Lots,price,10,stoploss,takeprofit,NULL,0,0,clrOrange);
     }
   if(stoploss > price)
     {
      OrderSend(_Symbol,OP_SELLLIMIT,Lots,price,10,stoploss,takeprofit,NULL,0,0,clrOrange);
     } 
     
     ObjectCreate(_Symbol,"tpmid",OBJ_HLINE,0,0,(price+takeprofit)/2);
     ObjectCreate(_Symbol,"slmid",OBJ_HLINE,0,0,(price+stoploss)/2); 
     
     BreakPoint();
}



double LotSize(double Price,double StopLoss)
{
   double TickValue = MarketInfo(_Symbol,MODE_TICKVALUE);
   int Spread = MarketInfo(_Symbol,MODE_SPREAD);
   
   double Dist = MathMax(Price,StopLoss)-MathMin(Price,StopLoss);
   double Money = Risk*AccountSize;
   int Points = Dist/_Point+Spread;
   double Calc = Points*TickValue+Commission;
   double Lots = Money/Calc;
   Print("lot size: "+string(Lots));
   
   return NormalizeDouble(Lots,2);
}

void CheckOrders()
{
   if(OrdersTotal()==0)
     {
      return;
     }
   OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
   Comment("Order Type: "+string(OrderType()));
   
   double high = ObjectGetDouble(_Symbol,"levelrange",OBJPROP_PRICE1,0);
   double low = ObjectGetDouble(_Symbol,"levelrange",OBJPROP_PRICE2,0);
   
   if(OrderType()==OP_BUYLIMIT && Candle(1)=="bull")
     {
      OrderDelete(OrderTicket(),clrNONE);
     }
   if(OrderType()==OP_SELLLIMIT && Candle(1)=="bear")
     {
      OrderDelete(OrderTicket(),clrNONE);
     } 
     
   if(OrderType()==OP_BUYLIMIT && High[1] > LevelPrice(0))
     {
      OrderDelete(OrderTicket(),clrNONE);
      DrawFibo(High[1],LevelPrice(100),5);
     }
   if(OrderType()==OP_SELLLIMIT && Low[1] < LevelPrice(0))
     {
      OrderDelete(OrderTicket(),clrNONE);
      DrawFibo(Low[1],LevelPrice(100),5);
     } 
   
   double MidSL = (OrderOpenPrice()+OrderStopLoss())/2;
   double MidTP = (OrderOpenPrice()+OrderTakeProfit())/2;
   
   if(OrderType()==OP_BUYLIMIT && Low[1]<high && Close[1]>MidTP)
     {
      OrderDelete(OrderTicket(),clrNONE);
     }
   if(OrderType()==OP_SELLLIMIT && High[1]>low && Close[1]<MidTP)
     {
      OrderDelete(OrderTicket(),clrNONE);
     }   
     
   if(OrderType()==OP_BUY && Close[1] < MidSL)
     {
      OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice(),0,clrNONE);
     }      
   if(OrderType()==OP_SELL && Close[1] > MidSL)
     {
      OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderOpenPrice(),0,clrNONE);
     }  
     
   if(OrderType()==OP_BUY && Bid > MidTP)
     {
      OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
     }      
   if(OrderType()==OP_SELL && Ask < MidTP)
     {
      OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
     }                
}