-- Taylor Swift Songs Data Exploration
-- SOURCES:

-- Data Set - https://www.kaggle.com/datasets/jarredpriester/taylor-swift-spotify-dataset
-- I also added a second table 'TS_Song_Details' with details from this article: https://www.musicgrotto.com/taylor-swift-songs-about-exes/
-- Note: Before starting I renamed some of the columns for clarity.

--COLUMN KEY:

--Taylor_Swift_Spotify:

-- ID - a simplified unique ID for each song
-- Song - the name of the song
-- Album - the name of the album
-- Release_Date - YYYY -MM-DD - the date the album was released
-- Track_Number - the order the song appears on the album
-- Spotify_ID - the Spotify id for the song
-- Spotify_ID - the Spotify uri for the song
-- Acousticness - 0.0 - 1.0 - whether the track is acoustic. 1.0 represents high confidence the track is acoustic.
-- Danceability - 0.0 - 1.0 - how suitable the song is for dancing
-- Energy - 0.0 - 1.0 - how energetic the song is
-- Instrumentalness - 0.0 - 1.0 - The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content.
-- Liveness - 0.0 - 1.0 - Detects the presence of an audience in the recording.
-- AvgDecibels - The overall loudness of a track in decibels (dB). 
-- Speechiness - 0.0 - 1.0 - Detects the presence of spoken words in a track. The closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech. Values below 0.33 most likely represent music.
-- Tempo - The overall estimated tempo of a track in beats per minute (BPM). 
-- Valence - A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
-- CurrentPopularity - the popularity of the song from 0 to 100. This is straight from the Spotify API and is a 0-100 range based on how 'hot' the track is across the platform.
-- Duration - The duration of the track in milliseconds.

-- TS_Song_Details:

-- Song_Name - The name of the song
-- Album_Name - The name of the album
-- Release_Date - The day month and year the album was released
-- Song_About_Ex - Detects whether or not the song has been connected to one of Taylor's ex-boyfriends (based on evidence from https://www.musicgrotto.com/taylor-swift-songs-about-exes/)
-- Speculated_Ex - Names the ex-boyfriend connected to the song (based on evidence from https://www.musicgrotto.com/taylor-swift-songs-about-exes/)

------------------------------------------------------------------------------------

-- First I want to get a general idea of how many songs Taylor has and pull some other basic metrics
-- Looking at the total number of songs Taylor has on Spotify (including all versions)

SELECT COUNT(Song) as TotalSongs
FROM Taylor_Swift_Spotify

-- Looking at the number of Unique songs. In this query, I am filtering out all the different versions so I can find out how many songs she wrote. I want to exclude Deluxe/Live/Tour versions of songs, but did not want to exclude Taylor's Version songs, so I'm using Album to apply contraints and included Red and Fearless (Taylor Versions) because Taylor took down the original versions of those albums. I'm also filtering out "Speak Now" because Taylor's Version of the album has been added to Spotify, but her original album hasn't been removed yet.

SELECT Song, Album
FROM Taylor_Swift_Spotify
WHERE ALBUM != 'Speak Now'
AND Album NOT LIKE '%Deluxe%'
AND Album NOT LIKE '%deluxe version%'
AND Album NOT LIKE '%international version%'
AND Album NOT LIKE '%Tour%'
AND Album NOT LIKE '%Til%'
AND Album NOT LIKE '%3am%'
AND Album NOT LIKE '%Live%'
AND Album NOT LIKE '%platinum%'

SELECT COUNT(DISTINCT Song) as TotalUniqueSongs
FROM Taylor_Swift_Spotify
WHERE ALBUM != 'Speak Now'
AND Album NOT LIKE '%Deluxe%'
AND Album NOT LIKE '%deluxe version%'
AND Album NOT LIKE '%international version%'
AND Album NOT LIKE '%Tour%'
AND Album NOT LIKE '%Til%'
AND Album NOT LIKE '%3am%'
AND Album NOT LIKE '%Live%'
AND Album NOT LIKE '%platinum%'

--Now I will use a CTE with a subquery to be able to pull the total number of songs vs the unique songs. 
--I found that there are 476 total tracks on Spotify and 183 unique songs, so only 38% of the tracks in this dataset are unique songs. The rest are basically duplicates because they are different versions of the songs she wrote.

WITH CTE_TaylorSongMetrics as
(SELECT COUNT(Song) as TotalSongs, 
	(SELECT COUNT(Song)
	 FROM Taylor_Swift_Spotify
	 WHERE Album != 'Speak Now'
	 AND Album NOT LIKE '%Deluxe%'
	 AND Album NOT LIKE '%deluxe version%'
	 AND Album NOT LIKE '%international version%'
	 AND Album NOT LIKE '%Tour%'
	 AND Album NOT LIKE '%Til%'
	 AND Album NOT LIKE '%3am%'
	 AND Album NOT LIKE '%Live%'
	 AND Album NOT LIKE '%platinum%') as TotalUniqueSongs 
FROM Taylor_Swift_Spotify)
SELECT TotalSongs, TotalUniqueSongs, (TotalUniqueSongs * 100/TotalSongs) as PercentUnique
FROM CTE_TaylorSongMetrics

-- Since there is such a big difference between the number of tracks and the number of unique songs, I'm now going to create a temp table with the unique songs so that I can query off of it multiple times later

CREATE TABLE #Unique_Songs (Song varchar(255)
,Album varchar(255)
,Release_Date date
,Danceability float
,Speechiness float
,Valence float
,CurrentPopularity int
,Duration nvarchar(255)
)

