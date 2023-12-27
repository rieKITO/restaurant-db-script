DROP TRIGGER IF EXISTS audit_dish_trigger ON dish;

DROP PROCEDURE IF EXISTS generate_dish(num_rows INT);
DROP FUNCTION IF EXISTS generate_random_dish_name();
DROP FUNCTION IF EXISTS generate_random_dish_weight();
DROP FUNCTION IF EXISTS generate_random_dish_image();
DROP FUNCTION IF EXISTS dish_audit();

DROP VIEW IF EXISTS date_sales;
DROP VIEW IF EXISTS dishes_with_potato;
DROP VIEW IF EXISTS toast_sales;

DROP TABLE IF EXISTS audit_dish;
DROP TABLE IF EXISTS daily_cooking;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS recipe;
DROP TABLE IF EXISTS many_dish_to_many_product;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS dish;
DROP TABLE IF EXISTS dish_type;

DROP SCHEMA IF EXISTS restaurant;

REVOKE CONNECT ON DATABASE potemkin_av_db FROM waiter_role_pav;
REVOKE CONNECT ON DATABASE potemkin_av_db FROM waiter_user_pav;
REVOKE CONNECT ON DATABASE potemkin_av_db FROM chef_role_pav;
REVOKE CONNECT ON DATABASE potemkin_av_db FROM chef_user_pav;
REVOKE CONNECT ON DATABASE potemkin_av_db FROM manager_role_pav;
REVOKE CONNECT ON DATABASE potemkin_av_db FROM manager_user_pav;

DROP ROLE IF EXISTS waiter_role_pav;
DROP ROLE IF EXISTS waiter_user_pav;
DROP ROLE IF EXISTS chef_role_pav;
DROP ROLE IF EXISTS chef_user_pav;
DROP ROLE IF EXISTS manager_role_pav;
DROP ROLE IF EXISTS manager_user_pav;

CREATE SCHEMA IF NOT EXISTS restaurant AUTHORIZATION potemkin_av;
COMMENT ON SCHEMA restaurant IS 'Схема ресторана';

GRANT ALL ON SCHEMA restaurant TO potemkin_av;
ALTER ROLE potemkin_av IN DATABASE potemkin_av_db SET search_path TO restaurant, public;
SET search_path TO restaurant, public;

CREATE TABLE dish (
	id serial NOT NULL,
	name TEXT NOT NULL,
	type_id integer NOT NULL,
	weight_gram integer NOT NULL,
	image text NOT NULL,
	CONSTRAINT dish_pk PRIMARY KEY (id)
);

COMMENT ON TABLE dish is 'Таблица, содержащая информацию о блюде';
COMMENT ON COLUMN dish.id is 'Поле, хранящее идинтификационный номер блюда';
COMMENT ON COLUMN dish.name is 'Поле, хранящее название блюда';
COMMENT ON COLUMN dish.type_id is 'Поле, хранящее идинтификационный номер типа блюда';
COMMENT ON COLUMN dish.weight_gram is 'Поле, хранящее вес блюда в граммах';
COMMENT ON COLUMN dish.image is 'Поле, хранящее изображение блюда';

CREATE TABLE audit_dish (
    id serial NOT NULL,
    name TEXT NOT NULL,
	type_id integer NOT NULL,
	weight_gram integer NOT NULL,
	image text NOT NULL,
    operation text,
	operation_date timestamp,
    user_name text
);

CREATE TABLE daily_cooking (
	id serial NOT NULL,
	dish_id integer NOT NULL,
	portion_number integer NOT NULL,
	sale_id integer NOT NULL,
	price numeric NOT NULL,
	CONSTRAINT daily_cooking_pk PRIMARY KEY (id)
);

COMMENT ON TABLE daily_cooking is 'Таблица, хранящая информацию об ежедневном приготовлении блюд';
COMMENT ON COLUMN daily_cooking.id is 'Поле, хранящее идинтификационный номер об определенном дне приготовления блюда';
COMMENT ON COLUMN daily_cooking.dish_id is 'Поле, хранящее идинтификационный номер блюда';
COMMENT ON COLUMN daily_cooking.portion_number is 'Поле, хранящее количество порций';
COMMENT ON COLUMN daily_cooking.sale_id is 'Поле, хранящее идинтификационный номер продажи';
COMMENT ON COLUMN daily_cooking.price is 'Поле, хранящее цену';

