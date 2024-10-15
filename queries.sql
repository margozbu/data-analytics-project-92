-- определяем общее количество покупателей
select
	count(customer_id) as customers_count
from customers; 

-- определяем десятку лучших продавцов
select
	concat_ws(' ', e.first_name, e.last_name) as seller,
	count(s.sales_id)as operations,
	trunc(sum(s.quantity * p.price)) as income
from employees e
left join sales s on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name
order by income desc nulls last limit 10;

-- определяем информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
select
	concat_ws(' ', e.first_name, e.last_name) as seller,
	trunc(avg(s.quantity * p.price)) as average_income
from employees e
left join sales s on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name
having trunc(avg(s.quantity * p.price)) < (
	select
		trunc(avg(s2.quantity * p2.price))
	from sales s2
	inner join products p2 on s2.product_id = p2.product_id)
order by average_income ASC;

-- определяем выручку по дням недели
select
	concat_ws(' ', e.first_name, e.last_name) as seller,
	to_char(s.sale_date,'Day') as day_of_week,
	trunc(sum(s.quantity * p.price)) as income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name, to_char(s.sale_date,'Day'), extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), seller;

-- определяем количество покупателей в разных возрастных группах
select
	age_category,
	count(*) as age_count
from (select
	case
		when age > 15 and age < 26 then '16-25'
		when age > 25 and age < 41 then '26-40'
		else '40+'
	end as age_category	
from customers c)
as agecat
group by age_category
order by age_category;