INSERT INTO #Unique_Songs
SELECT Song,Album,Release_Date,Danceability,Speechiness,Valence,CurrentPopularity,Duration_Min_Sec
FROM Taylor_Swift_Spotify
WHERE ALBUM != 'Speak Now'
	 AND Album NOT LIKE '%Deluxe%'
	 AND Album NOT LIKE '%deluxe version%'
	 AND Album NOT LIKE '%international version%'
	 AND Album NOT LIKE '%Tour%'
	 AND Album NOT LIKE '%Til%'
	 AND Album NOT LIKE '%3am%'
	 AND Album NOT LIKE '%Live%'
	 AND Album NOT LIKE '%platinum%'

SELECT *
FROM #Unique_Songs

--Looking at the duration ranges of Taylor's original songs, grouped by Album

SELECT Album,MAX(Duration) as LongestSong, MIN(Duration) as ShortestSong
FROM #Unique_Songs
GROUP BY Album
ORDER BY LongestSong DESC

-- Are her songs more positive or negative? Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
-- Interestingly enough, the average valence for each of her albums is under 0.5, showing that her songs tend to be skewed towards more negative feelings

SELECT Album,Avg(Valence) as Positivity
FROM #Unique_Songs
GROUP BY Album
ORDER BY Positivity DESC

-- I wanted to break this down further and categorize her songs by Positive (above 0.66), Indifferent (between 0.33 - 0.66), and Negative (under 0.33)

SELECT Song,Valence,
CASE
	WHEN Valence < 0.33 THEN 'Negative'
	WHEN Valence > 0.66 THEN 'Positive'
	WHEN Valence BETWEEN 0.33 AND 0.66 THEN 'Indifferent'
END AS SongFeeling
FROM #Unique_Songs
ORDER BY SongFeeling

------------------------------------------------------------------------------------

--Now let’s explore Taylor’s song popularity. Since the dataset is from Spotify, it is important to note that the popularity score is compared to all songs on Spotify.

--What is the most popular Taylor Swift Song on Spotify right now? Answer: Cruel Summer at 98 popularity!

SELECT TOP 1 song,CurrentPopularity
FROM Taylor_Swift_Spotify
ORDER BY CurrentPopularity DESC

