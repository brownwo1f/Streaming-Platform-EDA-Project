Select * from [dbo].[subscription_data] 

--1. Total Subscriptions
Select COUNT(A.subscription_key) as Total_Subscriptions from [dbo].[subscription_data] as A

--2. Total Revenue from Subscriptions
Select FORMAT(SUM(A.amount_paid),'N2') as Total_Revenue_from_Subscriptions  from [dbo].[subscription_data] as A

--3. Average Revenue per Subscription
Select FORMAT(AVG(a.amount_paid),'N2') from dbo.subscription_data as A

--4. Subscriptions percentage by plan type
Select A.plan_type, FORMAT(CAST(COUNT(*) as float) * 100 /(Select COUNT(*) from dbo.subscription_data as A),'N2') as SUB_PERC_PLAN_TYPE from dbo.subscription_data as A
where A.plan_type is not null
group by A.plan_type

--5. Subscriptions percentage by plan duration
Select 
DATEDIFF(MONTH,A.subscription_start_date,A.subscription_end_date) as DURATION_MONTHS, 
ROUND(CAST(COUNT(*) as float) *100 /(Select COUNT(*) from dbo.subscription_data as A),2) as SUB_PERC_PLAN_DUR
From dbo.subscription_data as A 
Where DATEDIFF(MONTH,A.subscription_start_date,A.subscription_end_date) > 0
Group by DATEDIFF(MONTH,A.subscription_start_date,A.subscription_end_date)
Order by SUB_PERC_PLAN_DUR DESC

--6. Calculate the total revenue generated per month
Select 
DATENAME(Month,A.subscription_created_date) as Month_,
FORMAT(SUM(A.amount_paid),'N2') as REVENUE_GEN
From dbo.subscription_data as A
Group by DATENAME(Month,A.subscription_created_date)
Order BY REVENUE_GEN

--7. Monthly New Subscriptions
Select  
DATENAME(Month, A.subscription_created_date) as Month_,
FORMAT(Count(A.subscription_key),'N2') as NEW_SUBS
From dbo.subscription_data as A
Group by DATENAME(Month,A.subscription_created_date)
Order BY NEW_SUBS

--H.W. Monthly new users who have taken a subscription.
Select COUNT(A.user_id) From dbo.subscription_data as A
Select DISTINCT COUNT(A.user_id) From dbo.subscription_data as A

/*Observing above query output it is clear that users are not purchasing new subscriptions 
after their subscription got expired as there is no instance of repeating user Id in the table
hence finding new users who have taken a subscription is not possible with current data*/

--8. Understanding when users are purchasing
Select
Case
	When HOUR_ >= 0 AND HOUR_ < 4 THEN 'Early Morning 12 AM to 4 AM'
	When HOUR_ >= 4 AND HOUR_ < 8 THEN 'Morning 4 AM to 8 AM'
	When HOUR_ >= 8 AND HOUR_ < 12 THEN 'Late Morning 8 AM to 12 PM'
	When HOUR_ >= 12 AND HOUR_ < 16 THEN  'Afternoon 12 PM to 4 PM'
	When HOUR_ >= 16 AND HOUR_ < 20 THEN  'Evening 4 PM to 8 PM'
	When HOUR_ >= 20 THEN 'Night 8 PM onwards'
End as TIME_PERIOD,
Count(*) as PURCHASE_DIST
From(
             SELECT *,DATEPART(HOUR,A.subscription_created_time) AS HOUR_
             FROM subscription_data AS A
			 ) AS T
Group by 
         Case
			When HOUR_ >= 0 AND HOUR_ < 4 THEN 'Early Morning 12 AM to 4 AM'
			When HOUR_ >= 4 AND HOUR_ < 8 THEN 'Morning 4 AM to 8 AM'
			When HOUR_ >= 8 AND HOUR_ < 12 THEN 'Late Morning 8 AM to 12 PM'
			When HOUR_ >= 12 AND HOUR_ < 16 THEN 'Afternoon 12 PM to 4 PM'
			When HOUR_ >= 16 AND HOUR_ < 20 THEN 'Evening 4 PM to 8 PM'
			When HOUR_ >= 20 THEN 'Night 8 PM onwards'
		End
ORDER BY PURCHASE_DIST DESC
