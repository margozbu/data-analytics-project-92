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
