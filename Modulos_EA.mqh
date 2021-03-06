//+------------------------------------------------------------------+
//|                                                   Modulos_EA.mqh |
//|                                          Copyright 2022, Hadliv. |
//|                                              https://handliv.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Hadliv."
#property link      "https://handliv.com"
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

//-------------------------------------------------------------------+
// Atenção: EA para fins APENAS didáticos!
// Isso aqui não confere orientação e/ou sugestão de investimentos!
// O autor não se responsabiliza pelo uso indevido deste material 
//-------------------------------------------------------------------+

CTrade trade;

bool pode_operar = true;
//---BREAKEVEN E TS
bool beAtivo = false;
bool parAtivo = false;

//+------------------------------------------------------------------+
//|COMPRA E VENDA A MERCADO                                          |
//+------------------------------------------------------------------+

void CompraAMercado(double num_lotes, string ativo, double ask, double TK_, double SL_)
   {
   
      
      
      trade.Buy(num_lotes,ativo,NormalizeDouble(ask,_Digits),NormalizeDouble(ask - SL_*_Point,_Digits),
                NormalizeDouble(ask + TK_*_Point,_Digits));
      
      if(trade.ResultRetcode() == 10008 || trade.ResultRetcode() == 10009)
        {
            Print("Ordem de compra Executada com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }          
     
   }

void VendaAMercado(double num_lotes, string ativo, double bid, double TK_, double SL_)
   {
      
      
      trade.Sell(num_lotes,ativo,NormalizeDouble(bid,_Digits),NormalizeDouble(bid + SL_*_Point,_Digits),
                  NormalizeDouble(bid - TK_*_Point,_Digits));
      
      if(trade.ResultRetcode() == 10008 || trade.ResultRetcode() == 10009)
        {
            Print("Ordem de venda Executada com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }              
   
   }
   
//+------------------------------------------------------------------+
//|COMPRA LIMITE E VENDA LIMITE                                      |
//+------------------------------------------------------------------+
void CompraLimite(double num_lotes, double nivel_compra, double tp = 0.0, double sl = 0.0)
   {
      
      
      trade.BuyLimit(num_lotes,nivel_compra,_Symbol, NormalizeDouble(nivel_compra - sl*_Point,_Digits), 
                     NormalizeDouble(nivel_compra + tp*_Point,_Digits) );
   
   
   }
//---
void VendaLimite(double num_lotes, double nivel_venda, double tp = 0.0, double sl = 0.0)
   {
      
      
      trade.SellLimit(num_lotes,nivel_venda,_Symbol, NormalizeDouble(nivel_venda + sl*_Point,_Digits),
                     NormalizeDouble( nivel_venda - tp*_Point,_Digits) ); 
   
   
   }

//+------------------------------------------------------------------+
//|FECHAR POSIÇÃO EM ABERTA                                          |
//+------------------------------------------------------------------+
void FecharPosicao()
   {
   
      ulong ticket = PositionGetTicket(0);
      
      trade.PositionClose(ticket);
      
      if(trade.ResultRetcode() == 10009)
        {
            Print("Fechamento Executado com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }  
   
   }
   
//+------------------------------------------------------------------+
//|CANCELAMENTO DE ORDEM                                             |
//+------------------------------------------------------------------+
void cancelarOrdem()
   {
   
      
      trade.OrderDelete(OrderGetTicket(0));
      
      if(trade.ResultRetcode() == 10009)
        {
            Print("Ordem cancelada com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           } 
   }


//+------------------------------------------------------------------+
//| FUNÇÕES PARA AUXILIAR NA VISUALIZAÇÃO DA ESTRATÉGIA              |
//+------------------------------------------------------------------+

void desenhaLinhaVertical(string nome, datetime dt, color cor = clrAliceBlue)
   {
      ObjectDelete(0,nome);
      ObjectCreate(0,nome,OBJ_VLINE,0,dt,0);
      ObjectSetInteger(0,nome,OBJPROP_COLOR,cor);
   } 
   
void desenhaLinhaHorizontal(string nome, double price, color cor = clrAliceBlue)
   {
      ObjectDelete(0,nome);
      ObjectCreate(0,nome,OBJ_HLINE,0,0,price);
      ObjectSetInteger(0,nome,OBJPROP_COLOR,cor);
   } 
//---

//+------------------------------------------------------------------+
//|TOTAL DE LUCRO ACUMULADO                                          |
//+------------------------------------------------------------------+
double LucroAcumulado()
   {
      
      double lucro_acum = 0;
      double lucro = 0;
      
      HistorySelect(0,TimeCurrent());
      
      int tn = HistoryDealsTotal();
      
      //Print("Total de negócios = ", tn); 
      
      //Print("Negócio 2 Lucro = ", );
      
      for(int i=1;i<=tn;i++)
        {
            ulong tick_n = HistoryDealGetTicket(i);
            
            lucro = HistoryDealGetDouble(tick_n,DEAL_PROFIT);
            //Print("Negócio (",i, ") , Lucro = ",lucro );
            
            lucro_acum = lucro_acum + lucro; // lucro_acum += lucro
            
        }
   
      return lucro_acum;
   }

//+------------------------------------------------------------------+
//|VERIFICAR NOVA VELA PARA ENTRADA                                  |
//+------------------------------------------------------------------+
bool TemosNovaVela()
  {
//--- memoriza o tempo de abertura da ultima barra (vela) numa variável
   static datetime last_time=0;
//--- tempo atual
   datetime lastbar_time= (datetime) SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- se for a primeira chamada da função:
   if(last_time==0)
     {
      //--- atribuir valor temporal e sair
      last_time=lastbar_time;
      return(false);
     }

//--- se o tempo estiver diferente:
   if(last_time!=lastbar_time)
     {
      //--- memorizar esse tempo e retornar true
      last_time=lastbar_time;
      return(true);
     }
//--- se passarmos desta linha, então a barra não é nova; retornar false
   return(false);
  }
//---   
//+------------------------------------------------------------------+
//|  NORMALIZAR MANUAL                                               |
//+------------------------------------------------------------------+
double Normalizarmanual() {
  double normalizadormanual = 0;
  
  if(_Digits == 5) {
    normalizadormanual = _Point;
    return(normalizadormanual);
  }
  if(_Digits == 4) {
    normalizadormanual = 10000;
    return(normalizadormanual);
  }
  if(_Digits == 3) {
    normalizadormanual = _Point * 10000;
    return(normalizadormanual);
  }
  if(_Digits == 2) {
    normalizadormanual = _Point * 10;
    return(normalizadormanual);
  }
  if(_Digits == 1) {
    normalizadormanual = 10;
    return(normalizadormanual);
  }
  if(_Digits == 0) {
    normalizadormanual = 1;
    return(normalizadormanual);
  }
  return(-1);
}

//+------------------------------------------------------------------+
//| CONTROLE DE VENCIMENTO                                           |
//+------------------------------------------------------------------+
void vencimento() {
  datetime vencimento = D'2022.05.22 23:00';
  long numeroconta = AccountInfoInteger(ACCOUNT_LOGIN);
  ENUM_ACCOUNT_TRADE_MODE contarealoudemo = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
  switch(contarealoudemo) {
  case(ACCOUNT_TRADE_MODE_DEMO):
  //   Print("\n" +"ROBÔ PERMITIDO OPERAR");
  break;
  case(ACCOUNT_TRADE_MODE_CONTEST):
  //    Print("\n" +"ROBÔ PERMITIDO OPERAR SOMENTE EM CONTA DEMO");
  ExpertRemove();
  break;
  default:
  Print("\n" + "DUVIDAS ENTRE EM CONTATO");
  }
   if(numeroconta != 58092847) {
  Alert("NUMERO DA CONTA INVALIDO ! , manda uma MSG para o SUPORTE com o print do alerta.");
  Print("\n" + "NUMERO DA CONTA INVALIDO ! , manda uma MSG para o SUPORTE com o print do alerta.");
  ExpertRemove();
  }
  if(TimeCurrent() > vencimento) {
  //  Print("\n" +"ENTRAR EM CONTATO PARA RENOVAR O TEMPO DE USO");
  ExpertRemove();
  }
}

//+------------------------------------------------------------------+
//| GERENCIAMENTO DE PERDAS E GANHOS                                 |
//+------------------------------------------------------------------+
void controle_financeiro_diario(string ativo, double lucro_maximo_dia,double perda_maximo_dia)
{
   if(PositionSelect(ativo))
        {
         double lucro = PositionGetDouble(POSITION_PROFIT);
         
         
         Print("Lucro atual = ",lucro);
         
         if(lucro <= -perda_maximo_dia)
           {
            FecharPosicao();
            pode_operar = false;
            Print("Limite de perda batida: ",perda_maximo_dia);
           }
         
         if(lucro >= lucro_maximo_dia)
           {
            FecharPosicao();
            pode_operar = false;
            Print("Limite de ganho batida: ",lucro_maximo_dia);
           } 
         }
           
 } 
  //+------------------------------------------------------------------+
//|   NOVO DIA                                                       |
//+------------------------------------------------------------------+
bool NewDay()
{
   static datetime PrevDay;

   if(PrevDay < iTime(NULL, PERIOD_D1, 0)) {
      PrevDay = iTime(NULL, PERIOD_D1, 0);
      Print("Novo dia identificado");
      return(true);
   }
   else {
      return(false);
   }
}

//+------------------------------------------------------------------+
//|Hórario para poder operar                                         |
//+------------------------------------------------------------------+
int saberDiaDaSemana(datetime d)
   {
      //0-dom, 1-seg, 2-ter, 3-qua, 5-qui, 6-sex, 7-sab
      MqlDateTime str;
      TimeToStruct(d,str);
      
      return str.day_of_week;
   }
//---

bool horaPodeOperar(string inicio, string fim)
   {
      bool resp = false;
      
      datetime tc = TimeCurrent();
      
      if( TimeToString(tc,TIME_MINUTES)  >= inicio &&  TimeToString(tc,TIME_MINUTES)  <= fim )
        {
         resp = true;
         
        }else
           {
            resp = false;
           }
   
      return resp;
   }
   
//+------------------------------------------------------------------+
//|Arredondamento de valores                                         |
//+------------------------------------------------------------------+
double arredondaMultiplo5()
   {
         return 0;
   }

//+------------------------------------------------------------------+
//| FUNÇÃO BREAKEVEN                                                 |
//+------------------------------------------------------------------+
void realizarbreakeven(string ativo, double PontoBE, double IniciarBE)
  {
      int temposicao = PositionsTotal() > 0;
      Print(PositionSelect(ativo));
      Print(PositionGetInteger(POSITION_TICKET));
      bool estoucomprado = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY;
      bool estouvendido = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL;
      double precoatual = 0;
      SymbolInfoDouble(ativo, SYMBOL_LAST);

      double pontosdelucrobe = NormalizeDouble(PontoBE * Normalizarmanual(), _Digits);
      //---
      if(temposicao && estoucomprado)
        {

         precoatual =  SymbolInfoDouble(ativo, SYMBOL_BID);

         double precodeentrada = PositionGetDouble(POSITION_PRICE_OPEN);
         double precostoploss  = PositionGetDouble(POSITION_SL);
         double precotakeprofit  = PositionGetDouble(POSITION_TP);
         double gatilhobe = precodeentrada + IniciarBE * Normalizarmanual();
         //--- BE Tipo 1 - A cima do preço
         if(precoatual >= gatilhobe && !beAtivo)
           {
            ulong ticket = PositionGetTicket(0);
            if(ticket == 0)
              {
               Print("NÃO FOI POSSÍVEL REALIZAR BE NA COMPRA , RETORNO TICKET 0 (N TEM POSIÇÃO OU POSIÇÃO NÃO ENCONTRADA)" + " FUNÇÃO: " + __FUNCTION__);
              }
            //bool checksttp = verificarniveisdestoplossetakeprofit(ORDER_TYPE_BUY, ativoOp, precodeentrada + pontosdelucrobe, precotakeprofit, retornodeerros) == true;
            //if(checksttp)
              //{
               trade.PositionModify(ticket, precodeentrada + pontosdelucrobe, precotakeprofit);
               beAtivo = true;
               Print("\n", "BREAKEVEN NA COMPRA REALIZADO COM SUCESSO", "\n");
               //trade.PositionClosePartial(PositionGetTicket(0),nContrato);
              //}
           }
        }
      //---
      if(temposicao && estouvendido)
        {
         double precodeentrada = PositionGetDouble(POSITION_PRICE_OPEN);
         double precostoploss  = PositionGetDouble(POSITION_SL);
         double precotakeprofit  = PositionGetDouble(POSITION_TP);
         double gatilhobe = precodeentrada - IniciarBE * Normalizarmanual();
         precoatual =  SymbolInfoDouble(ativo, SYMBOL_ASK);

         //--- BE Tipo 1 - A cima do preço
         if(precoatual <= gatilhobe && !beAtivo)
           {
            ulong ticket = PositionGetTicket(0);
            if(ticket == 0)
              {
               Print("NÃO FOI POSSÍVEL REALIZAR BE NA VENDA , RETORNO TICKET 0 (N TEM POSIÇÃO OU POSIÇÃO NÃO ENCONTRADA)" + " FUNÇÃO: " + __FUNCTION__);
              }
            //bool checksttp = verificarniveisdestoplossetakeprofit(ORDER_TYPE_SELL, ativoOp, precodeentrada - pontosdelucrobe, precotakeprofit, retornodeerros) == true;
            //if(checksttp)
              //{
               trade.PositionModify(ticket, precodeentrada - pontosdelucrobe, precotakeprofit);
               beAtivo = true;
               Print("\n", "BREAKEVEN NA VENDA REALIZADO COM SUCESSO", "\n");
               //trade.PositionClosePartial(PositionGetTicket(0),nContrato);
              //}
           }
        }
      //---
      Print("");
  }
  
//+------------------------------------------------------------------+
//|  TRAILING STOP                                                   |
//+------------------------------------------------------------------+
void realizartrailingstop(string ativo, double IniciarTS,double velaLow,double velaHigh, double tickLast)
{
        //--- STOP LOSS MÒVEL - Compra
        
        if(PositionSelect(ativo) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY )//liga_train == SIM_TS && 
          {
           
            double preco_entrada = PositionGetDouble(POSITION_PRICE_OPEN);
            double preco_sl      = PositionGetDouble(POSITION_SL);
            double preco_tp      = PositionGetDouble(POSITION_TP);
            double gatilho_ts    = NormalizeDouble(preco_entrada + IniciarTS * Normalizarmanual(),_Digits);
            

            double novo_sl       = NormalizeDouble(velaLow*_Point,_Digits);//velas[1].low
            
            
            if( tickLast >= gatilho_ts && preco_sl != novo_sl && novo_sl > preco_sl) // 
              {
                  
                  
                  Print("Compra - SL atual = ", preco_sl, ", Novo = ", novo_sl, " , Preço da entrada = ", preco_entrada);
                  trade.PositionModify(PositionGetTicket(0),novo_sl,preco_tp);
                  desenhaLinhaHorizontal("TrailingStop",novo_sl,clrYellow);
                  /*
                  if(liga_par == SIM_PARCIAL && !parAtivo && nContrato > 0)
                    {
                     trade.PositionClosePartial(PositionGetTicket(0), nContrato, spread);
                     parAtivo = true;
                    } */
                  
                  
              }
           
           
          }
        
        //--- STOP LOSS MÒVEL - Venda
        
        if(PositionSelect(ativo) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL )//liga_train == SIM_TS && 
          {
           
                  double preco_entrada = PositionGetDouble(POSITION_PRICE_OPEN);
                  double preco_sl      = PositionGetDouble(POSITION_SL);
                  double preco_tp      = PositionGetDouble(POSITION_TP);
                  double gatilho_ts    = NormalizeDouble(preco_entrada - IniciarTS * Normalizarmanual(),_Digits);
                  
                  double novo_sl       = NormalizeDouble(velaHigh*_Point,_Digits);//velas[1].high
                  
                  
                  if(  tickLast <= gatilho_ts && preco_sl != novo_sl && novo_sl < preco_sl) // 
                    {
                        
                        Print("Venda - SL atual = ", preco_sl, ", Novo = ", novo_sl, " , Preço da entrada = ", preco_entrada);
                        trade.PositionModify(PositionGetTicket(0),novo_sl,preco_tp);
                        desenhaLinhaHorizontal("TrailingStop",novo_sl,clrYellow);
                        /*
                        if(liga_par == SIM_PARCIAL && !parAtivo && nContrato > 0)
                          {
                           trade.PositionClosePartial(PositionGetTicket(0), nContrato, spread);
                           parAtivo = true;
                          }; */
                        
                        
                        
                    }
            
           
          } 
}

void trailingstopStep(string ativo, double IniciarTS, double StepTS)
  {
      for(int i = PositionsTotal() - 1 ; i >= 0 ; i--)
        {
         bool estoucomprado = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY;
         bool estouvendido = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL;
         string symbol = PositionGetSymbol(i);
         ulong idrobo = PositionGetInteger(POSITION_MAGIC);
         //Print('Meu simbolo: ',symbol,'ID ROBO: ',idrobo,,'MAGIC: ',Magic);
         //if(symbol == ativoOp && idrobo == Magic)
           //{          
            ulong ticketposicao = PositionGetInteger(POSITION_TICKET);
            double precostoploss  = PositionGetDouble(POSITION_SL);
            double precotakeprofit  = PositionGetDouble(POSITION_TP);
            double precoentrada = PositionGetDouble(POSITION_PRICE_OPEN);
            double startts = NormalizeDouble(IniciarTS * Normalizarmanual(), _Digits);
            double precogatilho = NormalizeDouble(SymbolInfoDouble(ativo,SYMBOL_LAST),_Digits);
            //--- TS COMPRA
            if(estoucomprado)
              {
               double novostoploss =  NormalizeDouble(precogatilho - StepTS * Normalizarmanual(), _Digits);
               bool distanciaprecoestop = (precogatilho - precoentrada) > startts;
               if(distanciaprecoestop && precostoploss != novostoploss && novostoploss >= precostoploss )//&& precostoploss != novostoploss && novostoploss >= precostoploss
                 {
                  if(trade.PositionModify(ticketposicao, novostoploss, precotakeprofit))
                    {
                     Print("\n", "TS NA COMPRA REALIZADO COM SUCESSO " + string(trade.ResultRetcode()) + " DESCRIÇÃO RETCODE = " + string(trade.ResultRetcodeDescription())  + " FUNÇÃO: " + __FUNCTION__ + "\n");
                    }
                  else
                    {
                     Print("\n" + "TS NA COMPRA NÃO REALIZADO " + string(trade.ResultRetcode()) + " DESCRIÇÃO RETCODE = " + string(trade.ResultRetcodeDescription()) + " FUNÇÃO: " + __FUNCTION__ + "\n");

                    }
                 }
              }
            //--- TS VENDA
            if(estouvendido)
              {
               double novostoploss = NormalizeDouble(precogatilho + StepTS * Normalizarmanual(), _Digits);
               bool distanciaprecoestop = (precoentrada - precogatilho) > startts;
               if(distanciaprecoestop && precostoploss != novostoploss  && novostoploss <= precostoploss )//&& precostoploss != novostoploss  && novostoploss <= precostoploss
                 {
                  if(trade.PositionModify(ticketposicao, novostoploss, precotakeprofit))
                    {
                     Print("\n", "TS NA VENDA REALIZADO COM SUCESSO " + string(trade.ResultRetcode()) + " DESCRIÇÃO RETCODE = " + string(trade.ResultRetcodeDescription()) + " FUNÇÃO: " + __FUNCTION__ + "\n");
                    }
                  else
                    {
                     Print("\n" + "TS NA VENDA NÃO REALIZADO " + string(trade.ResultRetcode()) + " DESCRIÇÃO RETCODE = " + string(trade.ResultRetcodeDescription())  + " FUNÇÃO: " + __FUNCTION__ + "\n");

                    }
                 }
              }
            //---
           }
     }
     
void fazerParcial(string ativo, double contrato, double IniciarParcial, double tickLast)
{
   double preco_entrada = PositionGetDouble(POSITION_PRICE_OPEN);
   long   spread        = SymbolInfoInteger(ativo, SYMBOL_SPREAD);
   
   //---COMPRA
   double gatilho_parcial    = NormalizeDouble(preco_entrada + IniciarParcial * Normalizarmanual(),_Digits);
   
   if(tickLast >= gatilho_parcial && !parAtivo && contrato > 0 && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)//liga_par == SIM_PARCIAL && 
      {
         trade.PositionClosePartial(PositionGetTicket(0), contrato, spread);
         parAtivo = true;
      }
   
   //---VENDA   
   gatilho_parcial    = NormalizeDouble(preco_entrada - IniciarParcial * Normalizarmanual(),_Digits);
   
   if(tickLast <= gatilho_parcial && !parAtivo && contrato > 0 && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)//liga_par == SIM_PARCIAL && 
      {
         trade.PositionClosePartial(PositionGetTicket(0), contrato, spread);
         parAtivo = true;
      }
}

void TrailingStop(string ativo, double preco, double gatilhoTS, double stepTS)
   {
      for(int i = PositionsTotal()-1; i>=0; i--)
         {
            string symbol = PositionGetSymbol(i);
            ulong magic = PositionGetInteger(POSITION_MAGIC);
            if(PositionSelect(ativo))
               {
                  ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
                  double StopLossCorrente = PositionGetDouble(POSITION_SL);
                  double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
                  if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                     {
                        if(preco >= (StopLossCorrente + gatilhoTS) )
                           {
                              double novoSL = NormalizeDouble(StopLossCorrente + stepTS, _Digits);
                              if(trade.PositionModify(PositionTicket, novoSL, TakeProfitCorrente))
                                 {
                                    Print("TrailingStop - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                                 }
                              else
                                 {
                                    Print("TrailingStop - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                                 }
                           }
                     }
                  else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                     {
                        if(preco <= (StopLossCorrente - gatilhoTS) )
                           {
                              double novoSL = NormalizeDouble(StopLossCorrente - stepTS, _Digits);
                              if(trade.PositionModify(PositionTicket, novoSL, TakeProfitCorrente))
                                 {
                                    Print("TrailingStop - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                                 }
                              else
                                 {
                                    Print("TrailingStop - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                                 }
                           }
                     }
               }
         }
   }
//---
//---

void BreakEven(string ativo, double preco, double PontoBE, double gatilhoBE)
   {
      for(int i = PositionsTotal()-1; i>=0; i--)
         {
            string symbol = PositionGetSymbol(i);
            ulong magic = PositionGetInteger(POSITION_MAGIC);
            if(PositionSelect(ativo))
               {
                  ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
                  double PrecoEntrada = PositionGetDouble(POSITION_PRICE_OPEN);
                  double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
                  double pontosdelucrobe = NormalizeDouble(PontoBE * Normalizarmanual(), _Digits);
                  if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                     {
                        if( preco >= (PrecoEntrada + gatilhoBE) )
                           {
                              if(trade.PositionModify(PositionTicket, PrecoEntrada + pontosdelucrobe, TakeProfitCorrente))
                                 {
                                    Print("BreakEven - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                                    beAtivo = true;
                                 }
                              else
                                 {
                                    Print("BreakEven - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                                 }
                           }                           
                     }
                  else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                     {
                        if( preco <= (PrecoEntrada - gatilhoBE) )
                           {
                              if(trade.PositionModify(PositionTicket, PrecoEntrada - pontosdelucrobe, TakeProfitCorrente))
                                 {
                                    Print("BreakEven - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                                    beAtivo = true;
                                 }
                              else
                                 {
                                    Print("BreakEven - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                                 }
                           }
                     }
               }
         }
   }