--Data Cleaning - Critical Role's Dungeons and Dragons 'Mighty Nein' Campaign Roll Data

-- Table Key:

-- Episode - The episode number formatted as C2E001 for Campaign 2 Episode 1. Ranges from 1 to 141
-- Time - Time stamp within the episode formatted in H:MM:SS
-- Character - The fictional dungeons and dragons character that is making the roll
-- Type of Roll - The specific type of D&D roll being made. There are 51 different types of rolls.
-- Total Value - The total value of the roll. This includes any 'modifiers' or 'bonuses' that the character adds to their dice roll.

-------------------------------------------------------------------------------------------------

-- Data Standardization

-- First I'm looking at the Type of Roll column to check for any incorrect spellings of the same type of roll. Knowing the rules of Dungeons & Dragons, there are many different types of dice rolls the players make, however the query below shows 64 different types of rolls. That number is a bit high, so I'm going to examine them to see if there are any instances where a type of roll is listed more than once but spelled differently.
-- I'm including a count in order to see which version has the most instances so I can update it to the most popular version.

SELECT allepisodes.[Type of Roll],COUNT(allepisodes.[Type of Roll]) AS TotalRolls
FROM AllEpisodes
GROUP BY allepisodes.[Type of Roll]
ORDER BY allepisodes.[Type of Roll]

-- I found quite a few instances of this happening, so below I'm using select then update to fix these:

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Alchemist Kit','Alchemist Tools','Alchemy Kit')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Alchemy Kit'
WHERE allepisodes.[Type of Roll] IN ('Alchemist Kit','Alchemist Tools','Alchemy Kit')

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Constitution Save','Consitution Save')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Constitution Save'
WHERE allepisodes.[Type of Roll] = 'Consitution Save'

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Inevstigation','Investigation')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Investigation'
WHERE allepisodes.[Type of Roll] = 'Inevstigation'

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Forgery','Forgery Kit','Forgery Tools')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Forgery Kit'
WHERE allepisodes.[Type of Roll] IN ('Forgery','Forgery Tools')

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Hit Dice','Hit Points')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Hit Dice'
WHERE allepisodes.[Type of Roll] IN ('Hit Points')

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Stealth','Steath')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Stealth'
WHERE allepisodes.[Type of Roll] IN ('Steath')

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('d100','Percentage')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'd100'
WHERE allepisodes.[Type of Roll] IN ('Percentage')


-- There were  types called "Other", "Basic check", "Check", "unknown"...in these cases there wasnt a specific type associated, but game master had the character roll.
-- I wanted to see if all of these rolls were made using the D20, so I used the query below to find the highest roll total and the total number of rolls made.

SELECT allepisodes.[Type of Roll],MAX(allepisodes.[Total Value]) as HighestRollTotal,COUNT(allepisodes.[Type of Roll]) AS TotalRolls
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('d20','Basic Check','Check','Flat Roll','Fragment','Other','Unknown')
GROUP BY allepisodes.[Type of Roll]
ORDER BY allepisodes.[Type of Roll]

-- I found that the "Other" had a max roll of 99, which would not be from a D20 roll, so I'm examining that further. After spot checking a few instances, I found that those rolls should be categorized as "Unknown".

SELECT allepisodes.[Type of Roll], allepisodes.[Total Value], Time, Episode
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] = 'Other'
ORDER BY allepisodes.[Total Value] DESC

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Other')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Unknown'
WHERE allepisodes.[Type of Roll] IN ('Other')

-- Now I will merge the rest of those into one type that I will call "Basic D20 Roll"

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('d20','Basic Check','Check','Flat Roll','Fragment')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Basic D20 Roll'
WHERE allepisodes.[Type of Roll] IN ('d20','Basic Check','Check','Flat Roll','Fragment')

UPDATE AllEpisodes
SET allepisodes.[Type of Roll] = 'Basic D20 Roll'
WHERE allepisodes.[Type of Roll] IN ('Encounter')

-- Below I am quickly checking the remaining types and their max/min roll value to make sure they all make sense. For instance, Damage rolls use lots of different dice, so the total value can be a lot...but skill checks and saves use only a D20, so there are more limitations. I want to make sure these types all have the expected range now.

SELECT allepisodes.[Type of Roll],MAX(allepisodes.[Total Value]) as HighestRollTotal,MIN(allepisodes.[Total Value]) as LowestRollTotal
FROM AllEpisodes
GROUP BY allepisodes.[Type of Roll]
ORDER BY HighestRollTotal DESC

 -------------------------------------------------------------------------------------------------

 -- Now that I esnured there weren't any duplicate types, I want to create a new column to make it easier to categorize these types.
 -- From my knowledge of D&D, I am categorizing the rolls in five groups: Ability Checks, Saving Throws, Attack Rolls, Damage Rolls, Utility Rolls (Healing, Control, Reactions, D100)

