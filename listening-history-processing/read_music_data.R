library(rjson)

# STEP 1: read in history from original .json

files <- list.files("spotify_data/streaming_history", full.names = TRUE)
history_lists <- lapply(files, function(x){fromJSON(file = x)}) # creates list of lists

# STEP 2: convert lists to dataframes

history_list <- do.call(c, history_lists) # join lists into single list
history <- do.call(rbind.data.frame, history_list) # convert everything to DF

# STEP 3: export to TSV
# storing as TSV instead of CSV, etc. b/c artist and track names contain
# all sorts of symbols, including , and ; and even |

write.table(history, file = "spotify_history.tsv", quote = FALSE,
            sep = '\t', row.names = FALSE)
