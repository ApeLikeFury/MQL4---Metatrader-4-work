#include <WinUser32.mqh>
#include "TradingFeatures.mq4"

void BreakPoint()
{
   if (!IsVisualMode()) return;
   
   keybd_event(19,0,0,0);
   Sleep(10);
   keybd_event(19,0,2,0);
   
   for(int i=0;i<10000000;i++){}
}

bool TradingSession()
{
   int GMT = TimeHour(TimeGMT());
   
   //London
   if(GMT > 8 && GMT < 16)
     {
      return true;
     }
   //NewYork  
   if(GMT > 12 && GMT < 20)
     {
      return true;
     }
   //Tokyo    
   if(GMT > 23 || GMT < 8)
     {
      return true;
     }  
     return false;  
}

int OnInit()
  {
   ChartSetInteger(_Symbol,CHART_MODE,CHART_CANDLES);
   ChartSetInteger(_Symbol,CHART_COLOR_BACKGROUND,clrBlack);
   ChartSetInteger(_Symbol,CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(_Symbol,CHART_COLOR_CANDLE_BULL,clrGreen);
   ChartSetInteger(_Symbol,CHART_COLOR_CHART_DOWN,clrWhite);
   ChartSetInteger(_Symbol,CHART_COLOR_CHART_UP,clrWhite);
   ChartSetInteger(_Symbol,CHART_COLOR_GRID,clrNONE);
   ChartSetInteger(_Symbol,CHART_SCALE,5);
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   CheckOrders();
   
   if(NewBar()==true && TradingSession()==true)
     {
      OnClose();
     }
  }
  
void OnClose()
{  
   if(Close[1] < Open[1] && OrdersTotal()==0)
     {
      BullImpulse();
      if(OrdersTotal()>0)
        {
         return;
        }
      LargeBullImpulse();
     }
   if(Close[1] > Open[1] && OrdersTotal()==0)
     {
      BearImpulse();
      if(OrdersTotal()>0)
        {
         return;
        }
      LargeBearImpulse();
     }  
}  

bool NewBar()
   {
      static int LastNumberOfBars;
      
      if (Bars>LastNumberOfBars)
      {
         LastNumberOfBars = Bars;
         return true;
      }
      else
      return false;
   }
   
bool Gap(int Candle)
{
   double Threshold = Volatility(Candle)*0.3;
   
   if(Open[Candle] > Close[Candle+1] + Threshold)
     {
      return true;
      ObjectDelete("gap");
      ObjectCreate(_Symbol,"gap",OBJ_RECTANGLE,0,Time[Candle],Open[Candle],Time[Candle+1],Close[Candle+1]);
      ObjectSet("gap",OBJPROP_COLOR,clrOrange);
     }
   if(Open[Candle] < Close[Candle+1] - Threshold)
     {
      ObjectDelete("gap");
      ObjectCreate(_Symbol,"gap",OBJ_RECTANGLE,0,Time[Candle],Open[Candle],Time[Candle+1],Close[Candle+1]);
      ObjectSet("gap",OBJPROP_COLOR,clrOrange);      
      return true;
     }  
     return false;
}    
   
double Volatility(int Shift)
{
  double rangesum = 0;
  int period = 30;
  
  for(int i=1;i<=period;i++)
    {
     double highest = High[iHighest(_Symbol,0,MODE_HIGH,i,1)];
     double lowest = Low[iLowest(_Symbol,0,MODE_LOW,i,1)];
     rangesum += highest-lowest;
    }
    return (rangesum/period)*0.3;
}

string Candle(int C)
{
   double vol = Volatility(C)*0.01;
   
   if(BodyHigh(C)-BodyLow(C)<vol)
     {
      return "doji";
     }
   if(Close[C]>Open[C])
     {
      return "bull";
     }
   if(Close[C]<Open[C])
     {
      return "bear";
     } 
}

double LevelPrice(double Level)
{
   string Name = DoubleToStr(Fibos,9);
   double L100 = ObjectGetDouble(_Symbol,Name,OBJPROP_PRICE1);
   double L0 = ObjectGetDouble(_Symbol,Name,OBJPROP_PRICE2);
   
   if(L0 > L100)
     {
      double Dist = L0-L100;
      double Unit = Dist/100;
      double Addon = Unit*Level;
      return NormalizeDouble(L0-Addon,_Digits);
     }
     else
       {
        Dist = L100-L0;
        Unit = Dist/100;
        Addon = Unit*Level;
        return NormalizeDouble(L0+Addon,_Digits);
       }
}

double BodyHigh(int C)
{
   return MathMax(Open[C],Close[C]);
}

double BodyLow(int C)
{
   return MathMin(Open[C],Close[C]);
}

bool EMABetweenLevels(double level1, double level2)
{
  double EMA = iMA(_Symbol,_Period,50,0,MODE_EMA,PRICE_CLOSE,0);
  double high = MathMax(LevelPrice(level1),LevelPrice(level2));
  double low = MathMin(LevelPrice(level1),LevelPrice(level2));
  
  if(EMA >= low && EMA <= high)
    {
     return true;
    }
    return false;
}

void BullImpulse()
{
   double HighBod = BodyHigh(1);
   double LowBod = BodyHigh(1);
   double HighWick = High[1];
   double LowWick = High[1];
   int Dojis = 0;
   
   if(Gap(1)==true)
        {
         return;
        }
   
   for(int i=2;i<20;i++)
     {
      if(Gap(i)==true)
        {
         return;
        }
      if(BodyLow(i)<LowBod)
        {
         LowBod = BodyLow(i);
        }
      if(Low[i]<LowWick)
        {
         LowWick = Low[i];
        }  
        
      if(Candle(i)=="bear" || Dojis > 2)
        {
         break;
        }
      if(Candle(i)=="doji")
        {
         Dojis++;
        }  

      if(BodyHigh(i)>HighBod)
        {
         HighBod = BodyHigh(i);
        } 
      if(High[i]>HighWick)
        {
         HighWick = High[i];
        }     
     }
     double Threshold = Volatility(i);
     
     if(HighBod-BodyHigh(i) > Threshold)
       {
        DrawFibo(HighWick,LowWick,i);
       }
}  

void BearImpulse()
{
   double HighBod = BodyLow(1);
   double LowBod = BodyLow(1);
   double HighWick = Low[1];
   double LowWick = Low[1];
   int Dojis = 0;
   
   if(Gap(1)==true)
        {
         return;
        }
   
   for(int i=2;i<20;i++)
     {
      if(Gap(i)==true)
        {
         return;
        }
      if(BodyHigh(i)>HighBod)
        {
         HighBod = BodyHigh(i);
        } 
      if(High[i]>HighWick)
        {
         HighWick = High[i];
        } 
        
      if(Candle(i)=="bull" || Dojis > 2)
        {
         break;
        }
      if(Candle(i)=="doji")
        {
         Dojis++;
        }  
        
      if(BodyLow(i)<LowBod)
        {
         LowBod = BodyLow(i);
        }
      if(Low[i]<LowWick)
        {
         LowWick = Low[i];
        }          
     }
     double Threshold = Volatility(i);
     
     if(BodyLow(i)-LowBod > Threshold)
       {
        DrawFibo(LowWick,HighWick,i);
       }
}

void LargeBullImpulse()
{
   double HighBod = BodyHigh(1);
   double LowBod = BodyHigh(1);
   double HighWick = High[1];
   double LowWick = High[1];
   double BullSum = 0;
   double BearSum = 0;
   int Dojis = 0;
   int Bears = 0;
   
   if(Gap(1)==true)
        {
         return;
        }
   
   for(int i=2;i<20;i++)
     {
      if(Gap(i)==true)
        {
         return;
        }
      if(BodyLow(i)<LowBod)
        {
         LowBod = BodyLow(i);
        }
      if(Low[i]<LowWick)
        {
         LowWick = Low[i];
        }  
      
      if(Candle(i)=="bull")
        {
         BullSum += BodyHigh(i)-BodyLow(i);
        }  
      if(Candle(i)=="bear")
        {
         Bears++;
         BearSum += BodyHigh(i)-BodyLow(i);
         
         if(Bears > 1)
           {
            break;
           }
        }
      if(Dojis > 2)
        {
         break;
        }  
      if(Candle(i)=="doji")
        {
         Dojis++;
        }  

      if(BodyHigh(i)>HighBod)
        {
         HighBod = BodyHigh(i);
        } 
      if(High[i]>HighWick)
        {
         HighWick = High[i];
        }     
     }
     double Threshold = Volatility(i)*0.7;
     
     if(HighBod-BodyHigh(i) > Threshold && BearSum < BullSum*0.2)
       {
        DrawFibo(HighWick,LowWick,i);
       }
}

void LargeBearImpulse()
{
   double HighBod = BodyLow(1);
   double LowBod = BodyLow(1);
   double HighWick = Low[1];
   double LowWick = Low[1];
   double BullSum = 0;
   double BearSum = 0;
   int Dojis = 0;
   int Bulls = 0;
   
   if(Gap(1)==true)
        {
         return;
        }
   
   for(int i=2;i<20;i++)
     {
      if(Gap(i)==true)
        {
         return;
        }
      if(BodyHigh(i)>HighBod)
        {
         HighBod = BodyHigh(i);
        } 
      if(High[i]>HighWick)
        {
         HighWick = High[i];
        } 
        
      if(Candle(i)=="bear")
        {
         BearSum += BodyHigh(i)-BodyLow(i);
        }  
      if(Candle(i)=="bull")
        {
         Bulls++;
         BullSum += BodyHigh(i)-BodyLow(i);
         
         if(Bulls > 1)
           {
            break;
           }
        }
      if(Dojis > 2)
        {
         break;
        }  
      if(Candle(i)=="doji")
        {
         Dojis++;
        }  
        
      if(BodyLow(i)<LowBod)
        {
         LowBod = BodyLow(i);
        }
      if(Low[i]<LowWick)
        {
         LowWick = Low[i];
        }          
     }
     double Threshold = Volatility(i)*0.7;
     
     if(BodyLow(i)-LowBod > Threshold && BullSum < BearSum*0.2)
       {
        DrawFibo(LowWick,HighWick,i);
       }
}  

int Fibos = 0;

void DrawFibo(double L0,double L100,int candle)
{
   string Name = DoubleToStr(Fibos,9);
   string Name2 = DoubleToStr(Fibos,10);
   ObjectDelete(_Symbol,Name);
   ObjectCreate(Name,OBJ_FIBO,0,Time[candle],L100,Time[candle],L0);
   ObjectDelete(_Symbol,Name2);
   ObjectCreate(Name2,OBJ_HLINE,0,Time[candle],LevelPrice(92.5));
   ObjectDelete(_Symbol,"tpmid");
   ObjectDelete(_Symbol,"slmid");
   
   if(EMABetweenLevels(61.8,92.5)==true)
     {
      CheckZone(61.8,candle);
     }
   if(EMABetweenLevels(38.2,61.8)==true)
     {
      CheckZone(38.2,candle);
     }  
}

void CheckZone(double level,int shift)
{
   double vol = Volatility(1)*0.15;
   double high = LevelPrice(level)+vol;
   double low = LevelPrice(level)-vol;
   double uhigh = MathMax(LevelPrice(level+5),LevelPrice(level-5));
   double ulow = MathMin(LevelPrice(level+5),LevelPrice(level-5));
   
   ObjectDelete(_Symbol,"range");
   ObjectCreate(_Symbol,"range",OBJ_RECTANGLE,0,Time[1],high,Time[40],low);
   
   ObjectDelete(_Symbol,"levelrange");
   ObjectCreate(_Symbol,"levelrange",OBJ_RECTANGLE,0,Time[1],uhigh,Time[40],ulow);
   ObjectSet("levelrange",OBJPROP_COLOR,clrTeal);
   
  
   int strength = 0;
   int mem;
   
   for(int i=shift;i<shift+40;i++)
     {
      if(Gap(i)==true || strength > 1)
        {
         break;
        }
      if(LevelPrice(0)>LevelPrice(100))
        {
         if(BodyHigh(i)>high || BodyHigh(i)>uhigh)
           {
            ObjectDelete(_Symbol,"break");
            ObjectCreate(_Symbol,"break",OBJ_ARROW_STOP,0,Time[i],BodyHigh(i));
            break;
           }
         if(High[i]>low && High[i]>ulow && IsHigh(i,high)==true)
           {
            strength++;
            mem = i;
           } 
        }
      if(LevelPrice(100)>LevelPrice(0))
        {
         if(BodyLow(i)<low || BodyLow(i)<ulow)
           {
            ObjectDelete(_Symbol,"break");
            ObjectCreate(_Symbol,"break",OBJ_ARROW_STOP,0,Time[i],BodyLow(i));
            break;
           }
         if(Low[i]<high && Low[i]<uhigh && IsLow(i,low)==true)
           {
            strength++;
            mem = i;
           } 
        }  
     }
     
     if(strength > 1 && Invalid(level,shift)==false)
       {
        ObjectDelete(_Symbol,"zone");
        ObjectDelete(_Symbol,"range");
        ObjectCreate(_Symbol,"zone",OBJ_RECTANGLE,0,Time[0],high,Time[mem],low);
        ObjectSet("zone",OBJPROP_COLOR,clrWhite);
        Conditions(MathMax(uhigh,high),MathMin(ulow,low));
       }
   
}

bool IsHigh(int candle,double zonehigh)
{
   double MA = iMA(_Symbol,_Period,3,3,MODE_LWMA,PRICE_CLOSE,3);
   
   if(BodyHigh(candle) < MA)
     {
      return false;
     }
   
   double Threshold = BodyHigh(candle)-Volatility(1)*0.3;
   
   for(int i=candle+1;i<candle+10;i++)
     {
      if(BodyHigh(i)>zonehigh)
        {
         return false;
        }
      if(BodyHigh(i)<Threshold)
        {
         return true;
        }
     }
     return false;
}

bool IsLow(int candle,double zonelow)
{
   double MA = iMA(_Symbol,_Period,3,3,MODE_LWMA,PRICE_CLOSE,3);
   
   if(BodyLow(candle) > MA)
     {
      return false;
     }
   
   double Threshold = BodyLow(candle)+Volatility(1)*0.3;
   
   for(int i=candle+1;i<candle+10;i++)
     {
      if(BodyLow(i)<zonelow)
        {
         return false;
        }
      if(BodyLow(i)>Threshold)
        {
         return true;
        }
     }
     return false;
}

bool Invalid(double level,int shift)
{
   double price = LevelPrice(level);
   
   for(int i=shift-1;i>1;i--)
     {
      if(LevelPrice(0)>LevelPrice(100))
        {
         if(Candle(i)=="bear" && BodyHigh(i)>price)
           {
            ObjectSet("impulse",OBJPROP_COLOR,clrPink);
            return true;
           }
        }
      if(LevelPrice(0)<LevelPrice(100))
        {
         if(Candle(i)=="bull" && BodyLow(i)<price)
           {
            ObjectSet("impulse",OBJPROP_COLOR,clrPink);
            return true;
           }
        }  
     }
     return false;
}

int buffer = 0;

void Conditions(double ZoneHigh,double ZoneLow)
{
   bool Pullback = false;
   
   if(LevelPrice(0)>LevelPrice(100))
     {
      if(Low[1]<=ZoneHigh)
        {
         return;
        }
      if(EMABetweenLevels(61.8,92.5)==true && Close[1] > LevelPrice(38.2))
        {
         PlaceLimit(LevelPrice(61.8-buffer),LevelPrice(92.5),LevelPrice(0));
        }
      if(EMABetweenLevels(38.2,61.8)==true && Close[1] > LevelPrice(27))
        {
         PlaceLimit(LevelPrice(38.2-buffer),LevelPrice(61.8),LevelPrice(0));
        }  
     }
   if(LevelPrice(100)>LevelPrice(0))
     {
      if(High[1]>=ZoneLow)
        {
         return;
        }
      if(EMABetweenLevels(61.8,92.5)==true && Close[1] < LevelPrice(38.2))
        {
         PlaceLimit(LevelPrice(61.8-buffer),LevelPrice(92.5),LevelPrice(0));
        }
      if(EMABetweenLevels(38.2,61.8)==true && Close[1] < LevelPrice(27))
        {
         PlaceLimit(LevelPrice(38.2-buffer),LevelPrice(61.8),LevelPrice(0));
        }  
     }  
}