--What are the top ten most popular Taylor Swift Songs on Spotify right now?

SELECT TOP 10 song,CurrentPopularity
FROM Taylor_Swift_Spotify
ORDER BY CurrentPopularity DESC

--What are the least popular songs?

SELECT Top 10 song,CurrentPopularity
FROM Taylor_Swift_Spotify
ORDER BY CurrentPopularity ASC

--What is the danceability and valence of the top ten most popular songs?

SELECT Top 10 Song, CurrentPopularity, Danceability, Valence
FROM Taylor_Swift_Spotify
ORDER BY CurrentPopularity DESC

--Shows that the danceability of Taylor's songs range from pretty low (0.24) to very high (0.89) with an average of 0.58. So, a little more than half of her songs can make you wanna dance!

SELECT TOP 10 Avg(Danceability) as AvgDanceability, Min(Danceability) as MinDanceability, MAX(Danceability) as MaxDanceability
FROM Taylor_Swift_Spotify

--Shows that the valence (positivity) of Taylor's songs range from VERY low (0.037) to very high (0.943) with an average of 0.39. So, from this data suggests that while Taylor's music ranges vastly when it comes to the positivity of the music, the majority of her songs tend to be on the negative side (with sad, depressed, angry or feelings)

SELECT TOP 10 Avg(Valence) as AvgValence, Min(Valence) as MinValence, MAX(Valence) as MaxValence
FROM Taylor_Swift_Spotify


------------------------------------------------------------------------------------

-- I want to learn more about Taylor’s songs that were written about her exes. For years, I have heard people say “she only writes songs about her exes”...that was her reputation. I want to explore this theory with data!

-- I'm interested in finding out how many of these songs were written about one of her exes and how do they relate on the popularity scale?
-- First, I'm going to use a LEFT JOIN to bring the ex details from TS_Song_Details together with my temp table, then I am filtering with WHERE to only songs where Song_About_Ex is Y
-- This first query shows that there are 31 songs written about her exes and the popularity of the songs range from 56 to 86. 

SELECT DISTINCT uni.Song,det.Song_About_Ex,det.Speculated_Ex,uni.CurrentPopularity
FROM #Unique_Songs as uni
JOIN TS_Song_Details as det ON uni.Song = det.Song_Name
WHERE det.Song_About_Ex = 'Y'
ORDER BY uni.CurrentPopularity DESC

-- What percent of her unique songs are written about an ex? Below I am using a CTE, Subquery, and JOIN to my temp table from before to compare the number of songs written about an ex to her total amount of unique songs.
-- Answer: The query below shows that out of the 183 Total unique songs, 38 of them are speculated to be about one of her Exes, coming out to 20% of her songs. While 20% is a good chunk of her songs, this shows that not ALL of her songs are about her exes.

