--Taylor Swift Songs - Data Cleaning Project

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

-- First, I am checking for NULLS to make sure we have everything we need. 
-- It came out clean for Taylor_Swift_Spotify

SELECT *
FROM taylor_swift_spotify
WHERE ID is null
	OR Song is null
	OR Album is null
	OR Release_Date is null
	OR Track_Number is null
	OR Spotify_URI is null
	OR Acousticness is null
	OR Danceability is null
	OR Energy is null
	OR Instrumentalness is null
	OR Liveness is null
	OR Loudness is null
	OR Speechiness is null
	OR Tempo is null
	OR Valence is null
	OR Popularity is null
	OR Duration is null

--The only NULLS that came up in the ts_song_details table were from the Songs_About_Ex and Speculated_Ex columns.

SELECT *
FROM ts_song_details
WHERE Song_Name is null
	OR Album_Name is null
	OR Release_Date is null
	OR Song_About_Ex is null
	OR Speculated_Ex is null
ORDER BY Song_Name

--Below I'm doublechecking that they have the same amount of NULLS. 
--Since the Song_About_Ex column shows if the song is about one of Taylor's Exes, the Speculated_Ex column should always be NULL if the Song_About_Ex column is NULL. 
--This is the case, so we are good to go.

SELECT
    (SELECT COUNT(*) FROM ts_song_details WHERE Song_About_Ex IS NULL) AS NullsInSongAboutEx,
    (SELECT COUNT(*) FROM ts_song_details WHERE Speculated_Ex IS NULL) AS NullsInSpeculatedEx

-- To make everything nice and clean, I am going to enter in values 'N' in place of the nulls in Song_About_Ex & "N/A" in Speculated_Ex
-- I'm selecting the data to be updated first to ensure I have the right data.

SELECT Song_Name,Speculated_Ex
FROM ts_song_details
WHERE Speculated_Ex is null

UPDATE ts_song_details
SET Speculated_Ex = 'N/A'
WHERE Speculated_Ex is null

SELECT Song_Name,Song_About_Ex
FROM ts_song_details
WHERE Song_About_Ex is null

UPDATE ts_song_details
SET Song_About_Ex = 'N'
WHERE Song_About_Ex is null

------------------------------------------------------------------------------------

--Standardizing the formatting. 
--The Release Date column values had the time data, but we do not need that info.

ALTER TABLE taylor_swift_spotify
ALTER COLUMN Release_Date date

ALTER TABLE ts_song_details
ALTER COLUMN Release_Date date

--Correcting the columns that should be integers

SELECT *
FROM taylor_swift_spotify

ALTER TABLE taylor_swift_spotify
ALTER COLUMN ID int

ALTER TABLE taylor_swift_spotify
ALTER COLUMN Track_Number int

ALTER TABLE taylor_swift_spotify
ALTER COLUMN Popularity int

SELECT *
FROM ts_song_details

ALTER TABLE ts_song_details
ALTER COLUMN ID int

--Changing the Duration values from milliseconds to minutes and seconds.
--First I am converting the data type to nvarchar since the modulo operator was giving an error that data types "float" and "int" are incompatible.

ALTER TABLE Taylor_Swift_Spotify
ALTER COLUMN Duration nvarchar(255)

SELECT *
FROM Taylor_Swift_Spotify

--Now, I will convert the duration to minutes and seconds. Here I am calculating the minutes by dividing the ms version by 60000, then converting it to a string and limiting it to two characters. It will put a 0 in front if it is less than 10 minutes. Next, I'm converting the seconds in a similar way. Then, I am using CONCAT to add a ":" between minutes and seconds.

SELECT Song,Duration,
	CONCAT(
	RIGHT('0' + CAST(duration/60000 as nvarchar), 2),
	':',
	RIGHT('0' + CAST((Duration/1000) % 60 as nvarchar),2)
	) AS Duration_Min_Sec
FROM taylor_swift_spotify

--Now I will add the column to the table

ALTER TABLE taylor_swift_spotify
ADD Duration_Min_Sec nvarchar(255)

UPDATE taylor_swift_spotify
SET Duration_Min_Sec = CONCAT(
	RIGHT('0' + CAST(duration/60000 as nvarchar), 2),
	':',
	RIGHT('0' + CAST((Duration/1000) % 60 as nvarchar),2)
	)

--After doublechecking that the new Duration column is correct (I cross-checked a few songs in Spotify), I removed the original Duration column that was in milliseconds because I will not need it.
ALTER TABLE taylor_swift_spotify
DROP COLUMN Duration;

------------------------------------------------------------------------------------
--Checking String columns to remove any inconsistency
--Checking the Albums and Release Dates to ensure there arent any typos that need fixing

