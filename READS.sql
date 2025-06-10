-- TASK 1: Dirty Read (READ UNCOMMITTED)
use modeling;

set session transaction isolation level read uncommitted;-- виставляю ізоляцію
start transaction; -- починаю транзакцію
update products
setstock = 10 
where product_id = 1; -- просто роблю зміни, але без комміту (щоб потім зробити роллбек)
rollback; -- якщо я потім захочу відкотитись

set session transaction isolation level read uncommitted; -- виставляю ізоляцію
select stock
from products
where product_id = 1; -- просто дивлюсь на результат
-- В результаті я бачу кількість 10, але я завжди можу зробити роллбек і кількість повернеться 


-- TASK 2: Non-Repeatable Read (READ COMMITTED)
set session transaction isolation level read committed; -- виставляю рівень ізоляції
start transaction; -- починаю транзакцію
select stock
from products
where product_id = 2; -- перевіряю кількість продукту
commit; -- комміт даних

set session transaction isolation level read committed; -- виставляю рівень ізоляції
start transaction; -- починаю транзакцію
update products
set stock = 11
where product_id = 2; -- оновлюю кількість продукту
commit; -- комміт даних

-- BONUS TASK 1: Repeatable Read (REPEATABLE READ)
set session transaction isolation level repeatable read; -- ставлю рівень транзакції
start transaction; -- починаю транзакцію
select stock
from products
where product_id = 3; -- дивлюсь кількість продукту
commit; -- комміт даних

set session transaction isolation level repeatable read; -- ставлю рівень ізоляції
start transaction; -- починаю транзакцію
update products
set stock = 10
where product_id = 3; -- оновлюю кількість продукту
commit; -- комміт даних

-- BONUS TASK 3: Deadlock
start transaction; -- починаю транзакцію
update products
set stock = 18
where product_id = 1; -- оновлюю кількість продукту
update products
set stock = 180
where product_id = 2; -- оновлюю кількість продукту

start transaction; -- починаю транзакцію

update products
set stock = 210
where product_id = 2; -- оновлюю кількість продукту

update products
set stock = 21
where product_id = 1; -- оновлюю кількість продукту
-- коротше ось тут дедлок, бо перша частина першої транзакції лочить продукт з айді 1
-- а друга з айді 2 і потім ви зрозуміли

-- commit;
