#--------------------------------------------------------------------------------------
# UCL -- Institute of Finance & Technology
# Student Name  : Muideen Abubakar
# Student Number : 21125043
# Coursework Two : Incorrect Trade Detection - Step 1
#--------------------------------------------------------------------------------------

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