create database Zepto_SQL_Project

use Zepto_SQL_Project

drop table if exists zepto

create table zepto(
sku_id int identity(1,1) primary key,
category varchar(120),
name varchar(150) not null,
mrp decimal(8,2),
discountPercent decimal(5,2),
availableQuantity integer,
discountedSellingPrice decimal(8,2),
weightInGms integer,
outOfStock bit,
quantity integer
)

--inserting data from csv to zepto
insert into zepto (category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity)
select category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity
from dbo.zepto_v2

--data exploration

--count of rows
select count(*) from zepto

--sample data
select top 10 * from zepto

--null values
select * from zepto
where name is null
or
name is null
or
category is null
or
mrp is null
or
discountPercent is null
or
discountedSellingPrice is null
or
weightInGms is null
or
availableQuantity is null
or
outOfStock is null
or
quantity is null

--different product categories
select distinct category from zepto
order by category

--Products in stock vs out of stock
select outOfStock,count(sku_id) from zepto
group by outOfStock

--Product names present multiple times
select name,count(sku_id) as "Number of SKU's"
from zepto
group by name
having count(sku_id) > 1
order by count(sku_id) desc

--data cleaning

--products with price - zero
select * from zepto
where mrp=0 or discountedSellingPrice=0

delete from zepto
where mrp = 0 --1row effected

--convert paise to ruppes
update zepto
set
	mrp = mrp/100.0,
	discountedSellingPrice = discountedSellingPrice/100.0

--checking
select mrp,discountedSellingPrice from zepto

--Q1.Find the top 10 best-value products based on the discount percentage.
select distinct top 10 name, mrp, discountPercent from zepto
order by discountPercent desc

--Q2.What are the Products with High MRP but Out Of Stock
select distinct name,mrp from zepto
where outOfStock = 1 and mrp > 300
order by mrp desc

--Q3.Caluculate Estimated Revenue for each category
select category,sum(discountedSellingPrice*availableQuantity) as total_revenue
from zepto
group by category
order by total_revenue

--Q4.Find all products where MRP is greater than 500 and discount is less than 10%
select distinct name,mrp,discountPercent from zepto
where mrp > 500 and discountPercent < 10
order by mrp desc, discountPercent desc

--Q5.Identify the top 5 categories offering the highest average discount percentage.
select top 5 category,
cast(round(avg(discountPercent), 2) as decimal(10,2)) as avg_discount
from zepto
group by category
order by avg_discount desc

--Q6.Find the price per gram for products above 100g and sort by best value.
select distinct name, weightInGms, discountedSellingPrice,
cast(round(discountedSellingPrice/weightInGms,2) as decimal(10,2)) as price_per_gram
from zepto
where weightInGms>=100
order by price_per_gram

--Q7.Group the products into categories like Low, Medium, Bulk.
select distinct name, weightInGms,
case when weightInGms < 1000 then 'Low'
	when weightInGms < 5000 then 'Medium'
	else 'Bulk'
	end as weight_category
from zepto

--Q8.What is the Total Inventory Weight Per Category
select category,
sum(weightInGms * availableQuantity) as total_weight
from zepto
group by category
order by total_weight