SELECT allepisodes.[Type of Roll],COUNT(allepisodes.[Type of Roll]) AS TotalRolls
FROM AllEpisodes
GROUP BY allepisodes.[Type of Roll]
ORDER BY allepisodes.[Type of Roll]

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Acrobatics','Alchemy Kit','Animal Handling','Arcana','Athletics','Basic D20 Roll','Charisma','Constitution','Deception','Dexterity','Disguise Kit','Forgery Kit','History','Initiative','Insight','Intelligence','Intimidation','Investigation','Medicine','Nature','Perception','Performance','Persuasion','Religion','Sleight of Hand','Stealth','Strength','Survival','Unknown','Wisdom')

ALTER TABLE AllEpisodes
ADD Category nvarchar(255)

UPDATE AllEpisodes
SET Category = 'Ability Check'
WHERE allepisodes.[Type of Roll] IN ('Acrobatics','Alchemy Kit','Animal Handling','Arcana','Athletics','Basic D20 Roll','Charisma','Constitution','Deception','Dexterity','Disguise Kit','Forgery Kit','History','Initiative','Insight','Intelligence','Intimidation','Investigation','Medicine','Nature','Perception','Performance','Persuasion','Religion','Sleight of Hand','Stealth','Strength','Survival','Unknown','Wisdom')

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] LIKE '%Thieves%' 

UPDATE AllEpisodes
SET Category = 'Ability Check'
WHERE allepisodes.[Type of Roll] LIKE '%Thieves%' 

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] LIKE '%Tinker%' 

UPDATE AllEpisodes
SET Category = 'Ability Check'
WHERE allepisodes.[Type of Roll] LIKE '%Tinker%' 

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Attack','Spell Attack')

UPDATE AllEpisodes
SET Category = 'Attack Roll'
WHERE allepisodes.[Type of Roll] IN ('Attack','Spell Attack')

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Damage')

UPDATE AllEpisodes
SET Category = 'Damage Roll'
WHERE allepisodes.[Type of Roll] IN ('Damage')

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Charisma Save','Constitution Save','Death Save','Dexterity Save','Intelligence Save','Strength Save','Wisdom Save')

UPDATE AllEpisodes
SET Category = 'Saving Throw'
WHERE allepisodes.[Type of Roll] IN ('Charisma Save','Constitution Save','Death Save','Dexterity Save','Intelligence Save','Strength Save','Wisdom Save')

SELECT allepisodes.[Type of Roll]
FROM AllEpisodes
WHERE allepisodes.[Type of Roll] IN ('Blink','Counterspell','d100','Deflect Missiles','Divine Intervention','Guidance','Healing','Hit Dice','Mirror Image')

UPDATE AllEpisodes
SET Category = 'Utility Roll'
WHERE allepisodes.[Type of Roll] IN ('Blink','Counterspell','d100','Deflect Missiles','Divine Intervention','Guidance','Healing','Hit Dice','Mirror Image')

-- Double checking that I have categorized all types of rolls:

SELECT Category,COUNT(allepisodes.[Type of Roll])
FROM AllEpisodes
GROUP BY Category

 -------------------------------------------------------------------------------------------------

 -- Checking standardization of Episodes
 -- Episodes 20 - 28, 40 - 43, and 63 were entered in a very different format.  Updating this below using a case statement

SELECT Episode, COUNT(Episode) as #ofRollsInEpisode
FROM AllEpisodes
GROUP BY Episode
ORDER BY Episode

UPDATE AllEpisodes
SET Episode =
	CASE
	WHEN Episode = '2-20' THEN 'C2E020'
	WHEN Episode = '2-21' THEN 'C2E021'
	WHEN Episode = '2-22' THEN 'C2E022'
	WHEN Episode = '2-23' THEN 'C2E023'
	WHEN Episode = '2-24' THEN 'C2E024'
	WHEN Episode = '2-25' THEN 'C2E025'
	WHEN Episode = '2-26' THEN 'C2E026'
	WHEN Episode = '2-27' THEN 'C2E027'
	WHEN Episode = '2-28' THEN 'C2E028'
	WHEN Episode = 'C2E40' THEN 'C2E040'
	WHEN Episode = 'C2E41' THEN 'C2E041'
	WHEN Episode = 'C2E42' THEN 'C2E042'
	WHEN Episode = 'C2E43' THEN 'C2E043'
	WHEN Episode = 'C2E63' THEN 'C2E063'
	ELSE Episode
	END


 -------------------------------------------------------------------------------------------------
 -- Since we will be analyzing the dice rolls made by the main cast members, I want to remove any rows that are referring to NPCs or Guest Stars.
 -- This query is checking to see what other characters are listed and how many instances they show up in the data. I'm cross-checking to ensure there aren't any misspellings that we actually need to keep.

