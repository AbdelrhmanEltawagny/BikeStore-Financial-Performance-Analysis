--Quantity sold and total revenue for each brand 
SELECT b.brand_name , SUM(i.quantity) quantity_sold , SUM(i.list_price) as total_revenue 
from production.brands b join production.products p on b.brand_id = p.brand_id 
join sales.order_items i on p.product_id = i.product_id 
Group by b.brand_name 
order by  total_revenue desc  , quantity_sold

--Brands and Categories
SELECT b.brand_name , c.category_name , SUM(i.quantity) quantity_sold 
from production.products p join sales.order_items i on p.product_id = i.product_id 
join production.categories c on c.category_id = p.category_id 
join production.brands b on b.brand_id = p.brand_id
Group by b.brand_name , c.category_name
order by b.brand_name asc , quantity_sold desc

--Stock quantity
SELECT b.brand_name , c.category_name, SUM(s.quantity) as stock_quantity, SUM(o.quantity) as quantity_sold , Sum(s.quantity) + Sum(o.quantity) as total_quantity
FROM production.categories c
INNER JOIN production.products p ON c.category_id = p.category_id
INNER JOIN production.brands b ON p.brand_id = b.brand_id
LEFT JOIN (
  SELECT product_id, SUM(quantity) as quantity
  FROM production.stocks
  GROUP BY product_id
) s ON p.product_id = s.product_id
LEFT JOIN (
  SELECT product_id, SUM(quantity) as quantity
  FROM sales.order_items
  GROUP BY product_id
) o ON p.product_id = o.product_id
GROUP BY c.category_name, b.brand_name
order by b.brand_name


--Top selling products
SELECT p.product_name , SUM(i.quantity) quantity_sold
From production.products p join sales.order_items i on p.product_id = i.product_id
GROUP BY p.product_name
HAVING SUM(i.quantity) >= 100
ORDER BY quantity_sold DESC


--The percentage of sales in each store
SELECT store_name , s.state , s.city , s.street , CAST(ROUND(COUNT(*)*100.0 /(SELECT COUNT(*) FROM sales.order_items) , 2) AS DEC(10,1)) as percentage_of_quantity_sold  
FROM  sales.order_items i join sales.orders o on i.order_id = o.order_id  
join sales.stores s on s.store_id = o.store_id
GROUP BY store_name , s.state , s.city , s.street 
order by percentage_of_quantity_sold desc

--Highest and Lowest Sellers
SELECT st.first_name + ' ' + st.last_name AS Staff_name , manager.first_name + ' ' + manager.last_name Manager , s.store_name, s.state ,SUM(i.quantity) as total_quantity
FROM sales.orders o join sales.order_items i on o.order_id = i.order_id
right join sales.staffs st on st.staff_id = o.staff_id
left join sales.staffs manager on manager.staff_id = st.manager_id 
join sales.stores s on s.store_id = st.store_id
GROUP BY st.first_name , st.last_name , manager.first_name , manager.last_name , s.store_name , s.state
order by total_quantity desc


--Customer information and the quantity of products who ordered 
SELECT cu.first_name + ' ' + cu.last_name customer_name , cu.email , cu.state , cu.city , cu.street ,cu.zip_code , SUM(i.quantity) quantity_sold
FROM  sales.orders o join sales.order_items i on o.order_id = i.order_id 
join sales.customers cu on cu.customer_id = o.customer_id
group by cu.first_name , cu.last_name , cu.email , cu.state , cu.city , cu.street , cu.zip_code
HAVING SUM(i.quantity) >=15
order by quantity_sold desc 

--The quantity sold of each category by quarter over the three years
SELECT 
    quarter,
	category_name,
    SUM(quantity) AS quantity_sold
FROM  
    (SELECT 
        oi.quantity, c.category_name,
        CASE 
            WHEN o.order_date BETWEEN '2016-01-01' AND '2016-03-31' THEN 'Q1-2016'
            WHEN o.order_date BETWEEN '2016-04-01' AND '2016-06-30' THEN 'Q2-2016'
            WHEN o.order_date BETWEEN '2016-07-01' AND '2016-09-30' THEN 'Q3-2016'
            WHEN o.order_date BETWEEN '2016-10-01' AND '2016-12-31' THEN 'Q4-2016'
            WHEN o.order_date BETWEEN '2017-01-01' AND '2017-03-31' THEN 'Q1-2017'
            WHEN o.order_date BETWEEN '2017-04-01' AND '2017-06-30' THEN 'Q2-2017'
            WHEN o.order_date BETWEEN '2017-07-01' AND '2017-09-30' THEN 'Q3-2017'
            WHEN o.order_date BETWEEN '2017-10-01' AND '2017-12-31' THEN 'Q4-2017'
            WHEN o.order_date BETWEEN '2018-01-01' AND '2018-03-31' THEN 'Q1-2018'
            WHEN o.order_date BETWEEN '2018-04-01' AND '2018-06-30' THEN 'Q2-2018'
            WHEN o.order_date BETWEEN '2018-07-01' AND '2018-09-30' THEN 'Q3-2018'
            WHEN o.order_date BETWEEN '2018-10-01' AND '2018-12-28' THEN 'Q4-2018'
            ELSE 'Other' 
        END AS quarter
    FROM 
        sales.orders o
        JOIN sales.order_items oi ON o.order_id = oi.order_id 
		JOIN production.products p on p.product_id = oi.product_id
		JOIN production.categories c on c.category_id = p.category_id
    WHERE 
        o.order_date BETWEEN '2016-01-01' AND '2018-12-28') AS temp

GROUP BY quarter , category_name
order by quarter 
