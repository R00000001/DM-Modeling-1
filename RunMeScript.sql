use store01;

select -- Вся інформація з замовлень
	orders.order_id,
	orders.order_date,
	customers.name as customer_name,
	SUM(order_items.quantity * order_items.price) as total_amount
from orders
join customers on
	orders.customer_id = customers.customer_id
join order_items on
	orders.order_id = order_items.order_id
group by
	orders.order_id,
	orders.order_date,
	customers.name
order by
	orders.order_date,
	orders.order_id;

select -- Самий популярний продукт
	products.product_id,
	products.name as product_name,
	SUM(order_items.quantity) as total_sold
from
	order_items
join products
    on
	order_items.product_id = products.product_id
group by
	products.product_id,
	products.name
order by
	total_sold desc
limit 1;

select -- Запаси продуктів
	products.product_id,
	products.name as product_name,
	products.stock as current_stock
from
	products;
 
select -- Покупці без замовлень
	customers.customer_id,
	customers.name,
	customers.email
from
	customers
left join orders
    on
	customers.customer_id = orders.customer_id
where
	orders.order_id is null;
