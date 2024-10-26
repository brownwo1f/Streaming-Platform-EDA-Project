Select * from dbo.catalogue_data
Select * from dbo.consumption_data
Select * from dbo.subscription_data


--1. Total content
Select COUNT(A.content_id) as TOTAL_CONTENT from dbo.catalogue_data as A
where A.status = 'Live'

--2. Total content split by paid & free
Select A.accesslevel, 
COUNT(A.content_id) as TOTAL_CONTENT, 
ROUND(CAST(COUNT(A.content_id)as float) * 100/(Select COUNT(A.content_id) from dbo.catalogue_data as A),2)
From dbo.catalogue_data as A
Where A.status = 'Live'
Group by A.accesslevel

--3. Total content split by status
Select A.status, 
COUNT(A.content_id) as TOTAL_CONTENT, 
ROUND(CAST(COUNT(A.content_id)as float) * 100/(Select COUNT(A.content_id) from dbo.catalogue_data as A),2)
From dbo.catalogue_data as A
Group by A.status
Order by TOTAL_CONTENT DESC

--4. Month of month content added to the paltform
Select Distinct DATENAME(MONTH, A.date_added) as Month_ ,
Count(*) as CONTENT_ADDED
From dbo.catalogue_data as A
Group by DATENAME(MONTH, A.date_added)
Order by CONTENT_ADDED DESC

--5. Compare MoM count of Indian content added to the platform vs other content added
Select Distinct 
DATEPART(MONTH, A.date_added) as Month_Num,
DATENAME(MONTH, A.date_added) as Month_ ,
Count(Case When A.country = 'India' then A.content_id end ) as IND_CONTENT,
Count(Case When A.country != 'India' and A.country is not null then A.content_id end ) as OTH_CONTENT,
Count(Case When A.country is null then A.content_id end ) as NULL_COUNTRY
From dbo.catalogue_data as A
Group by DATEPART(MONTH, A.date_added), DATENAME(MONTH, A.date_added)
Order by DATEPART(MONTH, A.date_added)

--6. Average duration of content
Select 
CONCAT(AVG(CAST(SUBSTRING(A.duration,1,Charindex(' ',A.duration)-1) as INT)),' ','mins') as AVG_CON_DURATION
From dbo.catalogue_data as A

--7. Which content is pulling in the most number of users?
Select Top 10 A.title, COUNT(C.user_id) as NEW_CUST_ADDED
From dbo.catalogue_data as A
inner join dbo.consumption_data as B
on A.content_id = B.content_id
inner join dbo.subscription_data as C
on B.userid = B.userid
where B.consumption_date = C.subscription_created_date and B.consumption_date = A.date_added
Group by A.title
Order by NEW_CUST_ADDED DESC

--EXTRA. Total content split by rating
Select A.rating, 
COUNT(A.content_id) as TOTAL_CONTENT, 
ROUND(CAST(COUNT(A.content_id)as float) * 100/(Select COUNT(A.content_id) from dbo.catalogue_data as A),2) as PERC_DIST
From dbo.catalogue_data as A
Group by A.rating
Order by TOTAL_CONTENT DESC
