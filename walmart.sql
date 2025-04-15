
# intial check
SELECT *
FROM walmart_clean_data
LIMIT 5;





#--Business Problem:

#--Q.1 find different payment method and number of transactions,number of qty sold 

SELECT payment_method ,
COUNT(*) AS no_of_payments ,
SUM(quantity) AS num_of_qty_sold 
FROM walmart_clean_data
GROUP BY payment_method
ORDER BY no_of_payments DESC;

#--Q.2 identify the highest-rated category in each branch, displaying the branch, category
#--AVG rating

SELECT*
FROM
(
SELECT
Branch,
category,
AVG(rating) AS avg_rating,
RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS Rating
FROM walmart_clean_data 
GROUP BY Branch, category
) AS ranking

WHERE Rating = 1;


#--Q.3 identify the busiest day for each branch based on the number of transaction

SELECT *
FROM
(SELECT Branch,
DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
COUNT(*) total_no_transactions,
RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as first
FROM walmart_clean_data
GROUP BY Branch, day_name) as joloff
where first = 1;



##--Q.4 calculate the total quantity of items sold per payment method. list payment_method and total_quantity

SELECT payment_method,
SUM(quantity) total_qty_sold 
FROM walmart_clean_data
GROUP BY payment_method
ORDER BY total_qty_sold DESC;


##--Q.5 determine the avg, min, max rating of category for each city.
##--list the city, averge_rating, min_rating, max_rating.



SELECT City, 
category,
AVG(rating) avg_rating,
MIN(rating) min_rating,
MAX(rating) max_rating
FROM walmart_clean_data
GROUP BY City, category;


##--Q-6 calculate the total profit  for each category by considering total profit as
##(unit_price * quantity * profit_margin)

SELECT category,
SUM(Total_Price) as total_revenue,
SUM(Total_Price * profit_margin) as profit
FROM walmart_clean_data
GROUP BY category
ORDER BY  total_revenue DESC;

##--Q7
##-- dtermine the most common payment method for each branch
##-- display branch and the preferred_payment_method


WITH cte
AS
(SELECT Branch,
payment_method,
COUNT(*) as total_payment_method,
RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as standing
FROM walmart_clean_data
GROUP BY Branch, 
payment_method)

SELECT *
FROM cte
WHERE standing = 1;



## Q-8 categorize sales  into 3 groups MORNING, AFTERNOON,  EVENING
## find out each of the shift and number of invoices



SELECT 
  Branch,
  CASE 
    WHEN HOUR(time) >= 5 AND HOUR(time) < 12 THEN 'Morning'
    WHEN HOUR(time) >= 12 AND HOUR(time) < 17 THEN 'Afternoon'
    WHEN HOUR(time) >= 17 AND HOUR(time) < 21 THEN 'Evening'
    ELSE 'Night'
  END AS time_of_day,
  COUNT(*) sale_count
FROM walmart_clean_data
GROUP BY Branch, time_of_day
ORDER BY Branch, sale_count DESC; 




-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(Total_Price) AS revenue
    FROM walmart_clean_data
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(Total_Price) AS revenue
    FROM walmart_clean_data
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;




