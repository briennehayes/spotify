library(rjson)
library(tidyr)
library(dplyr)

# using playlists is optional, but I do it because playlist records contain
# track URIs while stream history does not. This saves a step for all tracks in
# track history that are in at least one playlist

# STEP 1: read in history from original .json

files <- list.files("spotify_data/playlist", full.names = TRUE)
# creates list of lists;
# for some reason Spotify wraps each playlist file in a "playlists" layer
# so we also remove that here
playlist_lists <- lapply(files, function(x){fromJSON(file = x)$playlists}) 
playlists <- do.call(c, playlist_lists)

# STEP 2: extract track data from lists

# we don't care about which playlist each track was in, we just
# want the URI

trackData <- lapply(playlists, function(playlist){
  # creates a list of lists, where each child list contains the info vector
  # for each track in the playlist
  trackInfoList <- lapply(playlist$items, function(item){
    track <- item$track
    return(c(track$trackName, track$artistName, track$trackUri))
  })
  # flatten into list of matrices
  trackInfo <- do.call(rbind, trackInfoList)
})
# flatten again into a dataframe
trackDataDf <- do.call(rbind, trackData) %>%
  unique.data.frame()
colnames(trackDataDf) <- c("track", "artist", "uri")

# STEP 3: sync URIs from playlists w/ listening history

# STEP N: export to TSV
# storing as TSV instead of CSV, etc. b/c artist and track names contain
# all sorts of symbols, including , and ; and even |

write.table(history, file = "spotify_history.tsv", quote = FALSE,
            sep = '\t', row.names = FALSE)