CREATE TABLE recipe (
	id serial NOT NULL,
	dish_id integer NOT NULL,
	cooking_time TIME NOT NULL,
	cooking_technology TEXT NOT NULL,
	CONSTRAINT recipe_pk PRIMARY KEY (id)
);

COMMENT ON TABLE recipe is 'Таблица, хранящая информацию о рецептах блюд';
COMMENT ON COLUMN recipe.id is 'Поле, хранящее идинтификационный номер блюда';
COMMENT ON COLUMN recipe.cooking_time is 'Поле, хранящее время приготовления блюда в минутах';
COMMENT ON COLUMN recipe.cooking_technology is 'Поле, хранящее информацию о технологии приготовления блюда';

CREATE TABLE product (
	id serial NOT NULL,
	name TEXT NOT NULL,
	caloric_value integer NOT NULL,
	weight_gram integer NOT NULL,
	price_kg numeric NOT NULL,
	CONSTRAINT product_pk PRIMARY KEY (id)
);

COMMENT ON TABLE product is 'Таблица, хранящая информацию о продуктах, из которых приготавливается блюдо';
COMMENT ON COLUMN product.id is 'Поле, хранящее идинтификациооный номер продукта';
COMMENT ON COLUMN product.name is 'Поле, хранящее имя продукта';
COMMENT ON COLUMN product.caloric_value is 'Поле, хранящее количество калорий в 100 грамм продукта';
COMMENT ON COLUMN product.weight_gram is 'Поле, хранящее вес продукта в граммах';
COMMENT ON COLUMN product.price_kg is 'Поле, хранящее цену продукта в рублях за килограмм';

CREATE TABLE many_dish_to_many_product (
	dish_id integer NOT NULL,
	product_id integer NOT NULL
);

COMMENT ON TABLE many_dish_to_many_product is 'Таблица для связи многих ко многим среди продуктов и блюд';
COMMENT ON COLUMN many_dish_to_many_product.dish_id is 'Поле, хранящее идинтификациооный номер блюда';
COMMENT ON COLUMN many_dish_to_many_product.product_id is 'Поле, хранящее идинтификационный номер продукта'; 

CREATE TABLE sales (
	id serial NOT NULL,
	date date NOT NULL,
	sale_num integer NOT NULL,
	CONSTRAINT sales_pk PRIMARY KEY (id)
);

COMMENT ON TABLE sales is 'Таблица, хранящая информацию о продажах';
COMMENT ON COLUMN sales.id is 'Поле, хранящее идинтификационный номер продажи';
COMMENT ON COLUMN sales.date is 'Поле, хранящее дату продажи';
COMMENT ON COLUMN sales.sale_num is 'Поле, хранящее номер продажи';

CREATE TABLE dish_type (
	id serial NOT NULL,
	name TEXT NOT NULL,
	CONSTRAINT dish_type_pk PRIMARY KEY (id)
);

COMMENT ON TABLE dish_type is 'Таблица, хранящая типы блюд';
COMMENT ON COLUMN dish_type.id is 'Поле, хранящее идинтификационный номер типа блюда';
COMMENT ON COLUMN dish_type.name is 'Поле, хранящее имя(вид) типа блюда';

ALTER TABLE dish
	ADD CONSTRAINT dish_fk_dish_type
	FOREIGN KEY (type_id) REFERENCES dish_type(id)
	ON UPDATE CASCADE
	ON DELETE RESTRICT;

ALTER TABLE daily_cooking
	ADD CONSTRAINT daily_cooking_fk_dish_id
	FOREIGN KEY (dish_id) REFERENCES dish(id)
	ON UPDATE CASCADE
	ON DELETE RESTRICT;

ALTER TABLE daily_cooking
	ADD CONSTRAINT daily_cooking_fk_sale_id
	FOREIGN KEY (sale_id) REFERENCES sales(id)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE recipe
	ADD CONSTRAINT recipe_fk_dish_id
	FOREIGN KEY (dish_id) REFERENCES dish(id)
	ON UPDATE CASCADE
	ON DELETE SET NULL;

