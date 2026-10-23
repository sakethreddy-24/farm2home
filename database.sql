-- Farm2Home database setup. Run:  mysql -u root -p < database.sql
CREATE DATABASE IF NOT EXISTS farm2home;
USE farm2home;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(20) NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('consumer', 'farmer') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  category VARCHAR(50) NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  farmer_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES users(id)
);

CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  consumer_id INT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('Confirmed', 'Preparing', 'Delivered') NOT NULL DEFAULT 'Confirmed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (consumer_id) REFERENCES users(id)
) AUTO_INCREMENT = 1001;

CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Sample users. Password for both is: password123
INSERT INTO users (name, email, phone, password, role) VALUES
('Ramesh Farmer', 'farmer@farm2home.com', '9876543210',
 '$2a$10$xBEwxBMYVVgypdjk6na0AOsMg/bMvChoTl7hxRdx4bDg85kzM7IOO', 'farmer'),
('John Consumer', 'consumer@farm2home.com', '9123456780',
 '$2a$10$xBEwxBMYVVgypdjk6na0AOsMg/bMvChoTl7hxRdx4bDg85kzM7IOO', 'consumer');

INSERT INTO products (name, description, price, category, quantity, farmer_id) VALUES
('Tomatoes', 'Fresh red tomatoes, farm picked.', 40, 'Vegetables', 100, 1),
('Potatoes', 'Good quality potatoes for everyday cooking.', 35, 'Vegetables', 200, 1),
('Carrots', 'Crunchy sweet carrots.', 50, 'Vegetables', 80, 1),
('Mangoes', 'Juicy Alphonso mangoes.', 120, 'Fruits', 60, 1),
('Spinach', 'Fresh green spinach, sold per bunch.', 25, 'Leafy Greens', 50, 1);
