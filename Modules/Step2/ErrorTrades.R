#--------------------------------------------------------------------------------------
# UCL -- Institute of Finance & Technology
# Student Name  : Muideen Abubakar
# Student Number : 21125043
# Coursework Two : Incorrect Trade Detection - Step 2
#--------------------------------------------------------------------------------------

#Get the trades not genuine

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
