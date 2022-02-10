#--------------------------------------------------------------------------------------
# UCL -- Institute of Finance & Technology
# Student Name  : Muideen Abubakar
# Student Number : 21125043
# Coursework Two : Incorrect Trade Detection - Step 4
#--------------------------------------------------------------------------------------

#Aggregate the trades for both days and insert into the portfolio_position table in SQL

#4a. Aggregate Quantity and Notional for all trades by date, trader, symbol, ccy
AggTrade <- aggregate(x=FirstDayTrade[c("Quantity","Notional")], by = FirstDayTrade[c("Trader","Symbol","Ccy")], FUN = sum)
AggTrade2 <- aggregate(x=SecondDayTrade[c("Quantity","Notional")], by = SecondDayTrade[c("Trader", "Symbol", "Ccy")], FUN = sum)
head(AggTrade2)

#4b. Insert the cob_date column
AggTrade$cob_date <- format(TradeDate1,"%d-%b-%Y")
AggTrade2$cob_date <- format(TradeDate2, "%d-%b-%Y")

#4c. Insert the pos_id column
AggTrade$pos_id <- paste0(AggTrade$Trader,"20211111",AggTrade$Symbol)
AggTrade2$pos_id <- paste0(AggTrade2$Trader, "20211112", AggTrade2$Symbol)

#4d. Reorder columns to match the arrangement of the Portfolio_Position table
AggTrade <- AggTrade[, c(7,6,1,2,3,4,5)]
AggTrade2 <- AggTrade2[, c(7,6,1,2,3,4,5)]

#4e. Rename the columns to match that of portfolio_position
AggTrade <- rename(AggTrade, c(symbol = Symbol, ccy = Ccy, net_quantity = Quantity, net_amount = Notional))
AggTrade2 <- rename(AggTrade2, c(symbol = Symbol, ccy = Ccy, net_quantity = Quantity, net_amount = Notional))

#4f. Insert AggTrade and AggTrade2 into portfolio_position table
for(i in 1:nrow(AggTrade)){
  dbExecute(conSql, paste0("INSERT INTO portfolio_positions (pos_id, cob_date, trader, symbol, ccy, net_quantity, net_amount) ",
                           "VALUES (\"", 
                           as.character(AggTrade$pos_id[i]),"\",",
                           "\"",as.character(AggTrade$cob_date[i]),"\",",
                           "\"",as.character(AggTrade$trader[i]),"\",",
                           "\"",as.character(AggTrade$symbol[i]),"\",",
                           "\"",as.character(AggTrade$ccy[i]),"\",",
                           AggTrade$net_quantity[i],",",
                           AggTrade$net_amount[i], 
                           ")"))}

for(i in 1:nrow(AggTrade2)){
  dbExecute(conSql, paste0("INSERT INTO portfolio_positions (pos_id, cob_date, trader, symbol, ccy, net_quantity, net_amount) ",
                           "VALUES (\"", 
                           as.character(AggTrade2$pos_id[i]),"\",",
                           "\"",as.character(AggTrade2$cob_date[i]),"\",",
                           "\"",as.character(AggTrade2$trader[i]),"\",",
                           "\"",as.character(AggTrade2$symbol[i]),"\",",
                           "\"",as.character(AggTrade2$ccy[i]),"\",",
                           AggTrade2$net_quantity[i],",",
                           AggTrade2$net_amount[i], 
                           ")"))}