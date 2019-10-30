//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

input string isymbols = "EURUSD,AUDCHF,SCHEIS"; //Symbols
input int imas = 40; // Period for short EMA
input int imal = 100; // Period for long EMA
input ENUM_TIMEFRAMES itimeframe = PERIOD_M1; // Timeframe


//+------------------------------------------------------------------+
//| types                                                            |
//+------------------------------------------------------------------+
enum direction {
  none,
  rising,
  falling
};

struct  symbols_struct {
  string symbol;
  direction previous_direction;
  direction current_direction;
};

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

symbols_struct symbols[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
  EventSetTimer(10);

  string s[];
  StringSplit(isymbols, StringGetCharacter(",", 0), s);
  ArrayResize(symbols,ArraySize(s));

  for(int i = 0; i < ArraySize(s); i++) {
    symbols[i].symbol = s[i];
    symbols[i].previous_direction = none;
    symbols[i].current_direction = none;
  }

  string err = checkparams();

  if (err != "") {
    Print(err);
    return(INIT_PARAMETERS_INCORRECT);
  }
  
  return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProcessSymbol(symbols_struct &symbol) {
//MarketInfo(symbol,
// string valid = IsSymbolInMarketWatch(symbols[i]) == true ? "yes" : "no";
  bool valid = IsSymbolInMarketWatch(symbol.symbol);
  if(valid == false) {
    PrintFormat("Symbol: %s not found in Market watch !", symbol.symbol);
    return;
  }
  double shortSma = iMA(NULL, itimeframe, imas, 0, MODE_EMA, PRICE_CLOSE, 0);
  double longSma  = iMA(NULL, itimeframe, imal, 0, MODE_EMA, PRICE_CLOSE, 0);
// IsTradeAllowed()
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// int CheckForCross(double shortSma, double longSma) {
//   static int previous_direction = 0;
//   static int current_dirction = 0;
// // Up Direction = 1
//   if(shortSma > longSma) {
//     current_direction = 1;
//   }
// // Down Direction = 2
//   if(shortSma <= longSma) {
//     current_direction = 2;
//   }
// // Detect a direction change
//   if(current_direction != previous_direction) {
//     previous_direction = current_dirction;
//     return (previous_direction);
//   } else {
//     return (0);
//   }
// }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string checkparams() {
  if(imal < imal)
    return "Please check settings, Period for long EMA is lesser then the short EMA";
  // StringSplit(isymbols, StringGetCharacter(",", 0), symbols);
  string err = "";
  for(int i = 0; i < ArraySize(symbols); i++) {
    bool valid = IsSymbolInMarketWatch(symbols[i].symbol);
    if(valid == false) {
      err = err + "\nSymbol: " + symbols[i].symbol + " not found in Market watch !";
      continue;
    }
    int bars = iBars(symbols[i].symbol, itimeframe);
    if(bars < imal) {
      err = err + "\nSymbol: " + symbols[i].symbol +
            ". Please check settings, less then the second period bars available for the long SMA";
    }

  }
  return err;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSymbolInMarketWatch(string f_Symbol) {
  for(int s = 0; s < SymbolsTotal(false); s++) {
    if(f_Symbol == SymbolName(s, false))
      return(true);
  }
  return(false);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
  for(int i = 0; i < ArraySize(symbols); i++) {
    ProcessSymbol(symbols[i]);
  }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//--- destroy timer
  EventKillTimer();
}
//+------------------------------------------------------------------+
