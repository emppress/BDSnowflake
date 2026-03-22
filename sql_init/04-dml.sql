INSERT INTO snowflake.dim_pet_type (pet_type, pet_breed)
SELECT DISTINCT 
    customer_pet_type,
    customer_pet_breed
FROM public.mock_data
WHERE customer_pet_type IS NOT NULL;

INSERT INTO snowflake.dim_brand (brand_name)
SELECT DISTINCT product_brand
FROM public.mock_data
WHERE product_brand IS NOT NULL;

INSERT INTO snowflake.dim_color (color_name)
SELECT DISTINCT product_color
FROM public.mock_data
WHERE product_color IS NOT NULL;

INSERT INTO snowflake.dim_material (material_name)
SELECT DISTINCT product_material
FROM public.mock_data
WHERE product_material IS NOT NULL;

INSERT INTO snowflake.dim_product_category (category_name)
SELECT DISTINCT product_category
FROM public.mock_data
WHERE product_category IS NOT NULL;

INSERT INTO snowflake.dim_pet_category (pet_category_name)
SELECT DISTINCT pet_category
FROM public.mock_data
WHERE pet_category IS NOT NULL;;

INSERT INTO snowflake.dim_customer (first_name, last_name, age, email, 
    country, postal_code, pet_name, pet_type_key
)
SELECT DISTINCT ON (md.customer_email)
    md.customer_first_name,
    md.customer_last_name,
    md.customer_age,
    md.customer_email,
    md.customer_country,
    md.customer_postal_code,
    md.customer_pet_name,
    pt.pet_type_key
FROM public.mock_data md
LEFT JOIN snowflake.dim_pet_type pt 
    ON pt.pet_type = md.customer_pet_type 
    AND pt.pet_breed = md.customer_pet_breed;

INSERT INTO snowflake.dim_product (
    product_name, category_key, pet_category_key,
    brand_key, color_key, material_key, size, price,
    weight, rating, reviews, release_date, expiry_date, description
)
SELECT DISTINCT ON (
    md.product_name,  md.product_category, md.product_brand,
    md.product_price, md.product_color, md.product_size,
    md.product_material, md.product_weight
)
    md.product_name,
    pc.category_key,
    pcat.pet_category_key,
    b.brand_key,
    c.color_key,
    m.material_key,
    md.product_size,
    md.product_price,
    md.product_weight,
    md.product_rating,
    md.product_reviews,
    NULLIF(md.product_release_date, '')::DATE,
    NULLIF(md.product_expiry_date, '')::DATE,
    md.product_description
FROM public.mock_data md
LEFT JOIN snowflake.dim_product_category pc ON pc.category_name = md.product_category
LEFT JOIN snowflake.dim_pet_category pcat ON pcat.pet_category_name = md.pet_category
LEFT JOIN snowflake.dim_brand b ON b.brand_name = md.product_brand
LEFT JOIN snowflake.dim_color c ON c.color_name = md.product_color
LEFT JOIN snowflake.dim_material m ON m.material_name = md.product_material;

INSERT INTO snowflake.dim_seller (
    first_name, last_name, email, country, postal_code
)
SELECT DISTINCT ON (md.seller_email)
    md.seller_first_name,
    md.seller_last_name,
    md.seller_email,
    md.seller_country,
    md.seller_postal_code
FROM public.mock_data md;

INSERT INTO snowflake.dim_store (
    store_name, location, city, state, country, phone, email
)
SELECT DISTINCT
    md.store_name,
    md.store_location,
    md.store_city,
    md.store_state,
    md.store_country,
    md.store_phone,
    md.store_email
FROM public.mock_data md
WHERE md.store_name IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO snowflake.dim_supplier (
    supplier_name, contact_person, email, phone, address, city, country
)
SELECT DISTINCT
    md.supplier_name,
    md.supplier_contact,
    md.supplier_email,
    md.supplier_phone,
    md.supplier_address,
    md.supplier_city,
    md.supplier_country
FROM public.mock_data md
WHERE md.supplier_name IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO snowflake.dim_date (date_key, full_date, year, month, day)
SELECT DISTINCT
    TO_CHAR(date_parsed, 'YYYYMMDD')::INTEGER as date_key,
    date_parsed as full_date,
    EXTRACT(YEAR FROM date_parsed)::INTEGER as year,
    EXTRACT(MONTH FROM date_parsed)::INTEGER as month,
    EXTRACT(DAY FROM date_parsed)::INTEGER as day
FROM (
    SELECT 
        TO_DATE(sale_date, 'MM/DD/YYYY') as date_parsed
    FROM public.mock_data
    WHERE sale_date IS NOT NULL 
      AND sale_date != ''
      AND sale_date ~ '^\d{1,2}/\d{1,2}/\d{4}$'
) t
ON CONFLICT (full_date) DO NOTHING;

INSERT INTO snowflake.fact_sales (
    customer_key, seller_key, product_key, store_key, 
    supplier_key, date_key, quantity, total_price
)
SELECT 
    c.customer_id,
    s.seller_id,
    p.product_id,
    st.store_key,
    sup.supplier_key,
    d.date_key,
    md.sale_quantity,
    md.sale_total_price
FROM public.mock_data md
LEFT JOIN snowflake.dim_customer c ON 
    c.email = md.customer_email
LEFT JOIN snowflake.dim_seller s ON 
    s.email = md.seller_email
LEFT JOIN snowflake.dim_product p ON 
    p.product_name IS NOT DISTINCT FROM md.product_name
    AND p.price IS NOT DISTINCT FROM md.product_price
    AND p.size IS NOT DISTINCT FROM md.product_size
    AND p.weight IS NOT DISTINCT FROM md.product_weight
LEFT JOIN snowflake.dim_store st ON 
    st.store_name IS NOT DISTINCT FROM md.store_name 
    AND st.location IS NOT DISTINCT FROM md.store_location
    AND st.city IS NOT DISTINCT FROM md.store_city
    AND st.country IS NOT DISTINCT FROM md.store_country
LEFT JOIN snowflake.dim_supplier sup ON 
    sup.email = md.supplier_email
LEFT JOIN snowflake.dim_date d ON d.full_date = TO_DATE(md.sale_date, 'MM/DD/YYYY')
WHERE md.sale_customer_id IS NOT NULL;