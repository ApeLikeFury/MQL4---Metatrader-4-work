
#property show_inputs

extern ENUM_TIMEFRAMES timeframe = 5;
extern ENUM_TIMEFRAMES timeframe2 = 15;
extern string Template = "IdentityV3.tpl";

void OnStart()
  {
   OpenCharts();
   
   long chart = ChartFirst();
   long first = chart;
   
   while(chart > 0)
     {
      chart = ChartNext(chart);
      ChartSetSymbolPeriod(chart,ChartSymbol(chart),timeframe);
      ChangeStyle(chart);
     }
     ChartClose(first);
  }
  
void OpenCharts()
{ 
   ChartOpen("USDCHF",timeframe);
   ChartOpen("GBPUSD",timeframe);
   ChartOpen("EURUSD",timeframe);
   ChartOpen("USDJPY",timeframe);
   ChartOpen("USDCAD",timeframe);
   ChartOpen("AUDUSD",timeframe);
   ChartOpen("EURGBP",timeframe);
   ChartOpen("EURAUD",timeframe);
   ChartOpen("EURCHF",timeframe);
   ChartOpen("EURJPY",timeframe);
   ChartOpen("GBPCHF",timeframe);
   ChartOpen("CADJPY",timeframe);
   ChartOpen("AUDNZD",timeframe);
   ChartOpen("AUDCAD",timeframe);
   ChartOpen("AUDCHF",timeframe);
   ChartOpen("AUDJPY",timeframe);
   ChartOpen("CHFJPY",timeframe);
   ChartOpen("EURNZD",timeframe);
   ChartOpen("EURCAD",timeframe);
   ChartOpen("CADCHF",timeframe);
   ChartOpen("NZDJPY",timeframe);
   ChartOpen("NZDUSD",timeframe);
   ChartOpen("GBPAUD",timeframe);
   ChartOpen("GBPCAD",timeframe);
   ChartOpen("GBPNZD",timeframe);
   ChartOpen("NZDCAD",timeframe);
   ChartOpen("NZDCHF",timeframe);
   ChartOpen("USDSGD",timeframe);
   ChartOpen("GBPJPY",timeframe);
}  
  
void ChangeStyle(long chart)
{
      ChartApplyTemplate(chart,Template);
}  