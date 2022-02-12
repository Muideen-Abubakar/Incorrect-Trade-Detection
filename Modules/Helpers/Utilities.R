#--------------------------------------------------------------------------------------
# Name  : Muideen Abubakar
# Doc Title : Helper Functions
#--------------------------------------------------------------------------------------

#-- Print info log
#-- function for logging script info into console

printInfoLog <- function(message, type = "info"){
  
  type <- toupper(type)
  
  message <- paste0("[", type,"] ", Sys.time(), " ----- ", message, "\n \n")
  
  return(cat(message))
}
