-- определяем общее количество покупателей
select
	count(customer_id) as customers_count
from customers; 

-- определяем десятку лучших продавцов
select
	concat_ws(' ', e.first_name, e.last_name) as seller,
	count(s.sales_id) as operations,
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
select distinct on (s.customer_id)
	concat_ws(' ', c.first_name, c.last_name) as customer,
	s.sale_date,
	concat_ws(' ', e.first_name, e.last_name) as seller
from sales s 
left join customers c on s.customer_id = c.customer_id
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
where p.price = 0
order by s.customer_id, s.sale_date, p.price;