SELECT DISTINCT Album,Release_Date 
FROM Taylor_Swift_Spotify
ORDER BY Release_Date

SELECT * 
FROM ts_song_details

--Next, I checked the Speculated_Ex column and found that there were two different versions of "John Mayer", one with an accidental ";" after it.

SELECT Speculated_Ex,COUNT(Speculated_EX) as NumberOfSongsAboutHim
FROM ts_song_details 
GROUP BY Speculated_EX

UPDATE ts_song_details
SET Speculated_Ex = 'John Mayer'
WHERE Speculated_Ex = 'John Mayer;'


--Next I am going to check the columns that have strings and see if I need to fix anything or if I want to parse any of the data.

SELECT * 
FROM Taylor_Swift_Spotify

-- Below I'm checking to make sure the ID, Song, Album, and Release Date matches on both tables. Then, I'm checking to see how many unique songs there are. 
-- I noticed that a lot of songs have more than one version (Taylor's Version, Deluxe, etc), so I'm going to make a new column to specify the song version and parse the song name from any versions so we would be able to identi

SELECT *
FROM Taylor_Swift_Spotify as spot
LEFT JOIN ts_song_details as det
	ON spot.ID = det.ID
	AND spot.Song = det.Song_Name
	AND spot.Album = det.Album_Name
	AND spot.Release_Date = det.Release_Date
WHERE det.ID IS NULL

SELECT *
FROM ts_song_details as det
LEFT JOIN Taylor_Swift_Spotify as spot
	ON det.ID = spot.ID
	AND det.Song_Name =  spot.Song
	AND det.Album_Name = spot.Album
	AND det.Release_Date = spot.Release_Date
WHERE det.ID IS NULL

SELECT DISTINCT Song
FROM Taylor_Swift_Spotify
ORDER BY Song

SELECT spot.Song,COUNT(spot.Song) as CountOfEachSong
FROM Taylor_Swift_Spotify as spot
LEFT JOIN ts_song_details as det
	ON spot.ID = det.ID
GROUP BY spot.Song

SELECT Song
FROM Taylor_Swift_Spotify
WHERE Song LIKE '%(%'

-- The case statements below find the parentheses in the Song and will move the text within it to a new column

SELECT Song,
	CASE
		WHEN CHARINDEX('(', Song) >0 THEN SUBSTRING(Song,1, CHARINDEX('(', Song)-1)
		ELSE Song
	END as SongTitle,
	CASE
		WHEN CHARINDEX('(', Song) >0 THEN SUBSTRING(Song,CHARINDEX('(', Song) +1, CHARINDEX(')',Song) - CHARINDEX('(',Song)-1)
		ELSE ''
	END as SongVersion
FROM Taylor_Swift_Spotify

-- After separating out the Song Version, I double-checked my work and noticed there are "Live" versions that are specified after a "-" instead of a "()"
-- I also know that one song is called "Anti-Hero" so I am running a check first to see if there are any songs with words that contain a hyphen

SELECT Song
FROM Taylor_Swift_Spotify
WHERE Song LIKE '%[a-z]-[a-z]%'

SELECT Song,
	CASE --Identifying the Song Title
		WHEN Song = 'Anti-Hero' 
			THEN Song
		WHEN CHARINDEX('(', Song) >0 
			THEN SUBSTRING(Song,1, CHARINDEX('(', Song)-2)
		WHEN Song LIKE '%-%' 
			THEN SUBSTRING(Song, 1, CHARINDEX('-', Song) - 2)
		ELSE Song
	END as SongTitle,
	CASE --Identifying the version
		WHEN Song = 'Anti-Hero' 
			THEN Song
		WHEN CHARINDEX('(', Song) >0 
			THEN SUBSTRING(Song,CHARINDEX('(', Song) +1, CHARINDEX(')',Song) - CHARINDEX('(',Song)-1)
		WHEN Song LIKE '%-%'
			THEN SUBSTRING(Song,CHARINDEX('-',Song) +2,LEN(Song))
		ELSE ''
	END as SongVersion
FROM Taylor_Swift_Spotify

--Now I'm going to add these new columns and data to the table

ALTER TABLE Taylor_Swift_Spotify
Add SongTitle nvarchar(255)

UPDATE Taylor_Swift_Spotify
SET SongTitle = 
	CASE 
		WHEN Song = 'Anti-Hero' 
			THEN Song
		WHEN CHARINDEX('(', Song) >0 
			THEN SUBSTRING(Song,1, CHARINDEX('(', Song)-2)
		WHEN Song LIKE '%-%' 
			THEN SUBSTRING(Song, 1, CHARINDEX('-', Song) - 2)
		ELSE Song
	END

ALTER TABLE Taylor_Swift_Spotify
Add SongVersion nvarchar(255)

UPDATE Taylor_Swift_Spotify
SET SongVersion = 
	CASE
		WHEN Song = 'Anti-Hero' 
			THEN Song
		WHEN CHARINDEX('(', Song) >0 
			THEN SUBSTRING(Song,CHARINDEX('(', Song) +1, CHARINDEX(')',Song) - CHARINDEX('(',Song)-1)
		WHEN Song LIKE '%-%'
			THEN SUBSTRING(Song,CHARINDEX('-',Song) +2,LEN(Song))
		ELSE ''
	END

------------------------------------------------------------------------------------

-- After checking my work, I found that one version of "I Knew You Were Trouble" had a period at the end and there were two different "You're Not Sorry"

SELECT DISTINCT SongTitle,COUNT(SongTitle)
FROM Taylor_Swift_Spotify
GROUP BY SongTitle

SELECT SongTitle
FROM Taylor_Swift_Spotify
WHERE SongTitle LIKE '%I Knew You Were Trouble.%'

UPDATE Taylor_Swift_Spotify
SET SongTitle = 'I Knew You Were Trouble'
WHERE SongTitle LIKE '%I Knew You Were Trouble.%'

--I had to copy/paste the different versions of "You're Not Sorry" below to figure out what was different and found that one was using a type-writer style single quotation mark.

SELECT SongTitle
FROM Taylor_Swift_Spotify
WHERE SongTitle LIKE '%Not Sorry%'

--You're Not Sorry
--Youre Not Sorry

-- There is also a song called "Back To December/Apologize/You're Not Sorry", so I needed to make sure to exclude that from my changes

SELECT SongTitle
FROM Taylor_Swift_Spotify
WHERE SongTitle LIKE '%Youre Not Sorry%'

SELECT SongTitle
FROM Taylor_Swift_Spotify
WHERE SongTitle LIKE '%Not Sorry%' 
AND SongTitle NOT LIKE '%Back To December/Apologize%'

UPDATE Taylor_Swift_Spotify 
SET SongTitle = 'Youre Not Sorry'
WHERE SongTitle LIKE '%Not Sorry%' 
AND SongTitle NOT LIKE '%Back To December/Apologize%'

SELECT DISTINCT SongTitle
FROM Taylor_Swift_Spotify
GROUP BY SongTitle

------------------------------------------------------------------------------------
--Checking that there aren't any similar issues with the Album names. Luckily, there weren't any issues there!

SELECT DISTINCT Album
FROM Taylor_Swift_Spotify

SELECT *
FROM Taylor_Swift_Spotify

------------------------------------------------------------------------------------

--Finally, I'm going to double-check the ranges on the columns that include ratings.
-- Acousticness - A confidence measure from 0.0 to 1.0 of whether the track is acoustic.
-- Danceability - Danceability describes how suitable a track is for dancing. A value of 0.0 is least danceable and 1.0 is most danceable.
-- Energy - Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.
-- Instrumentalness - Predicts whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0.
-- Liveness - Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live.
-- AvgDecibels - The overall loudness of a track in decibels (dB). Values typically range between -60 and 0 db.
-- Speechiness - Detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks.
-- Tempo - The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration.
-- Valence - A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
-- CurrentPopularity - the popularity of the song from 0 to 100.

SELECT
	MAX(Acousticness)
    AS max_value,
    MIN(Acousticness)
    AS min_value
FROM Taylor_Swift_Spotify

SELECT
	MAX(Danceability)
    AS max_value,
    MIN(Danceability)
    AS min_value
FROM Taylor_Swift_Spotify

SELECT 
	MAX(Energy)
    AS max_value,
    MIN(Energy)
    AS min_value
FROM Taylor_Swift_Spotify

SELECT 
	MAX(Instrumentalness)
    AS max_value,
    MIN(Instrumentalness)
    AS min_value
FROM Taylor_Swift_Spotify

SELECT 
	MAX(Liveness)
    AS max_value,
    MIN(Liveness)
    AS min_value
FROM Taylor_Swift_Spotify

SELECT 
	MAX(AvgDecibels)
    AS max_value,
    MIN(AvgDecibels)
    AS min_value
FROM Taylor_Swift_Spotify

SELECT 
	MAX(Speechiness)
    AS max_value,
    MIN(Speechiness)
    AS min_value
FROM Taylor_Swift_Spotify

SELECT 
	MAX(Valence)
    AS max_value,
    MIN(Valence)
    AS min_value
FROM Taylor_Swift_Spotify

SELECT 
	MAX(CurrentPopularity)
    AS max_value,
    MIN(CurrentPopularity)
    AS min_value
FROM Taylor_Swift_Spotify