ALTER TABLE many_dish_to_many_product
	ADD CONSTRAINT many_dish_to_many_product_fk_dish_id
	FOREIGN KEY (dish_id) REFERENCES dish(id)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE many_dish_to_many_product
	ADD CONSTRAINT many_dish_to_many_product_fk_product_id
	FOREIGN KEY (product_id) REFERENCES product(id)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

-- продажи --
CREATE OR REPLACE VIEW date_sales AS
SELECT dish.name AS "Название блюда",
	dish.weight_gram AS "Вес блюда",
	dish_type.name AS "Тип блюда",
	sales.date AS "Время продажи"
FROM daily_cooking
JOIN sales ON daily_cooking.sale_id = sales.id
JOIN dish ON daily_cooking.dish_id = dish.id
JOIN dish_type ON dish_type.id = dish.type_id;

-- блюда с картошкой --
CREATE OR REPLACE VIEW dishes_with_potato AS
SELECT dish.name AS "Название блюда",
	dish.weight_gram AS "Вес блюда (гр.)",
	dish_type.name AS "Тип блюда"
FROM dish
JOIN dish_type ON dish.type_id = dish_type.id
JOIN many_dish_to_many_product ON dish.id = many_dish_to_many_product.dish_id
JOIN product ON many_dish_to_many_product.product_id = product.id
WHERE product.name = 'картофель'::text;

-- Продажи гренок --
CREATE OR REPLACE VIEW toast_sales AS
SELECT dish.name AS "Название блюда",
   dish_type.name AS "Тип блюда",
   daily_cooking.portion_number AS "Количество порций",
   daily_cooking.price AS "Цена продажи",
   sales.date AS "Дата продажи",
   sales.sale_num AS "Номер чека"
FROM dish
JOIN daily_cooking ON daily_cooking.dish_id = dish.id
JOIN dish_type ON dish_type.id = dish.type_id
JOIN sales ON sales.id = daily_cooking.sale_id
WHERE dish.name = 'Гренки'::text;


INSERT INTO dish_type VALUES
(1, 'горячее'),
(2, 'холодное'),
(3, 'салат'),
(4, 'напиток'),
(5, 'закуска'),
(6, 'суп');

INSERT INTO dish VALUES
(1, 'Лазанья', 1, 500, 'https://chefmarket.ru/blog/wp-content/uploads/2021/01/a-piece-of-chicken--2000x1200.jpg'),
(2, 'Пельмени', 1, 200, 'https://meat-expert.ru/files/uploads/obzor/_2023/30/01.jpg'),
(3, 'Махито', 4, 300, 'https://www.whitealuminumsarasota.com/zupload/library/37/-148-2048x1070-0.jpg'),
(4, 'Борщ', 6, 400, 'https://mykaleidoscope.ru/x/uploads/posts/2022-09/1663686606_11-mykaleidoscope-ru-p-borshch-so-smetanoi-oboi-15.jpg'),
(5, 'Гренки', 5, 50, 'https://volgastory.ru/wp-content/uploads/8/e/d/8ed2310ec8234de309f80be5a49682ae.jpeg'),
(6, 'Окрошка', 6, 150, 'https://www.tvcook.ru/wp-content/uploads/images/topic/2015/06/11/1181205eb8.jpg');

INSERT INTO recipe VALUES
(1, 1, '00:45:00', 'Лазанья классическая с соусом бешамель готовится из листов теста, мясного фарша и соуса бешамель'),
(2, 2, '00:06:00', 'Классические пельмени готовятся из теста и фарша и овтариваются в кипяченой воде'),
(3, 3, '00:05:00', 'Классический безалкагольный махито готовится из листков мяты, лайма, содовой'),
(4, 4, '01:00:00', 'Борщ - в кипящий бульон кладут петрушку, свежую капусту, проваривают 10-15 минут, добавляют тушуную свеклу с пассерованными овощами и томатное пюре, соль, специи, сахар и варят ещё 5 минут'),
(5, 5, '00:05:00', 'Гренки готовятся из ломтиков свежего или черствого хлеба, обжаренных с растительным маслом на сковороде'),
(6, 6, '00:30:00', 'Говядину отваривают, охлаждают и нарезают мелким кубиком. Зелёный лук шинкуют. Свежие огурцы нарезают мелким кубиком. Белки яиц, сваренных вкрутую, мелко нарезают, а желтки растирают с частью сметаны, горчицей, солью и сахаром и разводят квасом. В приготовленную смесь добавляют лук, нарезанные продукты и всё перемешивают');

