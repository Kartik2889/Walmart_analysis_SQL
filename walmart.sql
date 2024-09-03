-- ------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------Walmart Data Analysis-------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------

create database walmart;
use walmart;
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

select * from sales limit 5;

-- ----------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------- Feature Engineering------------------------------------------------------- 
-- ----------------------------------------------------------------------------------------------------------------------------------

-- Adding new column time_of_day (to give insight of sales in the Morning, Afternoon and Evening) 

alter table sales add time_of_day varchar(15);
update sales set time_of_day = 
(case 	when time between '00:00:00' and '12:00:00' then 'Morning'
		when time between '12:01:00' and '16:00:00' then 'Afternoon'
 else 'Evening' 
 End);

-- Adding a new column named day_name that contains the extracted days of the week (Mon, Tue, Wed,...)
 
alter table sales add column day_name varchar(10);
update sales set day_name = date_format(`date`, '%W');

-- Adding a new column named month_name (jan, feb, march,....)

alter table sales add column month_date varchar(10);
update sales set month_date = date_format(`date`, '%M');


-- -----------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------Generic Questions------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------

-- How many unique cities does the data have?

select distinct city from sales;

-- In which city is each branch?

select distinct city, branch from sales;

 -- ----------------------------------------------------------------------------------------------------------------------------------
 -- -------------------------------------------------------Product Related Queries----------------------------------------------------
 -- ----------------------------------------------------------------------------------------------------------------------------------

-- How many unique product lines does the data have?

select count(distinct product_line) as total_product_lines from sales;

-- What is the most common payment method?

select payment, count(payment) as most_used_payment_type from sales group by payment order by most_used_payment_type desc; 

-- What is the most selling product line?

select product_line, count(product_line) as most_selling_product_line from sales group by product_line order by most_selling_product_line desc;

-- What is the total revenue by month?

select month_date, sum(total) as total_revenue from sales group by month_date order by total_revenue desc ; 


-- Which branch sold more products than average product sold?

select branch,sum(quantity) as above_average from sales group by branch having above_average > (select sum(quantity)/3 from sales); 

-- What is the most common product line by gender?

 select gender, product_line, count(product_line) as most_common from sales group by gender, product_line order by most_common desc;

-- What is the average rating of each product line?

select product_line, avg(rating) as avg_rating from sales group by product_line;

-- ------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------Sales Queries------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday

select time_of_day, count(invoice_id) sales_count from sales where day_name not in ('Saturday', 'Sunday') group by time_of_day order by sales_count desc;

-- Which of the customer types brings the most revenue?

select customer_type, sum(total) as most_revenue from sales group by customer_type order by most_revenue desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

alter table sales change tax_pct VAT float;
select city,sum(VAT) as largest_vat_payer from sales group by city order by largest_vat_payer desc;  

-- Which customer type pays the most in VAT?

select customer_type, sum(Vat) as most_VAT_payer from sales group by customer_type order by most_VAT_payer desc;

-- -----------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------Customer Related Queries--------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------

-- Which customer type buys the most?

select customer_type, count(customer_type) as most_frequent from sales group by customer_type order by most_frequent desc;

-- What is the gender of most of the customers?

select gender, count(gender) as gender_count from sales group by gender order by gender_count desc;

-- What is the gender distribution per branch?
SELECT 
    branch, 
    gender, 
    COUNT(gender) AS gender_count,
    (COUNT(gender) * 100.0) / SUM(COUNT(gender)) OVER (PARTITION BY branch) AS gender_percentage
FROM 
    sales
GROUP BY 
    branch, gender
ORDER BY 
    branch ASC;

