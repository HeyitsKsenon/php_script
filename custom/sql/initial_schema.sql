-- Создание таблицы категорий
CREATE TABLE categories (
                            id SERIAL PRIMARY KEY,
                            name VARCHAR(255) NOT NULL
);

-- Создание таблицы продуктов
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(255) NOT NULL,
                          category_id INT REFERENCES categories(id),
                          price DECIMAL(10, 2) NOT NULL
);

-- Создание таблицы заказов
CREATE TABLE orders (
                        id SERIAL PRIMARY KEY,
                        product_id INT REFERENCES products(id),
                        quantity INT NOT NULL,
                        purchase_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание таблицы статистики
CREATE TABLE statistics (
                            id SERIAL PRIMARY KEY,
                            category_id INT REFERENCES categories(id),
                            total_quantity INT NOT NULL,
                            date DATE NOT NULL,
                            UNIQUE(category_id, date)
);

-- Создание функции для обновления статистики
CREATE OR REPLACE FUNCTION update_statistics() RETURNS TRIGGER AS $$
BEGIN
    -- Обновляем статистику по категории и дате
INSERT INTO statistics (category_id, total_quantity, date)
VALUES ((SELECT category_id FROM products WHERE id = NEW.product_id), NEW.quantity, CURRENT_DATE)
    ON CONFLICT (category_id, date)
    DO UPDATE SET total_quantity = statistics.total_quantity + NEW.quantity;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера на таблице заказов
CREATE TRIGGER after_order_insert
    AFTER INSERT ON orders
    FOR EACH ROW EXECUTE FUNCTION update_statistics();