INSERT INTO product VALUES
(1, 'тесто', 226, 100, 50),
(2, 'фарш', 250, 100, 300),
(3, 'сыр', 350, 100, 200),
(4, 'мука', 349, 100, 100),
(5, 'сливочное масло', 748, 100, 200),
(6, 'свекла', 42, 100, 50),
(7, 'морковь', 35, 100, 50),
(8, 'подсолнечное масло', 900, 100, 150),
(9, 'картофель', 77, 100, 50),
(10, 'лайм', 16, 100, 200),
(11, 'мята', 44, 100, 50),
(12, 'огурец', 15, 100, 70),
(13, 'хлеб', 266, 100, 30),
(14, 'содовая', 38, 100, 100),
(15, 'мясо', 300, 100, 400);

INSERT INTO many_dish_to_many_product VALUES
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 7),
(2, 1),
(2, 2),
(3, 10),
(3, 11),
(3, 14),
(4, 9),
(4, 6),
(4, 3),
(5, 13),
(5, 8),
(6, 15),
(6, 12),
(6, 9);

INSERT INTO sales VALUES
(1, '2023-12-08', 1),
(2, '2023-11-11', 2),
(3, '2023-12-07', 3),
(4, '2023-12-07', 4),
(5, '2023-11-11', 5);

INSERT INTO daily_cooking VALUES
(1, 1, 2, 1, 900),
(2, 3, 2, 1, 500),
(3, 2, 1, 2, 300),
(4, 5, 2, 2, 150),
(5, 4, 1, 3, 250),
(6, 5, 2, 3, 150),
(7, 2, 1, 3, 300),
(8, 6, 1, 4, 150),
(9, 3, 1, 5, 250),
(10, 5, 1, 5, 75);


-- Функция для генерации случайного названия блюда
CREATE OR REPLACE FUNCTION generate_random_dish_name()
RETURNS TEXT AS $$
DECLARE
	names TEXT[] := ARRAY['Пицца', 'Салат', 'Суп', 'Стейк', 'Рис'];
	random_index INT;
BEGIN
	random_index := floor(random() * array_length(names, 1) + 1);
	RETURN names[random_index];
END;
$$ LANGUAGE plpgsql;

-- Функция для генерации случайного веса блюда
CREATE OR REPLACE FUNCTION generate_random_dish_weight()
RETURNS INTEGER AS $$
BEGIN
	RETURN floor(random() * 1000 + 100);
END;
$$ LANGUAGE plpgsql;

-- Функция для генерации случайного имени изображения блюда
CREATE OR REPLACE FUNCTION generate_random_dish_image()
RETURNS TEXT AS $$
DECLARE
	images TEXT[] := ARRAY['image1.jpg', 'image2.jpg', 'image3.jpg', 'image4.jpg', 'image5.jpg'];
	random_index INT;
BEGIN
	random_index := floor(random() * array_length(images, 1) + 1);
	RETURN images[random_index];
END;
$$ LANGUAGE plpgsql;

-- Основная процедура для генерации данных для таблицы dish
CREATE OR REPLACE PROCEDURE generate_dish(num_rows INT) AS $$
DECLARE
	i INT;
	random_name TEXT;
	random_type_id INTEGER;
	random_weight INTEGER;
	random_image TEXT;
BEGIN
	FOR i IN 1..num_rows LOOP
		random_name := generate_random_dish_name();
		SELECT id FROM dish_type ORDER BY RANDOM() LIMIT 1 INTO random_type_id;
		random_weight := generate_random_dish_weight();
		random_image := generate_random_dish_image();

    	INSERT INTO dish (id, name, type_id, weight_gram, image)
    	VALUES (
        	(SELECT count(*) + 1 FROM dish),
        	random_name,
        	random_type_id,
        	random_weight,
        	random_image
    	);
	END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Аудит
