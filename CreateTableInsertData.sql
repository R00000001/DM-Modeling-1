create database Store01; -- створюю БД

use Store01; -- юзаю

create table customers (
  customer_id INT auto_increment primary key,
  name VARCHAR(100) not null,
  email VARCHAR(100) not null unique -- юнік чисто по приколу
); -- просто кастомери

create table categories (
  category_id INT auto_increment primary key,
  name VARCHAR(100) not null
); -- категорії

create table products (
  product_id INT auto_increment primary key,
  name VARCHAR(100) not null,
  category_id INT not null, -- ФК
  price DECIMAL(10, 2) not null check (price > 0), -- перевірка на пусте значення або бесплатне
  stock INT not null check (stock >= 0), -- перевірка на не мінусові значення
  foreign key (category_id) references categories(category_id)
    on update cascade -- на всякий випадок захист від апдейтів для ФК
    on delete restrict -- блок на видалення категорії  
); 

create table orders (
  order_id INT auto_increment primary key,
  order_date DATE not null,
  customer_id INT not null,
  foreign key (customer_id) references customers(customer_id) -- ФК
    on update cascade -- те саме
    on delete restrict -- те саме
); 

create table order_items (
  order_item_id INT auto_increment primary key,
  order_id INT not null,
  product_id INT not null,
  quantity INT not null check (quantity >= 0), -- не мінусова кількість
  price DECIMAL(10, 2) not null check (price > 0), -- не пусте і більше 0
  foreign key (order_id) references orders(order_id) -- ФК 
    on update cascade 
    on delete cascade, -- якщо видалити замовлення, то і видаляться все вибране в замовленні
	foreign key (product_id) references products(product_id)
    on update cascade
    on delete restrict -- якщо видалити продукт який є в замовленні (любому
);

create role store_manager; -- ролі
create role sales_clerk;
create role analyst;

grant all privileges on store01.* to store_manager; -- рут
grant select on store01.products to sales_clerk; -- тільки селект
grant select,insert on store01.orders to sales_clerk; -- селект та інсерт
grant select,insert	on store01.order_items to sales_clerk;
grant select on store01.* to analyst; -- тільки селект

create user 'manager'@'localhost' IDENTIFIED by 'cybersecura'; -- створюю юзерів
create user 'clerk'@'localhost' IDENTIFIED by 'General_Malysh'; -- з крутими
create user 'analyst'@'localhost' IDENTIFIED by 'YoMama'; -- пассвордами

grant store_manager to 'manager'@'localhost'; -- видаю ролі
grant sales_clerk to 'clerk'@'localhost';
grant analyst to 'analyst'@'localhost';

set default role 'store_manager' for 'manager'@'localhost'; -- роблю дефолтними
set default role 'sales_clerk' for 'clerk'@'localhost';
set default role 'analyst' for 'analyst'@'localhost';
-- не знаю нашо, але на практиці це робили

DELIMITER //
create trigger trig_item_insert
after
insert on
	order_items
for each row
begin
  update products
set
	stock = stock - NEW.quantity
where
	product_id = NEW.product_id;
end //
DELIMITER ;


-- ───────────────────────────────────────────────────────────────────
-- 2. Insert Sample Data
-- ───────────────────────────────────────────────────────────────────

-- 2.1 Insert into `categories` (Bonus)
INSERT INTO categories (name) VALUES
  ('Electronics'),
  ('Accessories'),
  ('Office Supplies');



-- 2.2 Insert into `products`
-- Columns: (name, category_id, price, stock)
INSERT INTO products (name, category_id, price, stock) VALUES
  ('Laptop',         1, 1000.00,  50),
  ('Wireless Mouse', 2,   25.00, 200),
  ('Keyboard',       2,   45.00, 100),
  ('Monitor',        1,  200.00,  75),
  ('Printer',        3,  150.00,  30);



-- 2.3 Insert into `customers`
-- Columns: (name, email)
INSERT INTO customers (name, email) VALUES
  ('Alice Johnson',    'alice.johnson@example.com'),
  ('Bob Martínez',     'bob.martinez@example.com'),
  ('Charlie Svensson', 'charlie.svensson@example.com');



-- 2.4 Insert into `orders`
-- Columns: (order_date, customer_id)
-- (We assume auto-incremented order_id = 1..15 in the same order as listed here)
INSERT INTO orders (order_date, customer_id) VALUES
  ('2025-05-01', 1),  -- order_id = 1
  ('2025-05-02', 2),  -- order_id = 2
  ('2025-05-03', 1),  -- order_id = 3
  ('2025-05-04', 3),  -- order_id = 4
  ('2025-05-05', 2),  -- order_id = 5
  ('2025-05-06', 3),  -- order_id = 6
  ('2025-05-07', 1),  -- order_id = 7
  ('2025-05-09', 3),  -- order_id = 8
  ('2025-05-10', 2),  -- order_id = 9
  ('2025-05-11', 1),  -- order_id = 10
  ('2025-05-12', 2),  -- order_id = 11
  ('2025-05-13', 3),  -- order_id = 12
  ('2025-05-14', 2),  -- order_id = 13
  ('2025-05-15', 1),  -- order_id = 14
  ('2025-05-15', 3);  -- order_id = 15



-- 2.5 Insert into `order_items`
-- Columns: (order_id, product_id, quantity, price)
--
--   We list every line item for orders 1..15 in ascending order_id.
--
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
  -- Order #1 (order_id = 1)
  (1, 1, 1,    1000.00),   -- 1 × Laptop
  (1, 2, 2,      25.00),   -- 2 × Wireless Mouse

  -- Order #2 (order_id = 2)
  (2, 2, 3,      25.00),   -- 3 × Wireless Mouse
  (2, 3, 2,      45.00),   -- 2 × Keyboard

  -- Order #3 (order_id = 3)
  (3, 3, 1,      45.00),   -- 1 × Keyboard
  (3, 2, 1,      25.00),   -- 1 × Wireless Mouse
  (3, 5, 1,     150.00),   -- 1 × Printer

  -- Order #4 (order_id = 4)
  (4, 4, 1,     200.00),   -- 1 × Monitor
  (4, 2, 1,      25.00),   -- 1 × Wireless Mouse

  -- Order #5 (order_id = 5)
  (5, 5, 1,     150.00),   -- 1 × Printer
  (5, 4, 1,     200.00),   -- 1 × Monitor

  -- Order #6 (order_id = 6)
  (6, 1, 1,    1000.00),   -- 1 × Laptop
  (6, 3, 1,      45.00),   -- 1 × Keyboard
  (6, 2, 2,      25.00),   -- 2 × Wireless Mouse

  -- Order #7 (order_id = 7)
  (7, 4, 1,     200.00),   -- 1 × Monitor
  (7, 2, 1,      25.00),   -- 1 × Wireless Mouse

  -- Order #8 (order_id = 8)
  (8, 5, 2,     150.00),   -- 2 × Printer
  (8, 3, 1,      45.00),   -- 1 × Keyboard

  -- Order #9 (order_id = 9)
  (9, 2, 4,      25.00),   -- 4 × Wireless Mouse
  (9, 4, 1,     200.00),   -- 1 × Monitor

  -- Order #10 (order_id = 10)
  (10, 1, 1,   1000.00),   -- 1 × Laptop
  (10, 5, 1,    150.00),   -- 1 × Printer

  -- Order #11 (order_id = 11)
  (11, 3, 2,     45.00),   -- 2 × Keyboard
  (11, 2, 1,     25.00),   -- 1 × Wireless Mouse

  -- Order #12 (order_id = 12)
  (12, 4, 2,    200.00),   -- 2 × Monitor
  (12, 1, 1,   1000.00),   -- 1 × Laptop
  (12, 2, 2,     25.00),   -- 2 × Wireless Mouse

  -- Order #13 (order_id = 13)
  (13, 5, 1,    150.00),   -- 1 × Printer
  (13, 3, 1,     45.00),   -- 1 × Keyboard

  -- Order #14 (order_id = 14)
  (14, 2, 5,     25.00),   -- 5 × Wireless Mouse
  (14, 4, 1,    200.00),   -- 1 × Monitor

  -- Order #15 (order_id = 15)
  (15, 1, 1,   1000.00),   -- 1 × Laptop
  (15, 2, 1,     25.00);   -- 1 × Wireless Mouse
  
  

