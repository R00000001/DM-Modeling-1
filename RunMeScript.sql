use store01;

select -- видає всю інфу з замовлень
	o.order_id,
	o.order_date,
	c.name as customer_name,
	SUM(oi.quantity * oi.price) as total_amount
from
	orders as o
join customers as c
  on
	o.customer_id = c.customer_id
join order_items as oi
  on
	o.order_id = oi.order_id
group by
	o.order_id,
	o.order_date,
	c.name
order by
	o.order_date,
	o.order_id;

select -- самий популярний продукт
  p.product_id,
  p.name as product_name,
  SUM(oi.quantity) as total_sold
from
order_items as oi
join products as p
  on
oi.product_id = p.product_id
group by
  p.product_id,
  p.name
order by
  total_sold desc
limit 1;

select -- запаси
	p.product_id,
	p.name as product_name,
	p.stock as current_stock
from
	products as p;

select -- покупці без замовлень
	c.customer_id,
	c.name,
	c.email
from
	customers as c
left join orders as o
  on
	c.customer_id = o.customer_id
where
	o.order_id is null;