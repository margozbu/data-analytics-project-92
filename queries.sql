-- определяем общее количество покупателей
select
	count(customer_id) as customers_count
from customers; 

-- определяем десятку лучших продавцов
select
	concat_ws(' ', e.first_name, e.last_name) as seller,
	count(s.sales_id)as operations,
	floor(sum(s.quantity * p.price)) as income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name
order by income desc nulls last limit 10;

-- определяем информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
select
	concat_ws(' ', e.first_name, e.last_name) as seller,
	floor(avg(s.quantity * p.price)) as average_income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name
having avg(s.quantity * p.price) < (
	select
		avg(s2.quantity * p2.price)
	from sales s2
	inner join products p2 on s2.product_id = p2.product_id)
order by average_income ASC;

-- определяем выручку по дням недели
select
	concat_ws(' ', e.first_name, e.last_name) as seller,
	to_char(s.sale_date,'day') as day_of_week,
	floor(sum(s.quantity * p.price)) as income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name, to_char(s.sale_date,'day'), extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), seller;

-- определяем количество покупателей в разных возрастных группах
select
	case
		when age > 15 and age < 26 then '16-25'
		when age > 25 and age < 41 then '26-40'
		else '40+'
	end as age_category,
	count(*) as age_count
from customers c
group by age_category
order by age_category;

-- определяем количество уникальных покупателей и выручку, которую они принесли, по месяцам
select
	to_char(s.sale_date, 'YYYY-MM') as selling_month,
	count(distinct s.customer_id) as total_customers,
	floor(sum(s.quantity * p.price)) as income
from sales s
left join products p on s.product_id = p.product_id
group by to_char(s.sale_date, 'YYYY-MM')
order by selling_month;

-- определяем покупателей, первая покупка которых была в ходе проведения акций
with tab1 as (
select
	s.customer_id,
	concat_ws(' ', c.first_name, c.last_name) as customer,
	s.sale_date,
	concat_ws(' ', e.first_name, e.last_name) as seller,
	p.price
from sales s 
left join customers c on s.customer_id = c.customer_id
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by s.customer_id, concat_ws(' ', c.first_name, c.last_name), s.sale_date, concat_ws(' ', e.first_name, e.last_name), p.price
order by s.customer_id, customer, sale_date, seller, price
),
	
tab2 as (
select
	*,
	row_number() over (partition by tab1.customer_id order by tab1.customer_id, tab1.price) as rn
from tab1
order by tab1.customer, tab1.sale_date, rn, tab1.price
)
	
select distinct on (tab2.customer_id)
	tab2.customer,
	tab2.sale_date,
	tab2.seller
from tab2
where tab2.price = 0 and tab2.rn = 1
order by tab2.customer_id;
