-- HR Data Exploration - Recruiting

-- This HR Dataset has 35 columns of employee data such as demographic info, hire info, recruiting, and performance/engagement.
-- The goal for this data exploration project is to extract insights on the company's quality of hiring by looking at the recruiting source and performance/engagement data.
-- Data source is from Kaggle: https://www.kaggle.com/datasets/rhuebner/human-resources-data-set

-- Table Key (Only columns used in this project):

-- EmpID - Employee's Unique ID number
-- Sex - M or F
-- State -	The state that the employee lives in
-- DOB - 	Date of Birth for the employee
-- Department - Name of the department the employee works in
-- RecruitmentSource - The name of the recruitment source where the employee was recruited from
-- PerfScoreID - Performance Score code that matches the employee’s most recent performance score
-- PerformanceScore - Performance Score text/category (Fully Meets, Partially Meets, PIP, Exceeds)
-- EngagementSurvey - 	Results from the last engagement survey
-- DateofHire - Date the employee was hired
-- LastPerformanceReview_Date - Date of last performance review
-- DateofTermination - 	Date the person was terminated
-- TermReason - A text reason / description for why the person was terminated

----------------------------------------------------------------------------------------------------------

-- First I'm taking a look at the columns I will be using to ensure the data is clean and in the correct format.

SELECT EmpID,Sex,State,DOB,Department,RecruitmentSource,PerfScoreID,PerformanceScore,EngagementSurvey,DateofHire,LastPerformanceReview_Date,DateofTermination,TermReason
FROM HRData

-- The date fields are in datetime data type, so I'm going to fix that real quick:

ALTER Table HRData
ALTER COLUMN DOB Date
ALTER Table HRData
ALTER COLUMN DateofHire Date
ALTER Table HRData
ALTER COLUMN LastPerformanceReview_Date Date
ALTER Table HRData
ALTER COLUMN DateofTermination Date

--Ensuring the categorical string fields don't have any misspellings

SELECT Department, COUNT(Department) as NumHires
FROM HRData
GROUP BY Department

SELECT RecruitmentSource, COUNT(RecruitmentSource) as NumHires
FROM HRData
GROUP BY RecruitmentSource

SELECT PerformanceScore, COUNT(PerformanceScore) as NumHires
FROM HRData
GROUP BY PerformanceScore

SELECT TermReason, COUNT(TermReason) as NumHires
FROM HRData
GROUP BY TermReason

--There was a source named 'Online Web Application' and one named 'Website'. In this case I am assuming those are the same, but in a real-life scenario I would clarify before updating.

SELECT RecruitmentSource
FROM HRData
WHERE RecruitmentSource = 'On-line Web application'

UPDATE HRData
SET RecruitmentSource = 'Website'
WHERE RecruitmentSource = 'On-line Web application'

-- The TermReason data is also all over the place, so I will categorize the data further into Involuntary, Voluntary, Still Employed

SELECT TermReason,
CASE 
	WHEN TermReason = 'Another position' 
		OR TermReason = 'career change' 
		OR TermReason = 'maternity leave - did not return'
		OR TermReason = 'medical issues'
		OR TermReason = 'military'
		OR TermReason = 'more money'
		OR TermReason = 'relocation out of area'
		OR TermReason = 'retiring'
		OR TermReason = 'return to school'
		OR TermReason = 'unhappy'
		OR TermReason = 'hours' THEN 'Voluntary'
	WHEN TermReason = 'attendance'
		OR TermReason = 'Fatal attraction'
		OR TermReason = 'gross misconduct'
		OR TermReason = 'no-call, no-show' 
		OR TermReason = 'performance'
		OR TermReason = 'Learned that he is a gangster' THEN 'Involuntary'
	ELSE 'Still Employed'
END as TermType
FROM HRData

ALTER TABLE HRData
ADD TermType nvarchar(255)

UPDATE HRData
SET TermType =
CASE 
	WHEN TermReason = 'Another position' 
		OR TermReason = 'career change' 
		OR TermReason = 'maternity leave - did not return'
		OR TermReason = 'medical issues'
		OR TermReason = 'military'
		OR TermReason = 'more money'
		OR TermReason = 'relocation out of area'
		OR TermReason = 'retiring'
		OR TermReason = 'return to school'
		OR TermReason = 'unhappy'
		OR TermReason = 'hours' THEN 'Voluntary'
	WHEN TermReason = 'attendance'
		OR TermReason = 'Fatal attraction'
		OR TermReason = 'gross misconduct'
		OR TermReason = 'no-call, no-show' 
		OR TermReason = 'performance'
		OR TermReason = 'Learned that he is a gangster' THEN 'Involuntary'
	ELSE 'Still Employed'
