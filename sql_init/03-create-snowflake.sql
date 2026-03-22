CREATE SCHEMA IF NOT EXISTS snowflake;


CREATE TABLE snowflake.dim_pet_type (
    pet_type_key SERIAL PRIMARY KEY,
    pet_type VARCHAR(50),
    pet_breed VARCHAR(100)
);

CREATE TABLE snowflake.dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(200),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    pet_name VARCHAR(100),
    pet_type_key INTEGER REFERENCES snowflake.dim_pet_type(pet_type_key)
);

CREATE TABLE snowflake.dim_brand (
    brand_key SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) UNIQUE
);

CREATE TABLE snowflake.dim_color (
    color_key SERIAL PRIMARY KEY,
    color_name VARCHAR(50) UNIQUE
);

CREATE TABLE snowflake.dim_material (
    material_key SERIAL PRIMARY KEY,
    material_name VARCHAR(100) UNIQUE
);

CREATE TABLE snowflake.dim_product_category (
    category_key SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE
);

CREATE TABLE snowflake.dim_pet_category (
    pet_category_key SERIAL PRIMARY KEY,
    pet_category_name VARCHAR(50) UNIQUE
);

CREATE TABLE snowflake.dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200),
    category_key INTEGER REFERENCES snowflake.dim_product_category(category_key),
    pet_category_key INTEGER REFERENCES snowflake.dim_pet_category(pet_category_key),
    brand_key INTEGER REFERENCES snowflake.dim_brand(brand_key),
    color_key INTEGER REFERENCES snowflake.dim_color(color_key),
    material_key INTEGER REFERENCES snowflake.dim_material(material_key),
    size VARCHAR(50),
    price DECIMAL(10,2),
    weight DECIMAL(10,2),
    rating DECIMAL(3,2),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE,
    description TEXT
);

CREATE TABLE snowflake.dim_seller (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    country VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE snowflake.dim_store (
    store_key SERIAL PRIMARY KEY,
    store_name VARCHAR(200),
    location VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(200)
);

CREATE TABLE snowflake.dim_supplier (
    supplier_key SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200),
    contact_person VARCHAR(200),
    email VARCHAR(200),
    phone VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE snowflake.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE UNIQUE,
    year INTEGER,
    month INTEGER,
    day INTEGER
);


CREATE TABLE snowflake.fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,
    customer_key INTEGER REFERENCES snowflake.dim_customer(customer_id),
    seller_key INTEGER REFERENCES snowflake.dim_seller(seller_id),
    product_key INTEGER REFERENCES snowflake.dim_product(product_id),
    store_key INTEGER REFERENCES snowflake.dim_store(store_key),
    supplier_key INTEGER REFERENCES snowflake.dim_supplier(supplier_key),
    date_key INTEGER REFERENCES snowflake.dim_date(date_key),
    quantity INTEGER,
    total_price DECIMAL(10,2)
);