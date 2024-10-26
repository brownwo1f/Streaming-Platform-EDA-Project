Select * from dbo.consumption_data

--1. Overall Avg user duration
Select CONCAT(ROUND(AVG(A.user_duration),2),' ','mins') 
From dbo.consumption_data as A

--2. % of content consumption by Platform
Select Distinct 
A.[platform], 
COUNT(A.usersessionid) as PLATFORM_DIST,
ROUND(CAST(COUNT(A.usersessionid)as float) * 100/(Select COUNT(A.usersessionid) from dbo.consumption_data as A),2) as PERC_PLATFORM_DIST
From dbo.consumption_data as A
Group by A.[platform]
Order by PLATFORM_DIST DESC

--2.1. Which platform is used the most to consume the content.
Select Distinct Top 1
A.[platform], 
COUNT(A.usersessionid) as PLATFORM_DIST,
ROUND(CAST(COUNT(A.usersessionid)as float) * 100/(Select COUNT(A.usersessionid) from dbo.consumption_data as A),2) as PERC_PLATFORM_DIST
From dbo.consumption_data as A
Group by A.[platform]
Order by PLATFORM_DIST DESC

--3. Completion Rate per content
Select A.content_id, 
ROUND((SUM(A.user_duration)/SUM(A.content_duration))*100,2) AS AVG_Completion_rate
From consumption_data as A
Group by A.content_id
Order by AVG_Completion_rate DESC

--4. Which content is being watched the most.
Select A.content_id, 
COUNT(A.consumption_date) as TIMES_PLAYED,
ROUND((SUM(A.user_duration)/SUM(A.content_duration))*100,2) AS AVG_Completion_rate
From dbo.consumption_data as A
Group by A.content_id
Order by TIMES_PLAYED DESC

--5. Whether users are taking the subscription to watch a particular content.
-- same as task 3 Q7.
Select Top 10 A.title, COUNT(C.subscription_key) as NEW_CUST_ADDED
From dbo.catalogue_data as A
right join dbo.consumption_data as B
on A.content_id = B.content_id
right join dbo.subscription_data as C
on B.userid = C.user_id
where B.consumption_date = C.subscription_created_date and B.consumption_date = A.date_added
Group by A.title
Order by NEW_CUST_ADDED DESC