SELECT Character, COUNT(Character)
FROM AllEpisodes
WHERE Character NOT IN ('Beau','Fjord','Jester','Nott','Caleb','Yasha','Caduceus','Veth','Molly')
GROUP BY Character

-- I did find one character called "Travis", which I know is the name of the player who plays the character "Fjord". I like to double check that I am selecting the correct data with a select statement, then I'm using Update to make the correction:

SELECT Character
FROM AllEpisodes
WHERE Character = 'Travis'

UPDATE AllEpisodes
SET Character = 'Fjord'
WHERE Character = 'Travis'

-- Now I am going to remove the rows that have rolls by characters other than our main cast.
-- Again, I will check that I'm selecting the correct data first, then use a delete statement with the condition where the character is not one of our main characters:

SELECT Character
FROM AllEpisodes
WHERE Character NOT IN ('Beau','Fjord','Jester','Nott','Caleb','Yasha','Caduceus','Veth','Molly')
ORDER BY Character

DELETE FROM AllEpisodes
WHERE Character NOT IN ('Beau','Fjord','Jester','Nott','Caleb','Yasha','Caduceus','Veth','Molly')

-- This removed 609 rows of extra data that we just don't need for what we want to do.

-------------------------------------------------------------------------------------------------

--Checking for nulls

SELECT *
FROM AllEpisodes
WHERE [Total Value] is null
ORDER BY Episode

-- Many rows came up with nulls in the Total Value, but I could also see a few duplicate rows in the data, so it is possible that the roll total is in a different row.
-- The roll matches up to a time stamp and episode, so I'm going to use a self-join to populate the Total Value based on the episode and time stamp if the roll is blank

SELECT a.Episode, b.Episode, a.Time, b.Time, a.[Total Value], b.[Total Value], ISNULL(a.[Total Value], b.[Total Value])
FROM AllEpisodes as a
JOIN AllEpisodes as b
	ON a.Episode = b.Episode
	AND a.Time = b.Time
WHERE a.[Total Value] is null
ORDER BY a.Time

UPDATE a
SET [Total Value] = ISNULL(a.[Total Value], b.[Total Value])
FROM AllEpisodes as a
JOIN AllEpisodes as b
	ON a.Episode = b.Episode
	AND a.Time = b.Time
WHERE a.[Total Value] is null

SELECT *
FROM AllEpisodes
Where [Total Value] is null

--There are still 427 rows left with a Null value in the "Total Value", but I am choosing to keep them so that I can still analyze the count for certain columns.

-------------------------------------------------------------------------------------------------

--Now I would like to remove any duplicates, so I'm using a CTE to see if any rows have the same data

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() over (
	PARTITION BY Episode,
				 Time,
				 Character,
				 [Type of Roll],
				 [Total Value],
				 CharacterID,
				 Category
				 ORDER BY Time) as row_num
FROM AllEpisodes)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

-- Lastly, I'm going to add a column for the player since a few characters are played by the same player and it might be interesting to analyze by player.

SELECT Character, COUNT(Character)
FROM AllEpisodes
GROUP BY Character
ORDER BY Character

SELECT Character,
CASE
	WHEN Character = 'Beau' THEN 'Marisha'
	WHEN Character = 'Fjord' THEN 'Travis'
	WHEN Character = 'Jester' THEN 'Laura'
	WHEN Character = 'Nott' THEN 'Sam'
	WHEN Character = 'Caleb' THEN 'Liam'
	WHEN Character = 'Yasha' THEN 'Ashley'
	WHEN Character = 'Caduceus' THEN 'Taliesin'
	WHEN Character = 'Veth' THEN 'Sam'
	WHEN Character = 'Molly' THEN 'Taliesin'
ELSE '' 
	END as player
FROM AllEpisodes

ALTER TABLE AllEpisodes
ADD Player nvarchar(255)

UPDATE AllEpisodes
SET Player =
	CASE
	WHEN Character = 'Beau' THEN 'Marisha'
	WHEN Character = 'Fjord' THEN 'Travis'
	WHEN Character = 'Jester' THEN 'Laura'
	WHEN Character = 'Nott' THEN 'Sam'
	WHEN Character = 'Caleb' THEN 'Liam'
	WHEN Character = 'Yasha' THEN 'Ashley'
	WHEN Character = 'Caduceus' THEN 'Taliesin'
	WHEN Character = 'Veth' THEN 'Sam'
	WHEN Character = 'Molly' THEN 'Taliesin'
ELSE '' 
	END

SELECT *
FROM AllEpisodes
ORDER BY Episode
