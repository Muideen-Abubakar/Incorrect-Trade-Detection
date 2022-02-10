# Incorrect-Trade-Detection
The aim of this project is to demonstrate a practical understanding of building data pipelines in order to extract data from a database, manipulate data and then load into a database
The case: Traders submit single trades at any point in time during the day of 2021-11-11 & 2021-11-12. Traders might make mistakes when they submit their trades, it is your responsibility to verify that trades submitted are genuine and in line with market expectations. If a trade is deemed to be suspect, (i.e. incorrect trade price or incorrect quantity), it must be reported.

To achieve this, the steps that will be taken are:

1. Retrieve all trades as per end of day (i.e. one run for all trades on 2021-11-11 and one run for 2021-11-12)
2. For each day, check that trades are consistent with expectations (i.e. there is no fat fingers error, inconsistency between quantity traded and notional amounts, genuine mis-pricing on the trade); Here, the model adopted to detect whether a trade is genuine or not is the trade vs other trade/price model 
3. If incorrect any trades are detected, create a new table in SQLite Database called trades_suspects. 
4. Load suspect trades into a new table in SQL. The creation statement for this table will be stored in "./modules/db/SQL/CreateTable." 
5. aggregate Quantity and Notional for all trades by date, trader, symbol, ccy and insert the results into portfolio_positions.
