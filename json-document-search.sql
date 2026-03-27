select * from products_json;

CREATE TABLE products_json (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    details JSONB
);


-- Create a GIN index on the entire details JSONB column
CREATE INDEX idx_products_details_gin ON products_json USING GIN (details);


-- Create a B-tree index on the 'price' field within the details JSONB
-- CREATE INDEX idx_products_details_price ON products_json ((details->>'price')::NUMERIC);

-- Create a B-tree index on the 'brand' field within the details JSONB
CREATE INDEX idx_products_details_brand ON products_json USING BTREE ((details->>'brand'));

-- Create a B-tree index on the 'stock' field within the details JSONB
-- CREATE INDEX idx_products_details_stock ON products_json ((details->>'stock')::INT);


INSERT INTO products_json (name, category, details) VALUES
('Quantum Keyboard RGB', 'Peripherals', '{
    "brand": "TechGear",
    "model": "GK-1000",
    "features": ["mechanical", "RGB lighting", "programmable macros"],
    "specifications": {
        "switch_type": "Cherry MX Red",
        "layout": "Full-size",
        "connectivity": "USB-C"
    },
    "price": 129.99,
    "stock": 50,
    "availability": "In Stock",
    "warranty_years": 2,
    "reviews": [
        {"user": "Alice", "rating": 5, "comment": "Amazing keyboard!"},
        {"user": "Bob", "rating": 4, "comment": "RGB is vibrant."}
    ]
}'),
('ErgoMouse Wireless', 'Peripherals', '{
    "brand": "ComfortTech",
    "model": "EM-500",
    "features": ["ergonomic design", "wireless", "rechargeable battery"],
    "specifications": {
        "DPI": 1600,
        "buttons": 6,
        "connectivity": "2.4GHz USB Dongle"
    },
    "price": 49.99,
    "stock": 120,
    "availability": "In Stock",
    "reviews": [
        {"user": "Charlie", "rating": 5, "comment": "Very comfortable for long sessions."},
        {"user": "David", "rating": 4, "comment": "Battery life is good."}
    ]
}'),
('UltraHD Monitor 27"', 'Monitors', '{
    "brand": "VisioLux",
    "model": "VL-274K",
    "features": ["4K resolution", "HDR support", "IPS panel"],
    "specifications": {
        "screen_size_inches": 27,
        "resolution": "3840x2160",
        "refresh_rate_hz": 60,
        "ports": ["HDMI", "DisplayPort"]
    },
    "price": 399.99,
    "stock": 30,
    "availability": "Limited Stock",
    "warranty_years": 3
}'),
('NoiseCancelling Headphones', 'Audio', '{
    "brand": "SoundPro",
    "model": "SP-ANC-200",
    "features": ["active noise cancellation", "Bluetooth 5.0", "long battery life"],
    "specifications": {
        "driver_size_mm": 40,
        "battery_hours": 30
    },
    "price": 199.00,
    "stock": 75,
    "availability": "In Stock",
    "colors_available": ["Black", "Silver", "Blue"],
    "reviews": [
        {"user": "Eve", "rating": 5, "comment": "Best noise cancellation I have experienced!"}
    ]
}'),
('Portable SSD 1TB', 'Storage', '{
    "brand": "SpeedDrive",
    "model": "SD-P1000",
    "features": ["USB 3.2 Gen 2", "compact design", "durable"],
    "specifications": {
        "capacity_gb": 1000,
        "read_speed_mbps": 1050,
        "write_speed_mbps": 1000
    },
    "price": 89.99,
    "stock": 200,
    "availability": "In Stock"
}'),
('Smart Home Hub', 'Smart Home', '{
    "brand": "ConnectAll",
    "model": "CH-V1",
    "features": ["Zigbee", "Z-Wave", "Wi-Fi", "voice control"],
    "price": 149.99,
    "stock": 40,
    "availability": "In Stock",
    "supported_protocols": ["Zigbee", "Z-Wave", "Matter"]
}'),
('Gaming Chair Pro', 'Furniture', '{
    "brand": "ErgoGame",
    "model": "GC-Elite",
    "features": ["lumbar support", "recline function", "adjustable armrests"],
    "price": 249.00,
    "stock": 15,
    "availability": "Low Stock",
    "material": "PU Leather"
}');

-- 3. Querying JSONB Data
-- PostgreSQL offers powerful operators and functions for querying JSONB data.

-- 3.1. Basic Extraction
-- -> (JSON object field or array element as JSONB): Extracts a JSON object field or array element. The result is still JSONB.

-- ->> (JSON object field or array element as text): Extracts a JSON object field or array element as TEXT.

-- Get the brand and price of all products
SELECT
    name,
    details->>'brand' AS brand,
    details->>'price' AS price
FROM products_json;

-- Get the first feature (array element 0) of the Quantum Keyboard
SELECT
    name,
    details->'features'->>0 AS first_feature
FROM products_json
WHERE name = 'Quantum Keyboard RGB';

-- Get the full specifications object for a product
SELECT
    name,
    details->'specifications' AS specs_jsonb
FROM products_json
WHERE name = 'UltraHD Monitor 27"';


-- Find products manufactured by 'TechGear'
SELECT name, category, details->>'brand' FROM products_json
WHERE details @> '{"brand": "TechGear"}';

-- Find products with a stock less than 50 (numeric comparison requires casting)
SELECT name, category, details->>'stock' AS stock FROM products_json
WHERE (details->>'stock')::INT < 50;

-- Find products that have 'RGB lighting' as a feature (uses contains on array)
SELECT name, category, details->'features' AS features_array FROM products_json
WHERE details->'features' @> '["RGB lighting"]';

-- Find products where the 'details' JSONB contains a top-level key named 'warranty_years'
SELECT name, details->>'warranty_years' AS warranty FROM products_json
WHERE details ? 'warranty_years';

-- Find products that have either 'colors_available' or 'material' as a top-level key
SELECT name, details FROM products_json
WHERE details ?| ARRAY['colors_available', 'material'];

-- Find products that have both 'stock' and 'price' as top-level keys
SELECT name, details FROM products_json
WHERE details ?& ARRAY['stock', 'price'];

-- Find products with reviews where a rating of 5 exists
-- This involves unnesting the array and checking its contents
SELECT p.name, p.category, review->>'user' AS reviewer, review->>'rating' AS rating
FROM products_json p, jsonb_array_elements(p.details->'reviews') AS review
WHERE review @> '{"rating": 5}';

-- 3.3. Advanced Queries
-- jsonb_array_elements(): Expands a JSON array into a set of JSONB values.

-- jsonb_each_text(): Expands the top-level JSON object into a set of key/value pairs.

-- List all features for each product (unnesting the features array)
SELECT
    p.name,
    feature_text
FROM
    products_json p,
    jsonb_array_elements_text(p.details->'features') AS feature_text;

-- Find products that are "In Stock" AND have a price less than 100
SELECT name, category, details->>'price' AS price, details->>'availability' AS availability
FROM products_json
WHERE
    details @> '{"availability": "In Stock"}'
    AND (details->>'price')::NUMERIC < 100.00;

-- Find products with a specific nested specification (e.g., screen_size_inches for monitors)
SELECT name, details->>'screen_size_inches' AS screen_size
FROM products_json
WHERE category = 'Monitors'
  AND (details->'specifications'->>'screen_size_inches')::INT > 25;

-- Find products that have a review from 'Alice'
SELECT p.name, p.details->'reviews' AS reviews
FROM products_json p
WHERE EXISTS (
    SELECT 1
    FROM jsonb_array_elements(p.details->'reviews') AS review
    WHERE review->>'user' = 'Alice'
);