END

----------------------------------------------------------------------------------------------------------
-- First, I'm looking at the performance of employees who have been employed for at least 30 days and their recruiting source
-- Adding a column for Employment Duration which counts the amount of days in between the employee's hire date and their last performance review. This will allow me to filter out any new hires who haven't fully onboarded yet.

Select EmpID, DATEDIFF(day,DateofHire,LastPerformanceReview_Date) as EmploymentDuration
FROM HRData

ALTER TABLE HRData
Add EmploymentDuration int

UPDATE HRData
SET EmploymentDuration = DATEDIFF(day,DateofHire,LastPerformanceReview_Date)

-- Pulling the performance & Enagement scores and recruiting source of employees who have been employed at least 30 days

SELECT PerformanceScore,PerfScoreID,EngagementSurvey,RecruitmentSource
FROM HRData
WHERE EmploymentDuration > 30

--Below I'm using aggregate functions to see the average performance score per source. 
--According to this data, Employee's who were hired from an Employee Referral have the highest average performance score at 3.16 out of 4, followed by the Diversity Job Fair and LinkedIn at an average of 3.

SELECT RecruitmentSource,AVG(PerfScoreID) as AveragePerformanceScore
FROM HRData
WHERE EmploymentDuration > 30
GROUP BY RecruitmentSource
ORDER BY AveragePerformanceScore DESC

-- The query below shows that the employees with a source of "other" has the highest Average engagement score at 4.55 / 5, but the other sources are not too far behind ranging from 3.98 - 4.27
--Knowing this, I would want to learn more about the "Other" source. I would inquire with the Recruiting team to find out how that is defined, since something is working well when it comes to employee engagement.

SELECT RecruitmentSource,AVG(EngagementSurvey) as AverageEngagementScore
FROM HRData
WHERE EmploymentDuration > 30
GROUP BY RecruitmentSource
ORDER BY AverageEngagementScore DESC

--Now I'm interested in looking at the scores broken down by gender, department, and tenure

SELECT Department, AVG(EngagementSurvey) as AverageEngagementScore,AVG(PerfScoreID) as AveragePerformanceScore
FROM HRData
WHERE EmploymentDuration > 30
GROUP BY Department
ORDER BY AveragePerformanceScore DESC

SELECT Sex, AVG(EngagementSurvey) as AverageEngagementScore,AVG(PerfScoreID) as AveragePerformanceScore
FROM HRData
WHERE EmploymentDuration > 30
GROUP BY Sex
ORDER BY AveragePerformanceScore DESC

--For Tenure, I needed to add a new column to count the years the employee worked at the company when the performance/engagement scores were recorded.

ALTER TABLE HRData
Add Tenure int

UPDATE HRData
SET Tenure = DATEDIFF(year,DateofHire,LastPerformanceReview_Date)


SELECT Tenure,AVG(EngagementSurvey) as AverageEngagementScore,AVG(PerfScoreID) as AveragePerformanceScore
FROM HRData
WHERE EmploymentDuration > 30
GROUP BY Tenure

--Looking at employees that were terminated involuntarily to see if there is a link to their recruitment source
--Shows that Google Search & Indeed sources are tied for the most related involuntary terminations

SELECT RecruitmentSource,COUNT(RecruitmentSource) as #ofInVoluntaryTerminatedEmp
FROM HRData
WHERE TermType = 'Involuntary'
GROUP BY RecruitmentSource
ORDER BY #ofInVoluntaryTerminatedEmp DESC

-- Now I'm looking at the voluntary terminations
-- Similarly, the Google Search source shows up as the source for most of the voluntary terminations
-- Knowing this, the recruiting team may need to reconsider using Google Search as a sourcing tool

SELECT RecruitmentSource,COUNT(RecruitmentSource) as #ofVoluntaryTerminatedEmp
FROM HRData
WHERE TermType = 'Voluntary'
GROUP BY RecruitmentSource
ORDER BY #ofVoluntaryTerminatedEmp DESC
