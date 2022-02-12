#--------------------------------------------------------------------------------------
# Name  : Muideen Abubakar
# Doc Title : README 
#--------------------------------------------------------------------------------------
The objective: To detect incorrect trades for trades executed on 11-Nov-2021 and 12-Nov-2021

The Approach: Trade vs. Price

The Script Sequence/Logic: 
                        1. Starts by retrieving the trades for boths days from MongoDB
                        2. Compute the average unit price using the Quantity and Notional
                        3. Retrieve the data from the Equity database
                        4. Compare the price for each symbol against what was derived in 2 above
                        5. Seive the incorrect trades into a new trade_suspects table in SQL
                        6. Aggregate the trades for both days and insert into the portfolio_position table in SQL
                        7. Disconnect from  MongoDB and SQL

Running the script in an external environment: 
                                            To execute the script in a command shell, use;
                                            
                                            cd./Coursework/Coursework 1/MuideenAbubakar/2.CourseworkTwo
                                            
                                            Rscript Main.R C:/Users/user/Documents/BigData_in_Q.fin/Coursework/Coursework1/MuideenAbubakar/2.CourseworkTwo, "script.config", "script.params"

__________________________________________________________________________________________________________________________