WITH CTE_ExSongs as
(SELECT COUNT(Song) as TotalSongs, 
	(SELECT COUNT(uni.Song)
	 FROM #Unique_Songs as uni
     JOIN TS_Song_Details as det ON uni.Song = det.Song_Name
	 WHERE det.Song_About_Ex = 'Y') as AboutEx
FROM #Unique_Songs)
SELECT TotalSongs, AboutEx, (AboutEx * 100/TotalSongs) as PercentAboutEX
FROM CTE_ExSongs


-- What is the average popularity rate for songs about her exes as opposed to the rest of her songs?
-- The query below shows that the Average popularity for Taylor's songs that are NOT about her exes is 74, as opposed to the average of 70 for songs about her ex. So, there is not much of a difference in popularity.

WITH CTE_ExPopSongs as
(SELECT AVG(uni.CurrentPopularity) as AvgPopNotAboutEx, 
	(SELECT AVG(uni.CurrentPopularity)
	 FROM #Unique_Songs as uni
     JOIN TS_Song_Details as det ON uni.Song = det.Song_Name
	 WHERE det.Song_About_Ex = 'Y') as AvgPopAboutEx
FROM #Unique_Songs as uni
JOIN TS_Song_Details as det ON uni.Song = det.Song_Name
WHERE Song_About_Ex = 'N')
SELECT AvgPopNotAboutEx, AvgPopAboutEx
FROM CTE_ExPopSongs

-- What is the average valence (positivity) for songs about her exes as opposed to the rest of her songs?
-- In theory, her songs about her exes are more negative on average than her other songs. Let's see if the data supports this.
-- The query below shows that the avg valence of songs not about her ex is 0.389 and the average valence of songs about her exes is almost exactly the same with 0.387.

WITH CTE_ExSongsValence as
(SELECT AVG(uni.Valence) as AvgValenceNotAboutEx, 
	(SELECT AVG(uni.Valence)
	 FROM #Unique_Songs as uni
     JOIN TS_Song_Details as det ON uni.Song = det.Song_Name
	 WHERE det.Song_About_Ex = 'Y') as AvgValenceAboutEx
FROM #Unique_Songs as uni
JOIN TS_Song_Details as det ON uni.Song = det.Song_Name
WHERE Song_About_Ex = 'N')
SELECT AvgValenceNotAboutEx, AvgValenceAboutEx
FROM CTE_ExSongsValence

-- Knowing that there are only 38 songs about her ex, I also wanted to find the standard deviation to see if there is a difference
-- The result showed that the SD of valence on songs not about her ex is 0.188 and songs about her ex is 0.195

WITH CTE_ExSongsValence as
(SELECT STDEV(uni.Valence) as SDValenceNotAboutEx, 
	(SELECT STDEV(uni.Valence)
	 FROM #Unique_Songs as uni
     JOIN TS_Song_Details as det ON uni.Song = det.Song_Name
	 WHERE det.Song_About_Ex = 'Y') as SDValenceAboutEx
FROM #Unique_Songs as uni
JOIN TS_Song_Details as det ON uni.Song = det.Song_Name
WHERE Song_About_Ex = 'N')
SELECT SDValenceNotAboutEx, SDValenceAboutEx
FROM CTE_ExSongsValence

-- Finally, I am going to create a stored procedure with an 'ex' parameter so we can look up the specific ex mentioned and find info that way

CREATE PROCEDURE TaylorSwiftUniqueSongs
AS
CREATE TABLE #UniqueSongs (
Song varchar(255)
,Album varchar(255)
,Release_Date date
,Danceability float
,Speechiness float
,Valence float
,CurrentPopularity int
,Duration nvarchar(255)
,Song_About_Ex nvarchar(255)
,Speculated_Ex nvarchar(255)
)
INSERT INTO #UniqueSongs
SELECT DISTINCT spot.Song,spot.Album,spot.Release_Date,spot.Danceability,spot.Speechiness,spot.Valence,spot.CurrentPopularity,spot.Duration_Min_Sec,det.Song_About_Ex,det.Speculated_Ex
FROM Taylor_Swift_Spotify as spot
JOIN TS_Song_Details as det ON spot.Song = det.Song_Name
WHERE spot.ALBUM != 'Speak Now'
	 AND spot.Album NOT LIKE '%Deluxe%'
	 AND spot.Album NOT LIKE '%deluxe version%'
	 AND spot.Album NOT LIKE '%international version%'
	 AND spot.Album NOT LIKE '%Tour%'
	 AND spot.Album NOT LIKE '%Til%'
	 AND spot.Album NOT LIKE '%3am%'
	 AND spot.Album NOT LIKE '%Live%'
	 AND spot.Album NOT LIKE '%platinum%'

SELECT *
FROM TaylorSwiftUniqueSongs

--Now, I can look up the data specific to one of Taylor's exes!

EXEC TaylorSwiftUniqueSongs @SpeculatedEx = 'Joe Jonas'