CREATE OR REPLACE FUNCTION dish_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_dish (name, type_id, weight_gram, image, operation, operation_date, user_name)
        VALUES (NEW.name, NEW.type_id, NEW.weight_gram, NEW.image, 'INSERT', now()::timestamp, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_dish (name, type_id, weight_gram, image, operation, operation_date, user_name)
        VALUES (OLD.name, OLD.type_id, OLD.weight_gram, OLD.image, 'UPDATE', now()::timestamp, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_dish (name, type_id, weight_gram, image, operation, operation_date, user_name)
        VALUES (OLD.name, OLD.type_id, OLD.weight_gram, OLD.image, 'DELETE', now()::timestamp, current_user);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_dish_trigger
AFTER INSERT OR UPDATE OR DELETE ON dish
FOR EACH ROW
EXECUTE FUNCTION dish_audit();

-- Роли
-- waiter
CREATE ROLE waiter_role_pav WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
NOLOGIN
NOREPLICATION
NOBYPASSRLS;
GRANT SELECT ON daily_cooking TO waiter_role_pav;
GRANT SELECT ON sales TO waiter_role_pav;
GRANT CONNECT ON DATABASE potemkin_av_db TO waiter_role_pav;
GRANT USAGE ON SCHEMA restaurant TO waiter_role_pav;

CREATE ROLE waiter_user_pav WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
LOGIN
NOREPLICATION
NOBYPASSRLS
PASSWORD 'waiter';
GRANT waiter_role_pav TO waiter_user_pav;
ALTER ROLE waiter_user_pav IN DATABASE potemkin_av_db
	SET search_path TO restaurant, public;


CREATE ROLE chef_role_pav WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
NOLOGIN
NOREPLICATION
NOBYPASSRLS;
GRANT SELECT ON dish TO chef_role_pav;
GRANT SELECT ON product TO chef_role_pav;
GRANT SELECT ON dish_type TO chef_role_pav;
GRANT SELECT ON recipe TO chef_role_pav;
GRANT CONNECT ON DATABASE potemkin_av_db TO chef_role_pav;
GRANT USAGE ON SCHEMA restaurant TO chef_role_pav;

CREATE ROLE chef_user_pav WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
LOGIN
NOREPLICATION
NOBYPASSRLS
PASSWORD 'chef';
GRANT chef_role_pav TO chef_user_pav;
ALTER ROLE chef_user_pav IN DATABASE potemkin_av_db
	SET search_path TO restaurant, public;


CREATE ROLE manager_role_pav WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
NOLOGIN
NOREPLICATION
NOBYPASSRLS;
GRANT SELECT, INSERT, UPDATE, DELETE ON dish TO manager_role_pav;
GRANT SELECT, INSERT, UPDATE, DELETE ON product TO manager_role_pav;
GRANT SELECT, INSERT, UPDATE, DELETE ON dish_type TO manager_role_pav;
GRANT SELECT, INSERT, UPDATE, DELETE ON many_dish_to_many_product TO manager_role_pav;
GRANT SELECT, INSERT, UPDATE, DELETE ON sales TO manager_role_pav;
GRANT SELECT, INSERT, UPDATE, DELETE ON recipe TO manager_role_pav;
GRANT SELECT, INSERT, UPDATE, DELETE ON daily_cooking TO manager_role_pav;
GRANT SELECT, INSERT ON audit_dish TO manager_role_pav;
GRANT CONNECT ON DATABASE potemkin_av_db TO manager_role_pav;
GRANT USAGE ON SCHEMA restaurant TO manager_role_pav;
GRANT USAGE, SELECT ON SEQUENCE audit_dish_id_seq TO manager_role_pav;

CREATE ROLE manager_user_pav WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
LOGIN
NOREPLICATION
NOBYPASSRLS
PASSWORD 'manager';
GRANT manager_role_pav TO manager_user_pav;
ALTER ROLE manager_user_pav IN DATABASE potemkin_av_db
	SET search_path TO restaurant, public;