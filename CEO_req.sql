Select * from dbo.catalogue_data
Select * from dbo.consumption_data
Select * from dbo.subscription_data
Select * from dbo.rating_data


-- Content Live for 6 months atleast and rated by users atleast 300 times and Avg_completion_rate of <30%

WITH Content_live_6m
AS(
SELECT A.content_id,A.date_added,A.title,
--DATEDIFF(MONTH,A.date_added,'1/1/2022')  AS MONTH_
DATEDIFF(DAY,A.date_added,'1/1/2022') AS DAYS_LIVE
FROM catalogue_data AS A
WHERE A.status = 'LIVE'
AND DATEDIFF(MONTH,A.date_added,'1/1/2022') >= 6),

Content_Rated_300r
AS
(SELECT B.content_id, COUNT(*) AS CNT_RATINGS 
FROM rating_data AS A
INNER JOIN consumption_data AS B
ON A.usersessionid = B.usersessionid
WHERE A.rating NOT IN ('NOT_RATED','DISMISSED')
GROUP BY B.content_id
HAVING COUNT(*) >= 300),

Content_Rating
AS
(SELECT B.content_id,
CAST(ROUND(AVG(CASE 
    WHEN rating = 'TERRIBLE' THEN 1.0
	WHEN rating = 'BAD' THEN 2.0
	WHEN rating = 'Good' THEN 3.0
	WHEN rating = 'AWESOME' THEN 4.0
	ELSE NULL
	END),2) AS FLOAT) AS AVG_Rating
FROM rating_data AS A
INNER JOIN consumption_data AS B
ON A.usersessionid = B.usersessionid
GROUP BY B.content_id),

Completion_Rate
AS
(SELECT A.content_id, ROUND((SUM(A.user_duration)/SUM(A.content_duration))*100,2) AS Completion_rate
FROM consumption_data AS A
GROUP BY A.content_id),

Views_day
AS
(SELECT A.content_id,COUNT(DISTINCT A.userid) AS Total_views FROM consumption_data AS A
  GROUP BY A.content_id)

--Final Output
SELECT A.content_id,
A.title,
DAYS_LIVE
AVG_Rating,
Completion_rate,
Total_views/DAYS_LIVE AS VIEWS_PER_DAY
FROM Content_live_6m  AS A
JOIN Content_rated_300r AS B ON A.content_id = B.content_id
JOIN Content_Rating AS C ON A.content_id = C.content_id
JOIN Completion_Rate AS D ON A.content_id = D.content_id
JOIN Views_day as E ON A.content_id = E.content_id


--OTHER Requirements
--1. What is the total duration of content we have in our library?
Select CONCAT(SUM(CAST(SUBSTRING(A.duration,1,Charindex(' ',A.duration)-1) as INT)),' ','mins') as DURATION_IN_HOURS 
From dbo.catalogue_data as A

--2. Which is our most sold subscription length (months)?
Select Top 3
DATEDIFF(Month,A.subscription_start_date,A.subscription_end_date) as SUB_LEN,
COUNT(A.subscription_key) as SUB_COUNT
From dbo.subscription_data as A
Group by DATEDIFF(Month,A.subscription_start_date,A.subscription_end_date)
Order by SUB_COUNT DESC

--3. Find out which day of the week did we sell the most
Select 
DATENAME(WEEKDAY,A.subscription_created_date) as WEEK_DAY,
COUNT(A.subscription_key) as SUB_SOLD
From dbo.subscription_data as A
Group By 
DATENAME(WEEKDAY,A.subscription_created_date)
Order By SUB_SOLD DESC

--4. Find out which content got the most number of same day views 
--(same day as the content was added to our platform)
Select Top 10 B.title, COUNT (distinct A.userid) as SAME_DAY_VIEWS
From dbo.consumption_data as A
inner join dbo.catalogue_data as B
on A.content_id = B.content_id
where A.consumption_date = B.date_added
Group by B.title
Order by SAME_DAY_VIEWS DESC

--5. Find out which content got the most number of views 
--within 1 week of adding it on our platform
Select Top 10 B.title, COUNT (distinct A.userid) as SAME_WEEK_VIEWS
From dbo.consumption_data as A
inner join dbo.catalogue_data as B
on A.content_id = B.content_id
where A.consumption_date between B.date_added and DATEADD(Day,7,B.date_added)
Group by B.title
Order by SAME_WEEK_VIEWS DESC

--6. Find out which content is bringing in the most number of users to our platform.
Select Top 10 A.title, COUNT(B.userid) as USER_CNT
From dbo.catalogue_data as A
inner join dbo.consumption_data as B
on A.content_id = B.content_id
inner join dbo.subscription_data as C
on B.userid = C.user_id
where B.consumption_date = C.subscription_created_date
Group by A.title
Order by USER_CNT DESC

--7.Find the average days taken for the users
--to watch their second content on our platform.
SELECT AVG(T2.DAYS_DIFF) AS AVG_DAYS_FOR_2ND_WATCH FROM(

    SELECT *,
    DATEDIFF(DAY,T1.lAG_CONSUMPTION_DATE,T1.consumption_date) AS DAYS_DIFF
    FROM(
    
                SELECT *,
                LAG(T.consumption_date,1) OVER(PARTITION BY USERID ORDER BY CONSUMPTION_DATE ASC ) AS lAG_CONSUMPTION_DATE
                FROM(
                           SELECT A.userid,A.consumption_date,
                           ROW_NUMBER() OVER(PARTITION by USERID ORDER BY CONSUMPTION_DATE ASC) AS Rank_
                           FROM consumption_data AS A
                           ) AS T
                WHERE T.Rank_ <=2
                ) AS T1
          ) AS T2