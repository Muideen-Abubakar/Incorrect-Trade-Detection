#--------------------------------------------------------------------------------------
# UCL -- Institute of Finance & Technology
# Student Name  : Muideen Abubakar
# Student Number : 21125043
# Coursework Two : Incorrect Trade Detection - CreateTable
#--------------------------------------------------------------------------------------

#3a. Create the trade_suspects table for both days
suspected_trades <- dbWriteTable(conSql, "trades_suspects", Checked_Mistake, overwrite=TRUE, row.names=FALSE)
suspected_trades <- dbWriteTable(conSql, "trades_suspects", Checked_Mistake2, append=TRUE, row.names=FALSE)

#--------------------------------------------------------------------------------------