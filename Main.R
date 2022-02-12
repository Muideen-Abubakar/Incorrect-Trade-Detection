#--------------------------------------------------------------------------------------
# Name  : Muideen Abubakar
# Doc Title : Incorrect Trade Detection
#--------------------------------------------------------------------------------------

library(lubridate)
library(dplyr)
library(stringi)
library(RSQLite)             
library(mongolite)


#Args = c("C:/Users/user/Documents/BigData_in_Q.fin/Coursework/Coursework1/MuideenAbubakar/2.CourseworkTwo", "script.config", "script.params")
Args <- commandArgs(TRUE)
# Set working directory
setwd(Args[1])
#getwd()
# Source config
source(paste0("./Config/", Args[2]))
# Source params
source(paste0("./Config/", Args[3]))
# Source helper functions
source(Config$Directories$HelperFunctions)

printInfoLog("Main.r :: Script Settings Loaded...", type = "info")

#Trading Days
TradeDate1 <- as.Date("2021-11-11")
TradeDate2 <- as.Date("2021-11-12")


# Setting up connection with the MongoDB and SQL databases 
printInfoLog("Main.R :: Connecting to SQLite DB")

conMongo <- mongo(collection = "CourseworkTwo", db = "Equity", url = "mongodb://localhost",
                  verbose = FALSE, options = ssl_options())
conSql <- dbConnect(RSQLite::SQLite(), Config$Directories$SQLDataBase)

#Testing the connection
LowQtySymb <- conMongo$find(query = '{ "Quantity": {"$lt": 6000 } }', fields = '{ "Symbol": 1, "_id": 0}')
LowQtySymb

LowQty <- conMongo$find('{"Quantity":5000}')
print(LowQty)

#1a. Data Manipulations to get end of day trades
FirstDayTrade <- conMongo$find(query = '{"DateTime": {"$gte": "ISODate(2021-11-11T00:00:00.000Z)", 
                                "$lt": "ISODate(2021-11-12T00:00:00.000Z)" }}')
FirstDayTrade

SecondDayTrade <- conMongo$find(query = '{"DateTime": {"$gte": "ISODate(2021-11-12T00:00:00.000Z)"}}')
SecondDayTrade

#1b. Select the relevant columns
Relevant_Cols <- c("DateTime", "Trader", "Symbol", "Notional", "Quantity")
Relevant_Table <- FirstDayTrade[Relevant_Cols]
Relevant_Table2 <- SecondDayTrade[Relevant_Cols]

#2a. Estimate the unit price by dividing Notional by Quantity
Relevant_Table$UnitPrice <- FirstDayTrade[,6]/FirstDayTrade[,5]
Relevant_Table2$UnitPrice <- SecondDayTrade[,6]/SecondDayTrade[,5]
head(Relevant_Table2)

#2b. Query the SQL Equity Table for trades on 11-Nov-2021
sql_EquityTable <- dbGetQuery(conSql, "SELECT open, high, low, close, symbol_id FROM equity_prices WHERE cob_date = '11-Nov-2021';")

#2c. Query the SQL Equity Table for trades on 12-Nov-2021
sql_EquityTable2 <- dbGetQuery(conSql, "SELECT open, high, low, close, symbol_id FROM equity_prices WHERE cob_date = '12-Nov-2021';")

#2d. Rename symbol_id to Symbol, so the primary key matches with that of the Relevant_Table
names(sql_EquityTable)[5] <- "Symbol"
names(sql_EquityTable2)[5] <- "Symbol"
head(sql_EquityTable2)

#2e. Join both tables to form a new table
New_EquityDB <- left_join(Relevant_Table, sql_EquityTable)
New_EquityDB2 <- left_join(Relevant_Table2, sql_EquityTable2)
head(New_EquityDB2)

#2f. Find the suspect trades by comparing if the Unit Price falls within the High-Low price range
Mistake_Check <- New_EquityDB$UnitPrice <= New_EquityDB$high & New_EquityDB$UnitPrice >= New_EquityDB$low
Checked_Mistake <- New_EquityDB[!Mistake_Check, ] #Check the CreateTable.r file to see the codes for creating the suspect_trades table in SQLite

Mistake_Check2 <- New_EquityDB2$UnitPrice <= New_EquityDB2$high & New_EquityDB2$UnitPrice >= New_EquityDB2$low
Checked_Mistake2 <- New_EquityDB2[!Mistake_Check2, ] #Check the CreateTable.r file to see the codes for creating the suspect_trades table in SQLite

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
AggTrade <- rename(AggTrade, c(symbol = Symbol, ccy = Ccy, net_quantity = Quantity, net_amount = Notional, trader = Trader))
AggTrade2 <- rename(AggTrade2, c(symbol = Symbol, ccy = Ccy, net_quantity = Quantity, net_amount = Notional, trader = Trader))

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

# Close Mongo & SQL Connections -------------------------------------------


dbDisconnect(conSql)
conMongo$disconnect()
printInfoLog("SQLUpdate.R :: SQL Update Completed")# Close Mongo & SQL Connections -------------------------------------------



